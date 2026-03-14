from fastapi import APIRouter, HTTPException
from app.services.vaccine_service import (
    generate_immunization_schedule,
    generate_supplement_schedule,
    get_vaccine_schedule,
    mark_completed,
    schedule_reminders,
)
from app.models.vaccine import MarkVaccineDoneRequest

router = APIRouter(prefix="/vaccines", tags=["Vaccines"])


@router.post("/schedule/{child_id}/generate")
async def generate_schedule(child_id: str):
    """Generate full immunization + supplement schedule after child profile creation."""
    from firebase_admin import firestore
    db = firestore.client()

    child_doc = db.collection("children").document(child_id).get()
    if not child_doc.exists:
        raise HTTPException(status_code=404, detail="Child not found")

    child = child_doc.to_dict()
    imm = generate_immunization_schedule(
        child_id, child["dob"], child["gender"], child.get("is_preterm", False)
    )
    supp = generate_supplement_schedule(
        child_id, child["dob"], child.get("is_preterm", False)
    )
    return {"immunization": imm, "supplements": supp}

@router.get("/schedule/{child_id}")
async def get_schedule(child_id: str):
    """Get grouped immunization schedule for a child."""
    return get_vaccine_schedule(child_id)
@router.patch("/schedule/{child_id}/{vaccine_id}/mark-done")
async def mark_vaccine_done(
    child_id: str,
    vaccine_id: str,
    body: MarkVaccineDoneRequest
):
    """Mark a specific vaccine as administered."""
    result = mark_completed(child_id, vaccine_id, body.dict())
    if not result:
        raise HTTPException(status_code=404, detail="Vaccine record not found")
    return result
@router.get("/supplements/{child_id}")
async def get_supplements(child_id: str):
    """Get supplement schedule for a child."""
    from firebase_admin import firestore
    from datetime import datetime
    db = firestore.client()
    today = datetime.utcnow()

    records = (
        db.collection("children")
        .document(child_id)
        .collection("supplement_records")
        .order_by("scheduled_date")
        .stream()
    )
    result = []
    for doc in records:
        r = doc.to_dict()
        r["days_until_due"] = (r["scheduled_date"] - today).days
        result.append(r)
    return {"supplements": result}