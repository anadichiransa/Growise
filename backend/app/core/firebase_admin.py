import os
import firebase_admin
from firebase_admin import credentials, auth


def _ensure_initialized():
    """Initialize Firebase Admin SDK if not already done."""
    if not firebase_admin._apps:
        base_dir = os.path.dirname(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        )
        key_path = os.path.join(base_dir, "serviceAccountKey.json")

        if not os.path.exists(key_path):
            raise FileNotFoundError(
                f"serviceAccountKey.json not found at {key_path}"
            )

        cred = credentials.Certificate(key_path)
        firebase_admin.initialize_app(cred)


def verify_token(token: str) -> dict:
    """Verify Firebase Auth ID token and return decoded claims."""
    _ensure_initialized()
    try:
        decoded = auth.verify_id_token(token)
        return decoded
    except Exception as e:
        raise ValueError(f"Invalid token: {e}")