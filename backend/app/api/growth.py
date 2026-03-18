from fastapi import APIRouter, HTTPException, Query
from schemas.growth import (
    AddMeasurementRequest,
    UpdateMeasurementRequest,
    GrowthRecordResponse,
    GrowthListResponse,
)
import services.growth_service as svc

router = APIRouter()


@router.get("/records", response_model=GrowthListResponse)
async def get_records(child_id: str = Query(..., description="Child's unique ID")):
    """Get all growth records for a child — replaces loadRecords() in Flutter."""
    records_raw = await svc.get_records(child_id)
    records = []
    for r in records_raw:
        category = r.get("category", "healthy")
        weight_z = r.get("weightForAgeZ", 0.0)
        height_z = r.get("heightForAgeZ", 0.0)
        records.append(GrowthRecordResponse(
            id=r["id"],
            child_id=r.get("childId", ""),
            date=r.get("date"),
            weight=r.get("weight"),
            height=r.get("height"),
            bmi=r.get("bmi"),
            weight_for_age_z=weight_z,
            height_for_age_z=height_z,
            category=category,
            measured_at=r.get("measuredAt", "home"),
            notes=r.get("notes"),
            # Bug #8 fix: createdAt may be absent in older Firestore documents
            created_at=r.get("createdAt"),
            summary=svc.generate_summary(category, weight_z, height_z, "your child"),
            recommendations=svc.get_recommendations(category),
        ))
    return GrowthListResponse(child_id=child_id, records=records, total=len(records))


@router.post("/records", response_model=GrowthRecordResponse, status_code=201)
async def add_measurement(body: AddMeasurementRequest):
    """Save a new measurement — replaces addMeasurement() in Flutter."""
    try:
        record = await svc.add_measurement(
            child_id=body.child_id, gender=body.gender,
            date_of_birth=body.date_of_birth, date=body.date,
            weight=body.weight, height=body.height,
            measured_at=body.measured_at, notes=body.notes,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return GrowthRecordResponse(
        id=record["id"], child_id=record["childId"],
        date=record["date"], weight=record["weight"],
        height=record["height"], bmi=record.get("bmi"),
        weight_for_age_z=record.get("weightForAgeZ"),
        height_for_age_z=record.get("heightForAgeZ"),
        category=record.get("category"),
        measured_at=record.get("measuredAt", "home"),
        notes=record.get("notes"), created_at=record.get("createdAt"),
        summary=record.get("summary", ""),
        recommendations=record.get("recommendations", []),
    )


@router.put("/records/{record_id}", response_model=GrowthRecordResponse)
async def update_measurement(record_id: str, body: UpdateMeasurementRequest):
    """Update an existing measurement — replaces updateRecord() in Flutter."""
    try:
        record = await svc.update_measurement(
            record_id=record_id, child_id=body.child_id,
            gender=body.gender, date_of_birth=body.date_of_birth,
            date=body.date, weight=body.weight, height=body.height,
            measured_at=body.measured_at, notes=body.notes,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    return GrowthRecordResponse(
        id=record["id"], child_id=record["childId"],
        date=record["date"], weight=record["weight"],
        height=record["height"], bmi=record.get("bmi"),
        weight_for_age_z=record.get("weightForAgeZ"),
        height_for_age_z=record.get("heightForAgeZ"),
        category=record.get("category"),
        measured_at=record.get("measuredAt", "home"),
        notes=record.get("notes"), created_at=record.get("createdAt"),
        summary=record.get("summary", ""),
        recommendations=record.get("recommendations", []),
    )


@router.delete("/records/{record_id}", status_code=204)
async def delete_measurement(record_id: str):
    """Delete a record — replaces deleteRecord() in Flutter."""
    await svc.delete_measurement(record_id)
