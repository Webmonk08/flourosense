from pydantic import BaseModel

class UserCreate(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: str
    email: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: str | None = None
