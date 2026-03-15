from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1.auth import router as auth_router

app = FastAPI(
    title="Growise API",
    description="Backend API for Growise child health app",
    version="1.0.0"
)

# CORS — allows Flutter web and mobile to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])

@app.get("/")
def root():
    return {"message": "Growise API is running"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/health/db")
def health_db():
    try:
        from app.core.database import db
        if db is not None:
            return {"status": "ok", "database": "connected"}
        return {"status": "error", "message": "DB is None"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}