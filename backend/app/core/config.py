"""
Application Configuration
===========================
Reads all settings from the .env file using pydantic-settings.
The app will refuse to start if any required field is missing.

Usage anywhere in the app:
    from app.core.config import settings
    print(settings.GROQ_API_KEY)
"""

from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Growise"
    ENV:      str = "development"
    DEBUG:    bool = True

    # Server
    API_HOST:    str = "0.0.0.0"
    API_PORT:    int = 8000
    API_VERSION: str = "v1"

    # Firebase — required, no default
    FIREBASE_PROJECT_ID:       str = Field(..., description="Firebase project ID")
    FIREBASE_PRIVATE_KEY_PATH: str = Field(..., description="Path to firebase-admin-key.json")

    # AI
    GROQ_API_KEY: str  = Field(..., description="Groq API key (starts with gsk_)")
    GROQ_MODEL:   str  = "llama3-8b-8192"
    USDA_API_KEY: str  = ""

    # ChromaDB
    CHROMA_PATH: str = "./chroma_data"

    # Logging
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        # Don't throw an error for extra keys in .env
        extra = "ignore"


# Single instance — import this everywhere
settings = Settings()