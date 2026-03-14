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

