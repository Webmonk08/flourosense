from datetime import timedelta
from typing import Annotated, List
import io
import numpy as np
import tensorflow as tf
from PIL import Image

from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm

from app import auth, schemas
from app.services.supabase_service import SupabaseService
from app.models.models import User, ReportCreate, ReportInDB, ClassificationResult
from app.db.supabase import get_supabase_client

app = FastAPI(title="FluoroSense Backend")

# --- CORS Configuration ---
origins = [
    "http://localhost",
    "http://localhost:8000",
    "http://localhost:3000",
    "*", # Allow all origins for development
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

supabase_service = SupabaseService()

# Global variables for ML model
model = None
labels = []

# --- Startup Event (Initialize Supabase and Load ML Model) ---
@app.on_event("startup")
async def startup_event():
    get_supabase_client()
    print("FastAPI app starting up. Supabase initialized.")
    
    global model, labels
    try:
        # Load TFLite model
        interpreter = tf.lite.Interpreter(model_path="assets/model.tflite")
        interpreter.allocate_tensors()
        model = interpreter # Store interpreter
        print("TFLite model loaded successfully.")

        # Load labels
        with open("assets/labels.txt", "r") as f:
            labels = [line.strip() for line in f.readlines()]
        print(f"Labels loaded: {labels}")

    except Exception as e:
        print(f"Error loading TFLite model or labels: {e}")
        print("Ensure 'assets/model.tflite' and 'assets/labels.txt' exist in the backend/ directory.")

# --- User Authentication and Registration ---
@app.post("/register", response_model=schemas.UserResponse)
async def register_user(user_in: schemas.UserCreate):
    print("User registration requested for email:", user_in.email)
    existing_user = await supabase_service.get_user_by_email(user_in.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    hashed_password = auth.get_password_hash(user_in.password)
    user_data = await supabase_service.create_user(user_in.email, hashed_password)
    return schemas.UserResponse(id=user_data["email"], email=user_data["email"])

@app.post("/token", response_model=schemas.Token)
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    user = await auth.authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user["email"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=schemas.UserResponse)
async def read_users_me(current_user: Annotated[dict, Depends(auth.get_current_user)]):
    return schemas.UserResponse(id=current_user["email"], email=current_user["email"])

@app.put("/users/me", response_model=schemas.UserResponse)
async def update_user_me(
    current_user: Annotated[dict, Depends(auth.get_current_user)],
    user_update: schemas.UserUpdate
):
    update_data = user_update.model_dump(exclude_unset=True)
    
    if "password" in update_data:
        password = update_data.pop("password")
        update_data["hashed_password"] = auth.get_password_hash(password)
        
    updated_user = await supabase_service.update_user(current_user["email"], update_data)
    if not updated_user:
        raise HTTPException(status_code=400, detail="Update failed")
    return schemas.UserResponse(id=updated_user["email"], **{k: v for k, v in updated_user.items() if k != "id"})

# --- Report Submission and ML Inference ---
@app.post("/report", response_model=ClassificationResult)
async def submit_report(
    current_user: Annotated[dict, Depends(auth.get_current_user)],
    image_file: UploadFile = File(...),
    name: str = Form(...),
    age: str = Form(...),
    gender: str = Form(...),
    water_source: str = Form(...),
    toothpaste_type: str = Form(...),
    milk_intake: str | None = Form(None),
    sugar_levels: str | None = Form(None),
    toothpaste_swallowing: str | None = Form(None),
):
    if model is None:
        raise HTTPException(status_code=503, detail="ML model not loaded.")

    user_id = current_user["email"]
    
    # 1. Image Preprocessing and Inference
    contents = await image_file.read()
    image = Image.open(io.BytesIO(contents)).resize((224, 224))
    input_array = np.expand_dims(np.array(image, dtype=np.float32), axis=0) # Add batch dimension
    input_array = input_array / 255.0 # Normalize to [0, 1]

    # Get input and output tensors
    input_details = model.get_input_details()
    output_details = model.get_output_details()

    # Set the tensor to point to the input data to be inferred
    model.set_tensor(input_details[0]['index'], input_array)

    # Run inference
    model.invoke()

    # Get the results
    output_data = model.get_tensor(output_details[0]['index'])
    probabilities = np.squeeze(output_data) # Remove batch dimension

    # Get predicted class and confidence
    predicted_index = np.argmax(probabilities)
    classification = labels[predicted_index]
    confidence = float(probabilities[predicted_index]) # Convert to standard float

    # 2. Upload Image to Supabase Storage
    image_url = await supabase_service.upload_image(
        user_id=user_id,
        filename=image_file.filename,
        contents=contents,
        content_type=image_file.content_type
    )

    # 3. Save Report to Supabase
    report_data = ReportCreate(
        name=name,
        age=age,
        gender=gender,
        water_source=water_source,
        toothpaste_type=toothpaste_type,
        milk_intake=milk_intake,
        sugar_levels=sugar_levels,
        toothpaste_swallowing=toothpaste_swallowing,
        classification=classification,
        confidence=confidence,
        image_url=image_url,
        user_id=user_id,
    )
    await supabase_service.create_report(report_data)

    return ClassificationResult(classification=classification, confidence=confidence)

# --- Retrieve User Reports ---
@app.get("/reports/me", response_model=List[ReportInDB])
async def get_my_reports(current_user: Annotated[dict, Depends(auth.get_current_user)]):
    user_id = current_user["email"]
    reports = await supabase_service.get_user_reports(user_id)
    return reports

@app.get("/")
def read_root():
    return {"message": "Welcome to the FluoroSense API"}
