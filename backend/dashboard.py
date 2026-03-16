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
