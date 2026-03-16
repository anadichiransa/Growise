"""
Growise API — Entry Point
===========================
FastAPI application factory.

Start the server:
    cd backend
    source venv/bin/activate
    uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

Then open: http://localhost:8000/docs
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ── Import all routers ──────────────────────────────────────────────
from app.api.v1 import meal       # ← Meal bot (Asindu)
# from app.api.v1 import auth     # ← Nivvethik
# from app.api.v1 import children # ← Ackshay
# from app.api.v1 import growth   # ← Ramzy
# from app.api.v1 import vaccines # ← Ackshay

from app.core.database import initialize_firebase
import logging

logging.basicConfig(level="INFO")
logger = logging.getLogger(__name__)


# ── Create app ──────────────────────────────────────────────────────
app = FastAPI(
    title="Growise API",
    description="Backend for the Growise baby health and nutrition app",
    version="1.0.0",
    docs_url="/docs",      # Interactive API docs at http://localhost:8000/docs
    redoc_url="/redoc",
)


# ── CORS ────────────────────────────────────────────────────────────
# Allow all origins in development. Tighten this in production.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Startup event ───────────────────────────────────────────────────
@app.on_event("startup")
async def startup():
    logger.info("Starting Growise API...")
    try:
        initialize_firebase()
    except Exception as e:
        logger.warning(f"Firebase init warning (non-fatal in dev): {e}")
    logger.info("✅ Startup complete")


# ── Register routers ────────────────────────────────────────────────
app.include_router(
    meal.router,
    prefix="/api/v1/meals",
    tags=["Meals"]
)
# app.include_router(auth.router,     prefix="/api/v1/auth",     tags=["Auth"])
# app.include_router(children.router, prefix="/api/v1/children", tags=["Children"])
# app.include_router(growth.router,   prefix="/api/v1/growth",   tags=["Growth"])
# app.include_router(vaccines.router, prefix="/api/v1/vaccines", tags=["Vaccines"])


# ── Root endpoint ───────────────────────────────────────────────────
@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Growise API",
        "version": "1.0.0",
        "docs":    "/docs",
        "status":  "running"
    }


@app.get("/health", tags=["Root"])
async def health():
    return {"status": "ok"}
