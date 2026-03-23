from datetime import datetime, timezone
from typing import List
from fastapi import HTTPException

from app.models.help_request import HelpRequestCreate, HelpRequestResponse
from app.schemas.help_request import HelpRequestUpdate

COLLECTION = "help_requests"


def create_help_request(db, parent_uid: str, data: HelpRequestCreate) -> HelpRequestResponse:
    if data.parent_id != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    doc_ref = db.collection(COLLECTION).document()
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    help_data = data.model_dump()
    help_data["id"] = doc_ref.id
    help_data["status"] = "open"
    help_data["created_at"] = now
    help_data["updated_at"] = None

    doc_ref.set(help_data)

    return HelpRequestResponse(**help_data)


def get_help_request_by_id(db, parent_uid: str, request_id: str) -> HelpRequestResponse:
    doc = db.collection(COLLECTION).document(request_id).get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Help request not found")

    data = doc.to_dict()

    if data["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    return _to_response(data)


def list_help_requests(db, parent_uid: str) -> List[HelpRequestResponse]:
    docs = db.collection(COLLECTION).where("parent_id", "==", parent_uid).stream()
    items = [HelpRequestResponse(**_normalize_doc(d.to_dict())) for d in docs]
    items.sort(key=lambda x: x.created_at, reverse=True)
    return items


def update_help_request(
    db, parent_uid: str, request_id: str, data: HelpRequestUpdate
) -> HelpRequestResponse:
    doc_ref = db.collection(COLLECTION).document(request_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Help request not found")

    existing = doc.to_dict()

    if existing["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    updates = {k: v for k, v in data.model_dump().items() if v is not None}
    updates["updated_at"] = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    doc_ref.update(updates)

    return _to_response({**existing, **updates})


def delete_help_request(db, parent_uid: str, request_id: str) -> None:
    doc_ref = db.collection(COLLECTION).document(request_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Help request not found")

    existing = doc.to_dict()

    if existing["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    doc_ref.delete()


def _normalize_doc(data: dict) -> dict:
    created = data.get("created_at", "")
    updated = data.get("updated_at")

    if not isinstance(created, str):
        created = str(created)

    if updated is not None and not isinstance(updated, str):
        updated = str(updated)

    return {
        "id": data["id"],
        "parent_id": data["parent_id"],
        "child_id": data.get("child_id"),
        "title": data["title"],
        "message": data["message"],
        "category": data["category"],
        "priority": data.get("priority", "normal"),
        "status": data.get("status", "open"),
        "created_at": created,
        "updated_at": updated,
    }


def _to_response(data: dict) -> HelpRequestResponse:
    return HelpRequestResponse(**_normalize_doc(data))