from pydantic import BaseModel
from datetime import datetime

class ChildCreate(BaseModel):
    name: str
    birth_date: str  # ISO 8601 format
    gender: str
    parent_id: str

class ChildResponse(BaseModel):
    id: str
    name: str
    birth_date: str
    gender: str
    parent_id: str
    created_at: str