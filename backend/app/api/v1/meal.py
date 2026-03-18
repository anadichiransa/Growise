"""
Meals API Router
=================
Defines the REST endpoints for the AI Meal Planner.

Endpoints:
  POST /api/v1/meals/generate          — generate a meal plan (main endpoint)
  GET  /api/v1/meals/history/{child_id} — get past meal plans for a child
  GET  /api/v1/meals/health             — health check for this feature

This router is registered in backend/app/main.py.
"""

from fastapi import APIRouter, HTTPException
from app.models.meal import MealRequest, MealResponse, ErrorResponse
from app.services.meal_service import ai_service
import logging

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post(
    "/generate",
    response_model=MealResponse,
    responses={
        200: {"description": "Meal plan generated successfully"},
        404: {"model": ErrorResponse, "description": "No matching recipe found"},
        422: {"description": "Invalid request (age out of range, wrong types, etc.)"},
        500: {"description": "Server error"},
    },
    summary="Generate AI meal plan",
    description=(
        "Generates a personalized meal plan for a baby based on age, food preferences, "
        "and mother's preferred cooking methods. "
        "Uses ChromaDB for semantic recipe search + Groq AI for explanation."
    )
)
async def generate_meal_plan(request: MealRequest):
    """
    Main endpoint — called by Flutter when the mother taps 'Generate Meal Plan'.
    
    FastAPI automatically validates the request against MealRequest before
    this function runs. If validation fails, it returns a 422 response.
    """
    logger.info(
        f"Generate meal plan — age={request.child_age_months}m, "
        f"liked={request.liked_foods}, "
        f"disliked={request.disliked_foods}, "
        f"prep={request.prep_methods}"
    )

    try:
        result = ai_service.generate_meal_plan(
            child_age_months=request.child_age_months,
            liked_foods=request.liked_foods,
            disliked_foods=request.disliked_foods,
            prep_methods=request.prep_methods
        )

        # The service returns a dict with 'error' key when no recipe is found
        if 'error' in result:
            raise HTTPException(
                status_code=404,
                detail=result  # Flutter reads result['detail']['message']
            )

        return result

    except HTTPException:
        raise  # Re-raise HTTPException so FastAPI handles it normally

    except Exception as e:
        logger.error(f"Unexpected error in generate_meal_plan: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                'error': 'Internal server error',
                'message': 'An unexpected error occurred. Please try again.',
            }
        )


@router.get(
    "/history/{child_id}",
    summary="Get meal history for a child"
)
async def get_meal_history(child_id: str):
    """
    Returns past meal plans saved for a specific child.
    Reads from Firestore.
    
    Implement after the basic generate endpoint is working.
    """
    # TODO: implement Firestore read
    # from app.core.database import get_db
    # db = get_db()
    # docs = db.collection('meal_history').where('child_id', '==', child_id).stream()
    # return [doc.to_dict() for doc in docs]
    return []


@router.get("/health", summary="Meal planner health check")
async def meal_health():
    """Check that ChromaDB is accessible and has data."""
    from app.db.vector_db import recipe_collection, guidelines_collection
    return {
        "status":            "ok",
        "recipes_in_db":     recipe_collection.count(),
        "guidelines_in_db":  guidelines_collection.count(),
    }