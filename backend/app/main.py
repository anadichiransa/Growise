from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import children  
from app.api.v1 import vaccines
app = FastAPI(title="Growise API")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(children.router, prefix="/api/v1")

@app.get("/")
def read_root():
    return {"message": "Growise API is running"}