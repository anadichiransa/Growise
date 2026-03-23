from typing import List
from fastapi import APIRouter, status
from firebase_admin import firestore

from app.models.help_request import HelpRequestCreate, HelpRequestResponse
from app.schemas.help_request import HelpRequestUpdate
from app.services.help_service import (
    create_help_request,
    get_help_request_by_id,
    list_help_requests,
    update_help_request,
    delete_help_request,
)

router = APIRouter(prefix="/help", tags=["Help & Recovery"])


# Create help request
@router.post("/", response_model=HelpRequestResponse, status_code=status.HTTP_201_CREATED)
def create_help(data: HelpRequestCreate):
    db = firestore.client()
    return create_help_request(db, data.parent_id, data)


# List all help requests for a parent
@router.get("/", response_model=List[HelpRequestResponse])
def get_help_list(parent_id: str):
    db = firestore.client()
    return list_help_requests(db, parent_id)


# Get single help request
@router.get("/{request_id}", response_model=HelpRequestResponse)
def get_help(request_id: str, parent_id: str):
    db = firestore.client()
    return get_help_request_by_id(db, parent_id, request_id)


# Update help request
@router.put("/{request_id}", response_model=HelpRequestResponse)
def update_help(request_id: str, data: HelpRequestUpdate, parent_id: str):
    db = firestore.client()
    return update_help_request(db, parent_id, request_id, data)


# Delete help request
@router.delete("/{request_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_help(request_id: str, parent_id: str):
    db = firestore.client()
    delete_help_request(db, parent_id, request_id)