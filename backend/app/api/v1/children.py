from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import firestore
from ...core.firebase_admin import verify_token
from ...models.child import ChildCreate, ChildResponse

router = APIRouter(prefix="/children", tags=["children"])
db = firestore.client()
security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> str:
    """Extract and verify Firebase token"""
    try:
        token = credentials.credentials 
        decoded = verify_token(token)
        return decoded['uid']
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid authentication")

@router.post("/", response_model=ChildResponse)
async def create_child(
    child: ChildCreate,
    user_id: str = Depends(get_current_user)
):
    """Create child profile (backup copy from Flutter app)"""
    if child.parent_id != user_id:
        raise HTTPException(status_code=403, detail="Not authorized")
    
    doc_ref = db.collection('children').document()
    child_data = child.model_dump()
    child_data['id'] = doc_ref.id
    child_data['created_at'] = firestore.SERVER_TIMESTAMP
    
    doc_ref.set(child_data)
    
    # Return a standard string for the time so Pydantic doesn't crash
    current_time = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    
    return ChildResponse(
        id=doc_ref.id,
        **child.model_dump(),
        created_at=current_time
    )

@router.get("/", response_model=list[ChildResponse])
async def list_children(user_id: str = Depends(get_current_user)):
    """Get all children for authenticated user"""
    docs = db.collection('children').where('parent_id', '==', user_id).stream()
    
    children = []
    for doc in docs:
        data = doc.to_dict()
        # Convert Firestore timestamp to string for Pydantic
        if 'created_at' in data and data['created_at']:
            data['created_at'] = str(data['created_at'])
        else:
            data['created_at'] = ""
            
        children.append(ChildResponse(**data))
    
    return children