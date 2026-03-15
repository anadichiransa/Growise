from fastapi import APIRouter, HTTPException, status
from app.models.user import UserCreate, UserResponse
from app.services.auth_service import AuthService

router = APIRouter()

@router.post("/profile", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def save_profile(user_in: UserCreate):
    """
    Called from Flutter after Firebase Auth signup succeeds.
    Saves user profile data to Firestore.
    """
    result = AuthService.save_user_profile(user_in.uid, user_in)
    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=result["error"]
        )
    return {"uid": result["uid"], "full_name": result["full_name"],
            "email": result["email"]}

@router.get("/profile/{uid}", response_model=UserResponse)
async def get_profile(uid: str):
    """Get user profile from Firestore."""
    result = AuthService.get_user_profile(uid)
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result