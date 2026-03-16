from datetime import datetime, timezone
from typing import List
from fastapi import HTTPException, UploadFile
from firebase_admin import firestore
from app.models.child import ChildCreate, ChildResponse, ChildSummary
from app.schemas.child import ChildUpdateRequest

COLLECTION = "children"


def create_child(db, parent_uid: str, data: ChildCreate) -> ChildResponse:
    if data.parent_id != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    doc_ref = db.collection(COLLECTION).document()
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    child_data = {
        "id": doc_ref.id,
        "parent_id": data.parent_id,
        "name": data.name,
        "birth_date": data.birth_date,
        "gender": data.gender,
        "avatar_url": None,
        "created_at": now,
    }

    doc_ref.set(child_data)
    return ChildResponse(**child_data)


def get_child_by_id(db, parent_uid: str, child_id: str) -> ChildResponse:
    doc = db.collection(COLLECTION).document(child_id).get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Child not found")

    data = doc.to_dict()

    if data["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    return _to_response(data)


def list_children(db, parent_uid: str) -> List[ChildSummary]:
    docs = (
        db.collection(COLLECTION)
        .where("parent_id", "==", parent_uid)
        .stream()
    )
    return [
        ChildSummary(
            id=d.to_dict()["id"],
            name=d.to_dict()["name"],
            avatar_url=d.to_dict().get("avatar_url"),
        )
        for d in docs
    ]


def update_child(
    db, parent_uid: str, child_id: str, data: ChildUpdateRequest
) -> ChildResponse:
    doc_ref = db.collection(COLLECTION).document(child_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Child not found")

    existing = doc.to_dict()

    if existing["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    updates = {k: v for k, v in data.model_dump().items() if v is not None}
    updates["updated_at"] = (
        datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    )

    doc_ref.update(updates)
    return _to_response({**existing, **updates})


def delete_child(db, parent_uid: str, child_id: str) -> None:
    doc_ref = db.collection(COLLECTION).document(child_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Child not found")

    if doc.to_dict()["parent_id"] != parent_uid:
        raise HTTPException(status_code=403, detail="Not authorized")

    doc_ref.delete()


def _to_response(data: dict) -> ChildResponse:
    created = data.get("created_at", "")
    if not isinstance(created, str):
        created = str(created)
    return ChildResponse(
        id=data["id"],
        parent_id=data["parent_id"],
        name=data["name"],
        birth_date=data["birth_date"],
        gender=data["gender"],
        avatar_url=data.get("avatar_url"),
        created_at=created,
    )