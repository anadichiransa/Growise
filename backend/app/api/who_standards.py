from fastapi import APIRouter, HTTPException, Path
from firebase.config import get_db

router = APIRouter()

# ── Collection names ──────────────────────────────────────────────────────────

COLLECTIONS_BOYS = {
    "weight": "whoWeightBoys",
    "height": "whoHeightBoys",
    "bmi":    "whoBMIBoys",
}

COLLECTIONS_GIRLS = {
    "weight": "whoWeightGirls",
    "height": "whoHeightGirls",
    "bmi":    "whoBMIGirls",
}


def _get_collections(gender: str) -> dict:
    """Return the correct collection map for the given gender string."""
    if gender.lower() in ("female", "girl", "girls"):
        return COLLECTIONS_GIRLS
    return COLLECTIONS_BOYS  # default to boys for 'male' / 'boy' / 'boys'


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


# ── Gender-aware endpoints (Bug #5 fix) ───────────────────────────────────────

@router.get("/all/{gender}")
async def get_all_who_standards(
    gender: str = Path(..., description="'boys' or 'girls'"),
):
    """
    Get all WHO standards for boys or girls in one request.
    Flutter can call this once and cache all 3 chart datasets.
      • /who/all/boys
      • /who/all/girls
    """
    try:
        cols       = _get_collections(gender)
        weight_raw = _fetch_who_data(cols["weight"])
        height_raw = _fetch_who_data(cols["height"])
        bmi_raw    = _fetch_who_data(cols["bmi"])

        if not weight_raw or not height_raw or not bmi_raw:
            raise HTTPException(
                status_code=404,
                detail=f"WHO data not found for gender='{gender}'. "
                       "Run seed_who_data.py first.",
            )

        return {
            "gender":  gender,
            "source":  "WHO Child Growth Standards 2006",
            "weight":  [_format_entry(e) for e in weight_raw],
            "height":  [_format_entry(e) for e in height_raw],
            "bmi":     [_format_entry(e) for e in bmi_raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/weight-for-age/{gender}")
async def get_weight_for_age(
    gender: str = Path(..., description="'boys' or 'girls'"),
):
    """
    Get WHO Weight-for-Age standards for boys or girls (0–24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        cols = _get_collections(gender)
        raw  = _fetch_who_data(cols["weight"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail=f"WHO weight data not found for gender='{gender}'. "
                       "Run seed_who_data.py first.",
            )
        return {
            "chart_type": "weight_for_age",
            "gender":     gender,
            "age_range":  "0-24 months",
            "unit":       "kg",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/height-for-age/{gender}")
async def get_height_for_age(
    gender: str = Path(..., description="'boys' or 'girls'"),
):
    """
    Get WHO Height/Length-for-Age standards for boys or girls (0–24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        cols = _get_collections(gender)
        raw  = _fetch_who_data(cols["height"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail=f"WHO height data not found for gender='{gender}'. "
                       "Run seed_who_data.py first.",
            )
        return {
            "chart_type": "height_for_age",
            "gender":     gender,
            "age_range":  "0-24 months",
            "unit":       "cm",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/bmi-for-age/{gender}")
async def get_bmi_for_age(
    gender: str = Path(..., description="'boys' or 'girls'"),
):
    """
    Get WHO BMI-for-Age standards for boys or girls (0–24 months).
    Returns 25 data points with SD lines for chart rendering.
    """
    try:
        cols = _get_collections(gender)
        raw  = _fetch_who_data(cols["bmi"])
        if not raw:
            raise HTTPException(
                status_code=404,
                detail=f"WHO BMI data not found for gender='{gender}'. "
                       "Run seed_who_data.py first.",
            )
        return {
            "chart_type": "bmi_for_age",
            "gender":     gender,
            "age_range":  "0-24 months",
            "unit":       "kg/m²",
            "source":     "WHO Child Growth Standards 2006",
            "data":       [_format_entry(e) for e in raw],
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# ── Status check ──────────────────────────────────────────────────────────────

@router.get("/status")
async def who_data_status():
    """Check if WHO data has been seeded into Firestore (boys and girls)."""
    try:
        db = get_db()
        results = {}
        all_cols = {
            **{f"boys_{k}": v for k, v in COLLECTIONS_BOYS.items()},
            **{f"girls_{k}": v for k, v in COLLECTIONS_GIRLS.items()},
        }
        for key, col in all_cols.items():
            count = len(list(db.collection(col).limit(25).stream()))
            results[key] = {"collection": col, "documents": count,
                            "ready": count == 25}
        boys_ready  = all(results[f"boys_{k}"]["ready"]  for k in COLLECTIONS_BOYS)
        girls_ready = all(results[f"girls_{k}"]["ready"] for k in COLLECTIONS_GIRLS)
        all_ready = boys_ready and girls_ready
        return {
            "status":      "ready" if all_ready else "incomplete",
            "boys_ready":  boys_ready,
            "girls_ready": girls_ready,
            "message":     "All WHO data loaded ✅" if all_ready
                           else "Run seed_who_data.py to populate WHO data",
            "details":     results,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))