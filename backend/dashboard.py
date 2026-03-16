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
# ── Child profile ─────────────────────────────────────────────────────────────
@router.post(
    "/child",
    response_model=ChildResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a child",
    description="Creates a new child profile linked to the authenticated parent.",
)
async def create_child(
    payload: ChildCreate,
    parent_uid: str = Depends(get_current_user_uid),
    db=Depends(get_firestore_client),
):
    try:
        return dashboard_service.create_child(db, parent_uid, payload)
    except Exception as exc:
        logger.error("create_child failed uid=%s: %s", parent_uid, exc)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Could not create child profile.",
        )


@router.get(
    "/child/{child_id}",
    response_model=ChildResponse,
    summary="Get child profile",
    description="Returns the full profile for a specific child. Parent must own the record.",
)
async def get_child(
    child_id: str,
    parent_uid: str = Depends(get_current_user_uid),
    db=Depends(get_firestore_client),
):
    """
    Returns 404 if child doesn't exist or doesn't belong to this parent.
    Ownership check prevents one parent reading another's data.
    """
    child = dashboard_service.get_child_profile(db, child_id, parent_uid)
    if child is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Child '{child_id}' not found.",
        )
    return child

