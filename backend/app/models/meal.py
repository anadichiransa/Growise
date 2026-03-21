"""
Meal Planner Pydantic Models
==============================
Request and response schemas for the /meals/generate endpoint.

FastAPI uses these for:
  - Automatic request validation (age range, types)
  - Auto-generated API documentation at /docs
  - Response serialization (dict → JSON)
"""

from pydantic import BaseModel, Field
from typing import List, Optional


class MealRequest(BaseModel):
    """
    Request body for POST /api/v1/meals/generate
    
    All fields except child_age_months have sensible defaults,
    so the Flutter app can omit them if the user hasn't selected anything.
    """
    child_age_months: int = Field(
        ...,
        ge=6,
        le=24,
        description="Baby's age in months. Must be between 6 and 24."
    )
    liked_foods: List[str] = Field(
        default=[],
        description="Foods the baby likes. Used to bias recipe search."
    )
    disliked_foods: List[str] = Field(
        default=[],
        description="Foods the baby refuses. HARD-filtered out in Python."
    )
    prep_methods: List[str] = Field(
        default=[],
        description="Mother's preferred cooking methods (boiled, steamed, fried, etc.)."
    )

    class Config:
        json_schema_extra = {
            "example": {
                "child_age_months": 8,
                "liked_foods": ["rice", "chicken"],
                "disliked_foods": ["pumpkin"],
                "prep_methods": ["steamed", "boiled"]
            }
        }


class NutritionInfo(BaseModel):
    """Nutrition values from the verified database."""
    calories:        float
    protein_g:       float
    iron_mg:         float
    serving_size_g:  float
    serving_size_ml: float
    source:          str
    note:            str


class MealResponse(BaseModel):
    """
    Successful response from POST /api/v1/meals/generate
    
    All nutrition values come from the database.
    ai_explanation comes from Groq.
    """
    recipe_name:           str
    ingredients:           List[str]
    preparation:           str
    nutrition:             NutritionInfo
    ai_explanation:        str
    modification_required: bool
    omit_or_reduce:        List[str]
    texture:               str
    fhb_guideline_id:      str


class ErrorResponse(BaseModel):
    """Returned when no recipe can be found or an error occurs."""
    error:   str
    message: str
    advice:  Optional[str] = None   # AI-generated alternative suggestions