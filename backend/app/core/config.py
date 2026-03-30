"""
Application Configuration
===========================
Reads all settings from the .env file using pydantic-settings.
The app will refuse to start if any required field is missing.

Usage anywhere in the app:
    from app.core.config import settings
    print(settings.GEMINI_API_KEY)
"""

from pydantic_settings import BaseSettings
from pydantic import Field


class Settings(BaseSettings):
    APP_NAME: str = "Growise"
    ENV: str = "development"
    DEBUG: bool = True

    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_VERSION: str = "v1"

    FIREBASE_PROJECT_ID: str = Field(...)
    FIREBASE_PRIVATE_KEY_PATH: str = Field(...)

    GEMINI_API_KEY: str = Field(...)
    GEMINI_MODEL: str = "gemini-2.5-flash"

    CHROMA_PATH: str = "./chroma_data"
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()