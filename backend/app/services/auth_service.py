from app.core.database import db
from app.models.user import UserCreate, UserProfile
from datetime import datetime, timezone

class AuthService:

    @staticmethod
    def save_user_profile(uid: str, user_data: UserCreate) -> dict:
        """
        Called after Firebase Auth creates the user on Flutter side.
        Saves extra profile data (name, phone, language) to Firestore.
        """
        try:
            user_ref = db.collection("users").document(uid)
            
            # Check if profile already exists
            if user_ref.get().exists:
                return {"error": "User profile already exists"}

            profile = {
                "uid": uid,
                "full_name": user_data.full_name,
                "email": user_data.email,
                "phone_number": user_data.phone_number,
                "language_preference": user_data.language_preference,
                "created_at": datetime.now(timezone.utc).isoformat(),
            }

            user_ref.set(profile)
            return profile

        except Exception as e:
            return {"error": str(e)}

    @staticmethod
    def get_user_profile(uid: str) -> dict:
        """Get user profile from Firestore by Firebase Auth UID."""
        try:
            user_ref = db.collection("users").document(uid).get()
            if user_ref.exists:
                return user_ref.to_dict()
            return {"error": "User not found"}
        except Exception as e:
            return {"error": str(e)}