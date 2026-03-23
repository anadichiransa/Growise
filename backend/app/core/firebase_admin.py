import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, auth

load_dotenv()

firebase_path = os.getenv("FIREBASE_CREDENTIALS_PATH")

if not firebase_path:
    raise ValueError("FIREBASE_CREDENTIALS_PATH is not set in .env")

if not os.path.exists(firebase_path):
    raise FileNotFoundError(f"Firebase key file not found: {firebase_path}")

if not firebase_admin._apps:
    cred = credentials.Certificate(firebase_path)
    firebase_admin.initialize_app(cred)

def verify_token(token: str):
    return auth.verify_id_token(token)