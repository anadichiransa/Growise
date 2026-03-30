from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers.help_router import router as help_router
from app.api.v1 import children
from app.api.v1 import vaccines
from app.api.v1 import growth
from app.api.v1 import meal

app = FastAPI(title="Growise API")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(help_router, prefix="/api/v1")
app.include_router(children.router, prefix="/api/v1")
app.include_router(vaccines.router, prefix="/api/v1")
app.include_router(growth.router, prefix="/api/v1")
app.include_router(meal.router, prefix="/api/v1")


@app.get("/")
def read_root():
    return {"message": "Growise API is running"}


@app.get("/health")
def health_check():
    return {"status": "healthy", "version": "1.1.0"}