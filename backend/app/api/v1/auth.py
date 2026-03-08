from fastapi import APIRouter, HTTPException, status
from app.models.user import UserCreate, UserResponse, UserLogin
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

@router.post("/login", response_model=UserResponse)
async def login(user_in: UserLogin):
    result = AuthService.login_user(user_in.email, user_in.password)
    
    if "error" in result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=result["error"]
        )
    
    return result