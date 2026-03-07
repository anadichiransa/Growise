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

        #Prepare data for firestore
        
        user_dict = {
            "uid": user_id,
            "full_name" : user_data.full_name,
            "email": user_data.email,
            "phone_number": user_data.phone_number,
            "language_preferences": user_data.language_preference,
            "hashed_password": hashed_pwd,
            "created_at": datetime.utcnow()
        }

        #save to firestore

        db.collection("users").document(user_id).set(user_dict)

        #remove hased_password before returning to the frontend for security

        del user_dict["hashed_password"]
        return user_dict








