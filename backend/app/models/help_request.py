from typing import Optional
from pydantic import BaseModel


class HelpRequestCreate(BaseModel):
    parent_id: str
    child_id: Optional[str] = None
    title: str
    message: str
    category: str
    priority: str = "normal"


class HelpRequestResponse(BaseModel):
    id: str
    parent_id: str
    child_id: Optional[str] = None
    title: str
    message: str
    category: str
    priority: str
    status: str
    created_at: str
    updated_at: Optional[str] = None