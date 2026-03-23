from datetime import datetime
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
def get_vaccine_schedule(child_id: str) -> dict:
    today = datetime.utcnow()
    records_ref = (
        db.collection("children")
        .document(child_id)
        .collection("immunization_records")
        .order_by("age_months")
        .stream()
    )

    grouped = {}
    for doc in records_ref:
        r = doc.to_dict()
        scheduled = r["scheduled_date"]
        days_until = (scheduled - today).days
        r["days_until_due"] = days_until

        if r["status"] == "pending" and days_until < -7:
            r["status"] = VaccineStatus.OVERDUE.value

        label = r["age_label"]
        if label not in grouped:
            grouped[label] = {
                "age_label": label,
                "age_months": r["age_months"],
                "vaccines": [],
                "all_done": False,
            }
        grouped[label]["vaccines"].append(r)

    for group in grouped.values():
        group["all_done"] = all(v["status"] == "done" for v in group["vaccines"])

    return {"schedule": list(grouped.values())}
def mark_completed(child_id: str, vaccine_id: str, data: dict) -> dict:
    ref = (
        db.collection("children")
        .document(child_id)
        .collection("immunization_records")
        .document(vaccine_id)
    )
    if not ref.get().exists:
        return None

    ref.update({
        "status": VaccineStatus.DONE.value,
        "administered_date": data["administered_date"],
        "administered_by": data["administered_by"],
        "batch_number": data.get("batch_number"),
        "notes": data.get("notes", ""),
        "marked_by_parent": True,
        "updated_at": datetime.utcnow(),
    })
    return {"message": f"{vaccine_id} marked as done"}
def schedule_reminders(parent_uid: str) -> dict:
    today = datetime.utcnow()
    notifications = []

    children = (
        db.collection("children")
        .where("parent_uid", "==", parent_uid)
        .stream()
    )

    for child_doc in children:
        child = child_doc.to_dict()
        child_id = child_doc.id
        child_name = child.get("name", "Your child")

        records = (
            db.collection("children")
            .document(child_id)
            .collection("immunization_records")
            .where("status", "in", ["pending", "overdue"])
            .stream()
        )

        for rec in records:
            r = rec.to_dict()
            days_until = (r["scheduled_date"] - today).days

            if days_until <= 7:
                if days_until < 0:
                    urgency = "overdue"
                elif days_until == 0:
                    urgency = "today"
                elif days_until == 1:
                    urgency = "tomorrow"
                else:
                    urgency = "this_week"

                notifications.append({
                    "child_id": child_id,
                    "child_name": child_name,
                    "vaccine_id": r["vaccine_id"],
                    "vaccine_name": r["vaccine_name"],
                    "scheduled_date": r["scheduled_date"].isoformat(),
                    "urgency": urgency,
                    "days_until_due": days_until,
                    "show_on_home": urgency in ["today", "tomorrow", "overdue"],
                    "show_on_notifications": True,
                })

    notifications.sort(key=lambda x: x["days_until_due"])
    return {"notifications": notifications}