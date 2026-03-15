cat > firebase/config.py << 'EOF'
import os
import firebase_admin
from firebase_admin import credentials, firestore, storage

_app = None

def get_firebase_app():
    global _app
    if _app is None:
        key_path = os.path.join(os.path.dirname(__file__), "serviceAccountKey.json")
        cred = credentials.Certificate(key_path)
        _app = firebase_admin.initialize_app(cred, {
            "storageBucket": "growise-73261.appspot.com",
        })
    return _app

def get_db():
    get_firebase_app()
    return firestore.client()

def get_bucket():
    get_firebase_app()
    return storage.bucket()
EOF