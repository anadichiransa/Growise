from pydantic import BaseModel, Field
from typing import Optional, List
from app.models.child import ChildResponse, ChildSummary


class ChildUpdateRequest(BaseModel):
    full_name: Optional[str] = Field(None, min_length=1, max_length=100)
    birthdate: Optional[str] = None
    gender: Optional[str] = Field(None, pattern="^(Male|Female|Other)$")


class ChildUpdateResponse(BaseModel):
    message: str = "Child profile updated successfully"
    child: ChildResponse


class ChildGetResponse(BaseModel):
    child: ChildResponse


class ChildListResponse(BaseModel):
    children: List[ChildSummary]
    total: int


class AvatarUploadResponse(BaseModel):
    message: str = "Avatar updated successfully"
    avatar_url: str