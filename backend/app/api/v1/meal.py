from fastapi import APIRouter, HTTPException
from app.models.meal import MealRequest, MealResponse, ErrorResponse
from app.services.meal_service import ai_service
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/meals", tags=["meals"])


@router.post(
    "/generate",
    response_model=MealResponse,
    responses={
        200: {"description": "Meal plan generated successfully"},
        404: {"model": ErrorResponse, "description": "No matching recipe found"},
        422: {"description": "Invalid request"},
        500: {"description": "Server error"},
    },
    summary="Generate AI meal plan",
)
async def generate_meal_plan(request: MealRequest):
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
            prep_methods=request.prep_methods,
        )

        if "error" in result:
            raise HTTPException(status_code=404, detail=result)

        return result

    except HTTPException:
        raise

    except Exception as e:
        logger.error(f"Unexpected error in generate_meal_plan: {e}", exc_info=True)
        raise HTTPException(
            status_code=500,
            detail={
                "error": "Internal server error",
                "message": "An unexpected error occurred. Please try again.",
            },
        )


@router.get("/history/{child_id}")
async def get_meal_history(child_id: str):
    return []


@router.get("/health")
async def meal_health():
    from app.db.vector_db import recipe_collection, guidelines_collection
    return {
        "status": "ok",
        "recipes_in_db": recipe_collection.count(),
        "guidelines_in_db": guidelines_collection.count(),
    }