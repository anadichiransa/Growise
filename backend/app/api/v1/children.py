from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import datetime, timezone
from firebase_admin import firestore

from ...core.firebase_admin import verify_token
from ...models.child import ChildCreate, ChildResponse
from ...schemas.child import (
    ChildUpdateRequest,
    ChildUpdateResponse,
    ChildGetResponse,
    AvatarUploadResponse,
)
from ...services import child_service

router = APIRouter(prefix="/children", tags=["children"])
db = firestore.client()
security = HTTPBearer()


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    """Extract and verify Firebase token — unchanged from original."""
    try:
        token = credentials.credentials
        decoded = verify_token(token)
        return decoded["uid"]
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid authentication")


# ── ORIGINAL endpoints (kept exactly as written by teammate) ─────────────────

@router.post("/", response_model=ChildResponse, status_code=201)
async def create_child(
    child: ChildCreate,
    user_id: str = Depends(get_current_user),
):
    """Create child profile (backup copy from Flutter app)."""
    if child.parent_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")

    doc_ref = db.collection("children").document()
    child_data = child.model_dump()
    child_data["id"] = doc_ref.id
    child_data["created_at"] = firestore.SERVER_TIMESTAMP

    doc_ref.set(child_data)

    current_time = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    return ChildResponse(
        id=doc_ref.id,
        **child.model_dump(),
        created_at=current_time,
    )


@router.get("/", response_model=list[ChildResponse])
async def list_children(user_id: str = Depends(get_current_user)):
    """Get all children for authenticated user."""
    docs = db.collection("children").where("parent_id", "==", user_id).stream()

    children = []
    for doc in docs:
        data = doc.to_dict()
        if "created_at" in data and data["created_at"]:
            data["created_at"] = str(data["created_at"])
        else:
            data["created_at"] = ""
        children.append(ChildResponse(**data))

    return children


# ── NEW endpoints (added for profile screen) ──────────────────────────────────

@router.get("/{child_id}", response_model=ChildGetResponse)
async def get_child(
    child_id: str,
    user_id: str = Depends(get_current_user),
):
    """Fetch full profile for one child — called when profile screen opens."""
    child = child_service.get_child_by_id(db=db, parent_uid=user_id, child_id=child_id)
    return ChildGetResponse(child=child)


@router.put("/{child_id}", response_model=ChildUpdateResponse)
async def update_child(
    child_id: str,
    body: ChildUpdateRequest,
    user_id: str = Depends(get_current_user),
):
    """Update name, birthdate, gender — called by Save Changes button."""
    child = child_service.update_child(
        db=db, parent_uid=user_id, child_id=child_id, data=body
    )
    return ChildUpdateResponse(child=child)


@router.post("/{child_id}/avatar", response_model=AvatarUploadResponse)
async def upload_avatar(
    child_id: str,
    file: UploadFile = File(...),
    user_id: str = Depends(get_current_user),
):
    """Upload avatar image — called when user taps the camera icon."""
    avatar_url = await child_service.update_avatar(
        db=db, parent_uid=user_id, child_id=child_id, file=file
    )
    return AvatarUploadResponse(avatar_url=avatar_url)


@router.delete("/{child_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_child(
    child_id: str,
    user_id: str = Depends(get_current_user),
):
    """Delete a child profile."""
    child_service.delete_child(db=db, parent_uid=user_id, child_id=child_id)