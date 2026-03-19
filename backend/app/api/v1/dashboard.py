from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from config import get_settings
from routers import auth, profile, access_requests, support, forgot_password, dashboard

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    description="Backend for the Settings page — Profile, Access Requests, Support & Auth",
)

# ── CORS ───────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # tighten this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ────────────────────────────────────────────────────────────────────
app.include_router(auth.router,             prefix="/api/v1")
app.include_router(forgot_password.router,  prefix="/api/v1")
app.include_router(profile.router,          prefix="/api/v1")
app.include_router(access_requests.router,  prefix="/api/v1")
app.include_router(support.router,          prefix="/api/v1")
app.include_router(dashboard.router,        prefix="/api/v1")


@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok"}
