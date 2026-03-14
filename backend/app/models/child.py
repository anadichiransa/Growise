from pydantic import BaseModel
from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime


class ChildCreate(BaseModel):
    parent_id: str
    name: str = Field(..., min_length=1, max_length=100)
    birth_date: str                   # stored as ISO string "YYYY-MM-DD"
    gender: str = Field(..., pattern="^(Male|Female|Other)$")


class ChildUpdate(BaseModel):
    """All fields optional — only provided fields are updated (PATCH style)."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    birth_date: Optional[str] = None
    gender: Optional[str] = Field(None, pattern="^(Male|Female|Other)$")


class ChildResponse(BaseModel):
    id: str
    parent_id: str
    name: str
    birth_date: str
    gender: str
    avatar_url: Optional[str] = None
    last_weight_check: Optional[str] = None
    created_at: str

    class Config:
        populate_by_name = True


class ChildSummary(BaseModel):
    """Lightweight — used in Switch Profile row."""
    id: str
    name: str
    avatar_url: Optional[str] = None
    

