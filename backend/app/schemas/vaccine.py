
from pydantic import BaseModel
from typing import List


class VaccineScheduleResponse(BaseModel):
    schedule: List[dict]


class SupplementScheduleResponse(BaseModel):
    supplements: List[dict]


class MarkDoneResponse(BaseModel):
    message: str


class GenerateScheduleResponse(BaseModel):
    immunization: dict
    supplements: dict


class NotificationListResponse(BaseModel):
    notifications: List[dict]