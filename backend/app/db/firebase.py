import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Path to your service account key file is now read from the environment
SERVICE_ACCOUNT_KEY_PATH = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

def initialize_firebase():
    """Initializes Firebase Admin SDK."""
    if not firebase_admin._apps:
        if SERVICE_ACCOUNT_KEY_PATH is None:
            print("ERROR: GOOGLE_APPLICATION_CREDENTIALS environment variable not set.")
            print("Please create a .env file in the backend/ directory and set the path to your service account key.")
            exit(1)
        
        try:
            cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
            firebase_admin.initialize_app(cred)
            print("Firebase Admin SDK initialized successfully.")
        except Exception as e:
            print(f"Error initializing Firebase Admin SDK: {e}")
            print(f"Please ensure '{SERVICE_ACCOUNT_KEY_PATH}' is a valid path to your service account key.")
            exit(1) # Exit if Firebase can't be initialized

def get_firestore_db():
    """Returns a Firestore client instance."""
    if not firebase_admin._apps:
        initialize_firebase()
    return firestore.client()

# Call initialization on import to ensure it's ready
initialize_firebase()
