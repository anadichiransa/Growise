from fastapi import APIRouter, status
from firebase_admin import firestore

from ...models.growth import GrowthRecordCreate, GrowthRecordResponse
from ...services.growth_service import (
    create_growth_record,
    list_growth_records,
    delete_growth_record,
)

router = APIRouter(prefix="/growth", tags=["growth"])
db = firestore.client()


@router.post("/records", response_model=GrowthRecordResponse, status_code=status.HTTP_201_CREATED)
async def create_record(body: GrowthRecordCreate):
    return create_growth_record(db, body)


@router.get("/records/{child_id}", response_model=list[GrowthRecordResponse])
async def get_records(child_id: str):
    return list_growth_records(db, child_id)


@router.delete("/records/{record_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_record(record_id: str):
    delete_growth_record(db, record_id)