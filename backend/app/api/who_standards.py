from fastapi import APIRouter, HTTPException
from firebase.config import get_db

router = APIRouter()

# ── Collection names ──────────────────────────────────────────────────────────

COLLECTIONS = {
    "weight": "whoWeightBoys",
    "height": "whoHeightBoys",
    "bmi":    "whoBMIBoys",
}


def _fetch_who_data(collection_name: str) -> list[dict]:
    """Fetch all WHO standard documents from a Firestore collection."""
    db = get_db()
    docs = db.collection(collection_name).order_by("month").stream()
    return [doc.to_dict() for doc in docs]


def _format_entry(entry: dict) -> dict:
    """Format a Firestore document into a clean API response."""
    return {
        "month":      int(entry.get("month", 0)),
        "sd_minus3":  float(entry.get("sd_minus3", 0)),
        "sd_minus2":  float(entry.get("sd_minus2", 0)),
        "sd_minus1":  float(entry.get("sd_minus1", 0)),
        "median":     float(entry.get("median", 0)),
        "sd_plus1":   float(entry.get("sd_plus1", 0)),
        "sd_plus2":   float(entry.get("sd_plus2", 0)),
        "sd_plus3":   float(entry.get("sd_plus3", 0)),
    }


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.get("/weight-for-age/boys")
async def get_weight_for_age_boys():
    """
    Get WHO Weight-for-Age standards for boys (0-24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        raw = _fetch_who_data(COLLECTIONS["weight"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail="WHO weight data not found. Run seed_who_data.py first."
            )
        return {
            "chart_type": "weight_for_age",
            "gender":     "male",
            "age_range":  "0-24 months",
            "unit":       "kg",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/height-for-age/boys")
async def get_height_for_age_boys():
    """
    Get WHO Height/Length-for-Age standards for boys (0-24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        raw = _fetch_who_data(COLLECTIONS["height"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail="WHO height data not found. Run seed_who_data.py first."
            )
        return {
            "chart_type": "height_for_age",
            "gender":     "male",
            "age_range":  "0-24 months",
            "unit":       "cm",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/bmi-for-age/boys")
async def get_bmi_for_age_boys():
    """
    Get WHO BMI-for-Age standards for boys (0-24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        raw = _fetch_who_data(COLLECTIONS["bmi"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail="WHO BMI data not found. Run seed_who_data.py first."
            )
        return {
            "chart_type": "bmi_for_age",
            "gender":     "male",
            "age_range":  "0-24 months",
            "unit":       "kg/m²",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/all/boys")
async def get_all_who_standards_boys():
    """
    Get all WHO standards for boys in one request.
    Flutter can call this once and cache all 3 chart datasets.
    """
    try:
        weight_raw = _fetch_who_data(COLLECTIONS["weight"])
        height_raw = _fetch_who_data(COLLECTIONS["height"])
        bmi_raw    = _fetch_who_data(COLLECTIONS["bmi"])

        if not weight_raw or not height_raw or not bmi_raw:
            raise HTTPException(
                status_code=404,
                detail="WHO data not found. Run seed_who_data.py first."
            )

        return {
            "gender":  "male",
            "source":  "WHO Child Growth Standards 2006",
            "weight":  [_format_entry(e) for e in weight_raw],
            "height":  [_format_entry(e) for e in height_raw],
            "bmi":     [_format_entry(e) for e in bmi_raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def who_data_status():
    """Check if WHO data has been seeded into Firestore."""
    try:
        db = get_db()
        results = {}
        for key, col in COLLECTIONS.items():
            count = len(list(db.collection(col).limit(25).stream()))
            results[key] = {"collection": col, "documents": count,
                            "ready": count == 25}
        all_ready = all(r["ready"] for r in results.values())
        return {
            "status":    "ready" if all_ready else "incomplete",
            "message":   "All WHO data loaded ✅" if all_ready
                         else "Run seed_who_data.py to populate WHO data",
            "details":   results,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))