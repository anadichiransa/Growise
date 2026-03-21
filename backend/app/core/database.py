"""
Firebase / Firestore Database Connection
==========================================
Initializes Firebase Admin SDK using the service account key.
Called once at startup in main.py.

After calling initialize_firebase(), use:
    from firebase_admin import firestore
    db = firestore.client()
    db.collection('meals').document('...').set({...})
"""

import firebase_admin
from firebase_admin import credentials, firestore
from pathlib import Path
from app.core.config import settings


_db = None   # cached Firestore client


def initialize_firebase():
    """
    Initialize Firebase Admin SDK.
    Safe to call multiple times — checks if already initialized.
    """
    if not firebase_admin._apps:
        key_path = Path(settings.FIREBASE_PRIVATE_KEY_PATH)

        if not key_path.exists():
            raise FileNotFoundError(
                f"Firebase key not found at {key_path}. "
                "Download it from Firebase Console → Project Settings → Service Accounts."
            )

        cred = credentials.Certificate(str(key_path))
        firebase_admin.initialize_app(cred, {
            'projectId': settings.FIREBASE_PROJECT_ID
        })
        print(f"✅ Firebase initialized (project: {settings.FIREBASE_PROJECT_ID})")


def get_db():
    """Return a Firestore client. Initialize Firebase first if needed."""
    global _db
    if _db is None:
        initialize_firebase()
        _db = firestore.client()
    return _db