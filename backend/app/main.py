from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
from fastapi import FastAPI
from app.api.v1.auth import router as auth_router

app = FastAPI(title="GROWISE Backend")

# 1. Simple test to see if libraries are the problem
try:
    import firebase_admin
    from firebase_admin import firestore
    LIB_STATUS = "Libraries OK"
except ImportError:
    LIB_STATUS = "Libraries Missing"


app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])

@app.get("/health/db")
def health_check_db():
    # We will try to import the db here inside the function 
    # so the whole app doesn't crash on startup
    try:
        from app.core.database import db
        if db is not None:
            return {"status": "success", "database": "connected", "lib": LIB_STATUS}
        else:
            return {"status": "error", "message": "DB object is None. Check terminal logs."}
    except Exception as e:
        return {"status": "crash", "error_details": str(e)}