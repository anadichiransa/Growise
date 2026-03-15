from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from api import growth, learn, help_recovery, who_standards

app = FastAPI(
    title="GrowIse API",
    description="Backend for the GrowIse Flutter app",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(growth.router,        prefix="/growth",  tags=["Growth Tracker"])
app.include_router(learn.router,         prefix="/learn",   tags=["Play & Learn"])
app.include_router(help_recovery.router, prefix="/help",    tags=["Help & Recovery"])
app.include_router(who_standards.router, prefix="/who",     tags=["WHO Standards"])


@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "GrowIse API is running 🌱"}