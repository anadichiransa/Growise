from typing import Optional
from pydantic import BaseModel


class HelpRequestUpdate(BaseModel):
    title: Optional[str] = None
    message: Optional[str] = None
    category: Optional[str] = None
    priority: Optional[str] = None
    status: Optional[str] = None