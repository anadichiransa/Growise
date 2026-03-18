from __future__ import annotations
from datetime import datetime
from typing import Optional
from firebase_admin import firestore
from firebase.config import get_db

COLLECTION = "growthRecords"

# ── WHO median tables (0–24 months) ──────────────────────────────────────────

_WHO_WEIGHT_MEDIAN_MALE = {
    0: 3.3,  1: 4.5,  2: 5.6,  3: 6.4,  4: 7.0,  5: 7.5,
    6: 7.9,  7: 8.3,  8: 8.6,  9: 8.9,  10: 9.2, 11: 9.4,
    12: 9.6, 13: 9.9, 14: 10.1,15: 10.3,16: 10.5,17: 10.7,
    18: 10.9,19: 11.1,20: 11.3,21: 11.5,22: 11.8,23: 12.0,24: 12.2,
}
_WHO_WEIGHT_MEDIAN_FEMALE = {
    0: 3.2,  1: 4.2,  2: 5.1,  3: 5.8,  4: 6.4,  5: 6.9,
    6: 7.3,  7: 7.6,  8: 7.9,  9: 8.2,  10: 8.5, 11: 8.7,
    12: 8.9, 13: 9.2, 14: 9.4, 15: 9.6, 16: 9.8, 17: 10.0,
    18: 10.2,19: 10.4,20: 10.6,21: 10.9,22: 11.1,23: 11.3,24: 11.5,
}
_WHO_HEIGHT_MEDIAN_MALE = {
    0: 49.9, 1: 54.7, 2: 58.4, 3: 61.4, 4: 63.9, 5: 65.9,
    6: 67.6, 7: 69.2, 8: 70.6, 9: 72.0, 10: 73.3,11: 74.5,
    12: 75.7,13: 76.9,14: 78.0,15: 79.1,16: 80.2,17: 81.2,
    18: 82.3,19: 83.2,20: 84.2,21: 85.1,22: 86.0,23: 86.9,24: 87.8,
}
_WHO_HEIGHT_MEDIAN_FEMALE = {
    0: 49.1, 1: 53.7, 2: 57.1, 3: 59.8, 4: 62.1, 5: 64.0,
    6: 65.7, 7: 67.3, 8: 68.7, 9: 70.1, 10: 71.5,11: 72.8,
    12: 74.0,13: 75.2,14: 76.4,15: 77.5,16: 78.6,17: 79.7,
    18: 80.7,19: 81.7,20: 82.7,21: 83.7,22: 84.6,23: 85.5,24: 86.4,
}
_WEIGHT_SD_RATIO = 0.13
_HEIGHT_SD_RATIO = 0.04


def _get_median(table: dict, age_months: int) -> float:
    return table.get(max(0, min(24, age_months)), table[24])


def calculate_age_months(birth_date: datetime, measure_date: datetime) -> int:
    months = (measure_date.year - birth_date.year) * 12
    months += measure_date.month - birth_date.month
    if measure_date.day < birth_date.day:
        months -= 1
    return max(0, months)


def calculate_bmi(weight_kg: float, height_cm: float) -> float:
    height_m = height_cm / 100
    return round(weight_kg / (height_m ** 2), 2)


def calculate_z_scores(weight: float, height: float,
                        age_months: int, gender: str):
    is_male = gender.lower() == "male"
    w_med = _get_median(
        _WHO_WEIGHT_MEDIAN_MALE if is_male else _WHO_WEIGHT_MEDIAN_FEMALE,
        age_months)
    h_med = _get_median(
        _WHO_HEIGHT_MEDIAN_MALE if is_male else _WHO_HEIGHT_MEDIAN_FEMALE,
        age_months)
    weight_z = round((weight - w_med) / (w_med * _WEIGHT_SD_RATIO), 2)
    height_z = round((height - h_med) / (h_med * _HEIGHT_SD_RATIO), 2)
    return weight_z, height_z


def categorise(weight_z: float, height_z: float) -> str:
    if height_z < -3: return "severe_stunting"
    if weight_z < -3: return "severe_wasting"
    if height_z < -2: return "stunting"
    if weight_z < -2: return "wasting"
    if weight_z >  2: return "overweight"
    return "healthy"


