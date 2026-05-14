from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List, Dict, Any

# Pydantic model for user data
class User(BaseModel):
    id: Optional[str] = None
    email: str
    hashed_password: Optional[str] = None
    name: Optional[str] = None
    age: Optional[str] = None
    gender: Optional[str] = None
    water_source: Optional[str] = None
    toothpaste_type: Optional[str] = None
    user_type: Optional[str] = None # 'general' or 'maternal'

# Pydantic model for report data
class ReportBase(BaseModel):
    name: str
    age: str
    gender: str
    water_source: str
    toothpaste_type: str
    milk_intake: Optional[str] = None
    sugar_levels: Optional[str] = None
    toothpaste_swallowing: Optional[str] = None
    classification: str
    confidence: float
    image_url: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    user_id: str

class ReportCreate(ReportBase):
    pass # No extra fields for creation

class ReportInDB(ReportBase):
    id: str = Field(alias="id") # Document ID from Firestore

    class Config:
        allow_population_by_field_name = True
        json_encoders = {
            datetime: lambda dt: dt.isoformat() + "Z",
        }

# Pydantic model for classification result (returned to Flutter)
class ClassificationResult(BaseModel):
    classification: str
    confidence: float