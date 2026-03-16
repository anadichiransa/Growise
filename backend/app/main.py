from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Import database first so Firebase Admin SDK initializes before anything else
from app.core.database import db  # noqa: F401 - initializes Firebase on import

from app.api.v1.auth import router as auth_router
from app.api.v1.children import router as children_router

app = FastAPI(title="Growise API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(children_router, prefix="/api/v1", tags=["Children"])

@app.get("/")
def root():
    return {"message": "Growise API is running"}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/health/db")
def health_db():
    if db is not None:
        return {"status": "ok", "database": "connected"}
    return {"status": "error", "message": "DB not connected"}