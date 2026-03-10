import firebase_admin
from firebase_admin import credentials, auth
import os

# Initialize Firebase Admin SDK
cred = credentials.Certificate(os.getenv('FIREBASE_CREDENTIALS_PATH'))
firebase_admin.initialize_app(cred)

def verify_token(token: str) -> dict:
    """Verify Firebase ID token and return user info"""
    try:
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception as e:
        raise ValueError(f"Invalid token: {e}")