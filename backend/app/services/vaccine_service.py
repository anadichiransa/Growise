from datetime import datetime
from dateutil.relativedelta import relativedelta
from firebase_admin import firestore
from app.models.vaccine import VaccineStatus, SupplementType
from app.utils.helpers import add_months

db = firestore.client()

def generate_immunization_schedule(
    child_id: str, dob: datetime, gender: str, is_preterm: bool
) -> dict:
    today = datetime.utcnow()
    vaccines_ref = db.collection("vaccination_schedule").stream()
    vaccines = [v.to_dict() for v in vaccines_ref]
    batch = db.batch()

    for vaccine in vaccines:
        if vaccine.get("gender_restriction") and vaccine["gender_restriction"] != gender:
            continue

        scheduled_date = add_months(dob, vaccine["age_months"])
        days_diff = (today - scheduled_date).days
        status = VaccineStatus.OVERDUE.value if days_diff > 30 else VaccineStatus.PENDING.value

        record = {
            "vaccine_id": vaccine["vaccine_id"],
            "vaccine_name": vaccine["vaccine_name"],
            "age_label": vaccine["age_label"],
            "age_months": vaccine["age_months"],
            "diseases_prevented": vaccine["diseases_prevented"],
            "status": status,
            "scheduled_date": scheduled_date,
            "administered_date": None,
            "administered_by": None,
            "batch_number": None,
            "next_due_reminder_sent": False,
            "marked_by_parent": False,
            "is_booster": vaccine["is_booster"],
            "notes": vaccine.get("notes", ""),
            "created_at": today,
        }

        ref = (
            db.collection("children")
            .document(child_id)
            .collection("immunization_records")
            .document(vaccine["vaccine_id"])
        )
        batch.set(ref, record)

    batch.commit()
    return {"message": f"Schedule generated for child {child_id}"}
def generate_supplement_schedule(
    child_id: str, dob: datetime, is_preterm: bool
) -> dict:
    today = datetime.utcnow()
    batch = db.batch()
    records = []

    for month in range(6, 61, 6):
        records.append({
            "record_id": f"vitamin_a_{month}",
            "type": SupplementType.VITAMIN_A.value,
            "scheduled_date": add_months(dob, month),
            "status": "pending",
            "notes": f"Vitamin A Mega Dose — Month {month}",
        })

    for month in [6, 12, 18]:
        records.append({
            "record_id": f"mmn_{month}",
            "type": SupplementType.MMN.value,
            "scheduled_date": add_months(dob, month),
            "status": "pending",
            "notes": f"Micronutrient Supplement Packet — Month {month}",
        })

    for month in range(18, 61, 6):
        records.append({
            "record_id": f"worm_{month}",
            "type": SupplementType.WORM_TREATMENT.value,
            "scheduled_date": add_months(dob, month),
            "status": "pending",
            "notes": f"Worm Treatment — Month {month}",
        })

    if is_preterm:
        records.append({
            "record_id": "iron_daily_reminder",
            "type": SupplementType.IRON_DAILY.value,
            "scheduled_date": dob,
            "status": "pending",
            "notes": "Daily Iron & Vitamin — preterm until 24 months",
        })

    for record in records:
        ref = (
            db.collection("children")
            .document(child_id)
            .collection("supplement_records")
            .document(record["record_id"])
        )
        batch.set(ref, {**record, "created_at": today})

    batch.commit()
    return {"message": "Supplements scheduled", "count": len(records)}