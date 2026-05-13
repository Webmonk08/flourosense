from pydantic import BaseModel

from typing import Optional

class UserCreate(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: str
    email: str
    name: Optional[str] = None
    age: Optional[str] = None
    gender: Optional[str] = None
    water_source: Optional[str] = None
    toothpaste_type: Optional[str] = None
    user_type: Optional[str] = None

class UserUpdate(BaseModel):
    email: Optional[str] = None
    password: Optional[str] = None
    name: Optional[str] = None
    age: Optional[str] = None
    gender: Optional[str] = None
    water_source: Optional[str] = None
    toothpaste_type: Optional[str] = None
    user_type: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: str | None = None