def generate_summary(category: str, weight_z: float,
                     height_z: float, child_name: str) -> str:
    match category:
        case "healthy":
            return f"Great news! {child_name}'s growth is healthy and within the normal WHO range."
        case "stunting":
            return f"{child_name}'s height is below expected (z-score: {height_z:.1f}). Please consult your PHM."
        case "severe_stunting":
            return f"⚠️ {child_name}'s height is significantly below expected. Please see a doctor immediately."
        case "wasting":
            return f"{child_name}'s weight is below expected (z-score: {weight_z:.1f}). Please consult your PHM."
        case "severe_wasting":
            return f"⚠️ {child_name}'s weight is significantly below expected. Please see a doctor immediately."
        case "overweight":
            return f"{child_name}'s weight is above the normal range. Focus on balanced meals."
        case _:
            return "Growth data recorded."


def get_recommendations(category: str) -> list[str]:
    match category:
        case "healthy":
            return [
                "Continue with the current feeding routine",
                "Maintain regular check-ups with your PHM",
                "Ensure balanced, nutritious meals",
            ]
        case "stunting" | "severe_stunting":
            return [
                "Consult your PHM or pediatrician within 48 hours",
                "Increase meal frequency to 5–6 times daily",
                "Focus on protein-rich foods (eggs, dhal, fish)",
                "Monitor growth weekly",
            ]
        case "wasting" | "severe_wasting":
            return [
                "Consult a doctor immediately",
                "Increase calorie intake with energy-dense foods",
                "Monitor weight every 3 days",
                "Rule out any underlying illness",
            ]
        case "overweight":
            return [
                "Reduce sugary drinks and snacks",
                "Increase age-appropriate physical activity",
                "Focus on whole foods — fruits and vegetables",
            ]
        case _:
            return []


# ── Firestore CRUD ────────────────────────────────────────────────────────────

def _doc_to_dict(doc) -> dict:
    d = doc.to_dict()
    d["id"] = doc.id
    return d


async def get_records(child_id: str) -> list[dict]:
    db = get_db()
    docs = (
        db.collection(COLLECTION)
        .where("childId", "==", child_id)
        .order_by("date", direction=firestore.Query.ASCENDING)
        .stream()
    )
    return [_doc_to_dict(d) for d in docs]


async def add_measurement(child_id: str, gender: str,
                           date_of_birth: datetime, date: datetime,
                           weight: float, height: float,
                           measured_at: str = "home",
                           notes: Optional[str] = None,
                           child_name: str = "your child") -> dict:
    age_months = calculate_age_months(date_of_birth, date)
    weight_z, height_z = calculate_z_scores(weight, height, age_months, gender)
    category = categorise(weight_z, height_z)

    record = {
        "childId":       child_id,
        "date":          date,
        "weight":        weight,
        "height":        height,
        "bmi":           calculate_bmi(weight, height),
        "weightForAgeZ": weight_z,
        "heightForAgeZ": height_z,
        "category":      category,
        "measuredAt":    measured_at,
        "notes":         notes,
        "createdAt":     datetime.utcnow(),
    }
    db  = get_db()
    ref = db.collection(COLLECTION).document()
    ref.set(record)
    record["id"]              = ref.id
    record["summary"]         = generate_summary(category, weight_z, height_z, child_name)
    record["recommendations"] = get_recommendations(category)
    return record


async def update_measurement(record_id: str, child_id: str, gender: str,
                              date_of_birth: datetime, date: datetime,
                              weight: float, height: float,
                              measured_at: str = "home",
                              notes: Optional[str] = None,
                              child_name: str = "your child") -> dict:
    age_months = calculate_age_months(date_of_birth, date)
    weight_z, height_z = calculate_z_scores(weight, height, age_months, gender)
    category = categorise(weight_z, height_z)

    update_data = {
        "date":          date,
        "weight":        weight,
        "height":        height,
        "bmi":           calculate_bmi(weight, height),
        "weightForAgeZ": weight_z,
        "heightForAgeZ": height_z,
        "category":      category,
        "measuredAt":    measured_at,
        "notes":         notes,
        "updatedAt":     datetime.utcnow(),
    }
    get_db().collection(COLLECTION).document(record_id).update(update_data)
    update_data["id"]              = record_id
    update_data["childId"]         = child_id
    update_data["summary"]         = generate_summary(category, weight_z, height_z, child_name)
    update_data["recommendations"] = get_recommendations(category)
    return update_data


async def delete_measurement(record_id: str) -> bool:
    get_db().collection(COLLECTION).document(record_id).delete()
    return True
