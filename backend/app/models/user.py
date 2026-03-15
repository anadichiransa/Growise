from pydantic import BaseModel, EmailStr, Field
from typing import Optional

class UserCreate(BaseModel):
    uid: str                          # Firebase Auth UID from Flutter
    full_name: str = Field(..., min_length=2, max_length=50)
    email: EmailStr
    phone_number: str = Field(..., pattern=r"^\+94\d{9}$")
    language_preference: str = "English"

class UserProfile(BaseModel):
    uid: str
    full_name: str
    email: str
    phone_number: str
    language_preference: str
    created_at: str

class UserResponse(BaseModel):
    uid: str
    full_name: str
    email: str
    message: str = "Profile saved successfully"