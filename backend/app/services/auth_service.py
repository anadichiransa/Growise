from passlib.context import CryptContext
from app.core.database import db
from app.models.user import UserCreate
from datetime import datetime
import uuid

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class AuthService:
    @staticmethod
    def hash_password(password: str):
        return pwd_context.hash(password)
    
    def create_user(user_data: UserCreate):

        #Checking whether the user exists

        user_ref = db.collection("users").where("email", "==", user_data.email).get()
        if len(user_ref) > 0:
            return {"error" : "Email already registered"}
        
        #Generate a unique ID and Hash the password

        user_id = str(uuid.uuid4())
        hashed_pwd = AuthService.hash_password(user_data.password)

        






        
