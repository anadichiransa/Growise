import firebase_admin
from firebase_admin import credentials, firestore
import os

def initialize_db():
    # Find the absolute path to the backend folder
    # This ensures it works on Windows regardless of spaces in folder names
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    key_path = os.path.join(base_dir, "serviceAccountKey.json")

    print(f"\n--- DEBUG: DATABASE INITIALIZATION ---")
    print(f"Current working directory: {os.getcwd()}")
    print(f"Looking for serviceAccountKey.json at: {key_path}")

    if not os.path.exists(key_path):
        print(">>> ERROR: serviceAccountKey.json file not found at that path!")
        print("---------------------------------------\n")
        return None

    try:
        if not firebase_admin._apps:
            cred = credentials.Certificate(key_path)
            firebase_admin.initialize_app(cred)
            print(">>> SUCCESS: Firebase Admin SDK connected!")
        
        print("---------------------------------------\n")
        return firestore.client()
    except Exception as e:
        print(f">>> ERROR: Firebase failed to start: {e}")
        print("---------------------------------------\n")
        return None

db = initialize_db()