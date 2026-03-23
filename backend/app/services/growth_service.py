from datetime import datetime, timezone
from typing import List
from fastapi import HTTPException

from app.models.growth import GrowthRecordCreate, GrowthRecordResponse

COLLECTION = "growthRecords"


def create_growth_record(db, data: GrowthRecordCreate) -> GrowthRecordResponse:
    doc_ref = db.collection(COLLECTION).document()

    created_at = data.created_at or datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    record = {
        "id": doc_ref.id,
        "child_id": data.child_id,
        "user_id": data.user_id,
        "date": data.date,
        "weight": data.weight,
        "height": data.height,
        "bmi": data.bmi,
        "weight_for_age_z": data.weight_for_age_z,
        "height_for_age_z": data.height_for_age_z,
        "category": data.category,
        "recommendations": data.recommendations,
        "notes": data.notes,
        "created_at": created_at,
        "is_synced_to_backend": True,
    }

    doc_ref.set(record)
    return GrowthRecordResponse(**record)


def list_growth_records(db, child_id: str) -> List[GrowthRecordResponse]:
    docs = (
        db.collection(COLLECTION)
        .where("child_id", "==", child_id)
        .stream()
    )

    items = [GrowthRecordResponse(**_normalize_doc(d.to_dict())) for d in docs]
    items.sort(key=lambda x: x.date, reverse=True)
    return items


def delete_growth_record(db, record_id: str) -> None:
    doc_ref = db.collection(COLLECTION).document(record_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Growth record not found")

    doc_ref.delete()


def _normalize_doc(data: dict) -> dict:
    return {
        "id": data["id"],
        "child_id": data["child_id"],
        "user_id": data["user_id"],
        "date": str(data["date"]),
        "weight": data["weight"],
        "height": data["height"],
        "bmi": data.get("bmi"),
        "weight_for_age_z": data.get("weight_for_age_z"),
        "height_for_age_z": data.get("height_for_age_z"),
        "category": data.get("category"),
        "recommendations": data.get("recommendations", []),
        "notes": data.get("notes"),
        "created_at": str(data.get("created_at", "")),
        "is_synced_to_backend": data.get("is_synced_to_backend", True),
    }