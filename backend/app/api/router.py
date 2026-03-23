from fastapi import APIRouter
from app.api.v1 import vaccines

app = APIRouter()

app.include_router(vaccines.router)