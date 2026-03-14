from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from ...core.database import get_firestore_db
from ...core.dependencies import get_current_user

router = APIRouter()

class GrowthRecordSync(BaseModel):
    """
    Schema for incoming growth records from Flutter.
    Note: Flutter handles the Z-score logic; we just back it up.
    """
    child_id: str
    user_id: str
    date: datetime
    weight: float
    height: float
    bmi: Optional[float] = None
    weight_for_age_z: Optional[float] = None
    height_for_age_z: Optional[float] = None
    category: Optional[str] = None
    recommendations: List[str] = []
    notes: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

@router.post("/records")
async def sync_growth_record(
    record: GrowthRecordSync,
    current_user=Depends(get_current_user),
    db=Depends(get_firestore_db),
):
    """
    Endpoint to receive and store growth data.
    """
    try:
        doc_data = record.dict()
        doc_data['synced_at'] = datetime.utcnow()
        doc_data['source'] = 'flutter_sync'

        # Store in the backup collection
        db.collection('growthRecordsBackup').add(doc_data)
        return {"status": "synced", "message": "Record backed up successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/records/{child_id}")
async def get_growth_records(
    child_id: str,
    current_user=Depends(get_current_user),
    db=Depends(get_firestore_db),
):
    """
    Retrieves all records for a specific child.
    Useful for cross-platform syncing or web views.
    """
    docs = (
        db.collection('growthRecordsBackup')
        .where('child_id', '==', child_id)
        .where('user_id', '==', current_user.get("uid")) # Adjust based on your user object
        .order_by('date', direction='DESCENDING')
        .stream()
    )
    return [{'id': doc.id, **doc.to_dict()} for doc in docs]
