from pydantic import BaseModel, Field
from typing import Optional


class ChildCreate(BaseModel):
    parent_id: str
    name: str = Field(..., min_length=1, max_length=100)
    birth_date: str          # ISO string "YYYY-MM-DD"
    gender: str = Field(..., pattern="^(Male|Female|Other|Boy|Girl)$")


class ChildUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    birth_date: Optional[str] = None
    gender: Optional[str] = Field(None, pattern="^(Male|Female|Other|Boy|Girl)$")


class ChildResponse(BaseModel):
    id: str
    parent_id: str
    name: str
    birth_date: str
    gender: str
    avatar_url: Optional[str] = None
    created_at: str

    class Config:
        populate_by_name = True


class ChildSummary(BaseModel):
    id: str
    name: str
    avatar_url: Optional[str] = None