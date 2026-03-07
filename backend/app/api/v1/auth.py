from fastapi import APIRouter, HTTPException, status
from app.models.user import UserCreate, UserResponse 
from app.services.auth_service import AuthService

router = APIRouter()

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(user_in: UserCreate):
 
    result = AuthService.create_user(user_in)
    
    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=result["error"]
        )
    
    return result