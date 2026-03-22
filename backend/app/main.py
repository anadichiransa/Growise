from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import children
from app.api.v1 import vaccines

app = FastAPI(title="Growise API")

# CORS (allow frontend connection)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # later you can restrict to your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# register routes
app.include_router(children.router, prefix="/api/v1")
app.include_router(vaccines.router, prefix="/api/v1")

# test route
@app.get("/")
def read_root():
    return {"message": "Growise API is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "version": "1.0.0"}