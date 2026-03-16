import logging
from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.firebase.client import get_firestore_client
from app.middleware.auth import get_current_user_uid
from app.schemas.dashboard import (
    ChildCreate,
    ChildResponse,
    GrowthRecordCreate,
    GrowthRecordResponse,
    GrowthHistoryResponse,
    DashboardSummary,
    MessageResponse,
)
from app.services import dashboard_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])
# ── Health check ──────────────────────────────────────────────────────────────
@router.get(
    "/health",
    # ── Dashboard summary ─────────────────────────────────────────────────────────
@router.get(
    "/summary",
    response_model=DashboardSummary,
    summary="Get dashboard summary",
    description=(
        "All data for the Quick Overview card: child name, age in months, "
        "latest growth measurement, and next vaccine. Requires Firebase ID token."
    ),
)
async def get_summary(
    parent_uid: str = Depends(get_current_user_uid),
    db=Depends(get_firestore_client),
):
    """
    Main dashboard data endpoint.
    Called on app startup and pull-to-refresh.
    Returns safe defaults when no child is registered — never throws.
    """
    try:
        return dashboard_service.get_dashboard_summary(db, parent_uid)
    except Exception as exc:
        logger.error("get_summary failed uid=%s: %s", parent_uid, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not load dashboard summary.",
        )


    response_model=MessageResponse,
    summary="Dashboard health check",
    description="No auth required. Used by uptime monitors.",
)
async def health_check():
    return MessageResponse(message="Dashboard service is healthy")
