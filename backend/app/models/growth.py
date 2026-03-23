from pydantic import BaseModel
from typing import Optional, List


class GrowthRecordCreate(BaseModel):
    child_id: str
    user_id: str
    date: str
    weight: float
    height: float
    bmi: Optional[float] = None
    weight_for_age_z: Optional[float] = None
    height_for_age_z: Optional[float] = None
    category: Optional[str] = None
    recommendations: List[str] = []
    notes: Optional[str] = None
    created_at: Optional[str] = None


class GrowthRecordResponse(BaseModel):
    id: str
    child_id: str
    user_id: str
    date: str
    weight: float
    height: float
    bmi: Optional[float] = None
    weight_for_age_z: Optional[float] = None
    height_for_age_z: Optional[float] = None
    category: Optional[str] = None
    recommendations: List[str] = []
    notes: Optional[str] = None
    created_at: str
    is_synced_to_backend: bool = True