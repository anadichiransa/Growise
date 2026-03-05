from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="GROWISE Backend")

# This allows your Flutter app to communicate with the FastAPI server
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"status": "Growise Server is Online", "version": "1.0.0"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}