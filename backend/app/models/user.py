from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    full_name: str = Field(..., min_length=2, max_length=20)
    email: EmailStr
    password: str = Field(..., min_length=8)
    phone_number: str = Field(..., pattern=r"^\+94\d{9}$")
    language_preference: str = "English"


class UserResponse(BaseModel):
    uid: str
    full_name: str
    email: EmailStr
    phone_number: str
    created_at : datetime

class UserInDB(UserResponse):
    hashed_password: str


