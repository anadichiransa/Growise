from __future__ import annotations
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, validator


class AddMeasurementRequest(BaseModel):
    child_id: str
    gender: str
    date_of_birth: datetime
    date: datetime
    weight: float = Field(..., gt=0, le=30,  description="Weight in kg")
    height: float = Field(..., gt=0, le=150, description="Height in cm")
    measured_at: str = "home"   # 'home' or 'clinic'
    notes: Optional[str] = None

    @validator("gender")
    def gender_valid(cls, v):
        if v not in ("male", "female"):
            raise ValueError("gender must be 'male' or 'female'")
        return v

    @validator("measured_at")
    def location_valid(cls, v):
        if v not in ("home", "clinic"):
            raise ValueError("measured_at must be 'home' or 'clinic'")
        return v


class UpdateMeasurementRequest(AddMeasurementRequest):
    record_id: str


class GrowthRecordResponse(BaseModel):
    id: str
    child_id: str
    date: datetime
    weight: float
    height: float
    bmi: Optional[float]
    weight_for_age_z: Optional[float]
    height_for_age_z: Optional[float]
    category: Optional[str]
    measured_at: str
    notes: Optional[str]
    created_at: datetime
    summary: str
    recommendations: list[str]


class GrowthListResponse(BaseModel):
    child_id: str
    records: list[GrowthRecordResponse]
    total: int
