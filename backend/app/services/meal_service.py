from typing import List, Dict, Optional
import logging

from app.db.vector_db import recipe_collection, guidelines_collection
from app.ai.gemini_client import gemini_client
from app.ai.prompts.meal_planner import (
    create_meal_explanation_prompt,
    create_no_recipes_prompt,
)

logger = logging.getLogger(__name__)


class AIService:

    def generate_meal_plan(
        self,
        child_age_months: int,
        liked_foods: List[str],
        disliked_foods: List[str],
        prep_methods: List[str],
    ) -> Dict:
        """
        Generate a complete meal plan for a baby.

        Args:
            child_age_months: Baby's age (must be 6-24)
            liked_foods: Foods the baby enjoys
            disliked_foods: Foods the baby refuses
            prep_methods: Mother's preferred cooking methods

        Returns:
            Dict with recipe_name, ingredients, preparation, nutrition,
            ai_explanation, modification_required, omit_or_reduce, texture,
            fhb_guideline_id, or a Dict with 'error' key.
        """

        # STEP 1: Get the FHB guideline
        fhb_guideline = self._get_fhb_guideline(child_age_months)

        if not fhb_guideline:
            return {
                "error": "No FHB guideline found",
                "message": (
                    f"No FHB guideline found for {child_age_months} months. "
                    f"Age must be between 6 and 24 months."
                ),
            }

        # STEP 2: Build search query and query ChromaDB
        search_query = self._build_search_query(
            child_age_months,
            liked_foods,
            prep_methods,
        )

        logger.info(f"ChromaDB search query: {search_query}")

        search_results = recipe_collection.query(
            query_texts=[search_query],
            n_results=20,
            where={
                "$and": [
                    {"min_age_months": {"$lte": child_age_months}},
                    {"max_age_months": {"$gte": child_age_months}},
                ]
            },
        )

        if not search_results.get("metadatas") or len(search_results["metadatas"][0]) == 0:
            return {
                "error": "No recipes found",
                "message": (
                    "No recipes found for this age group. "
                    "Please check the database has been populated."
                ),
            }

        # STEP 3: Hard filter recipes
        harmful_substances = self._ensure_list(
            fhb_guideline.get("harmful_substances", [])
        )

        safe_recipes = self._hard_filter_recipes(
            search_results,
            disliked_foods,
            harmful_substances,
        )

        logger.info(
            f"Recipes after filter: {len(safe_recipes)} of "
            f"{len(search_results['metadatas'][0])}"
        )

        if not safe_recipes:
            advice = gemini_client.generate_explanation(
                create_no_recipes_prompt(child_age_months, disliked_foods)
            )
            return {
                "error": "No matching recipes",
                "message": "All available recipes contain one or more disliked foods.",
                "advice": advice,
            }

        # STEP 4: Select best recipe
        selected = safe_recipes[0]
        logger.info(f"Selected recipe: {selected.get('recipe_name', 'Unknown recipe')}")

        # STEP 5: Generate AI explanation
        prompt = create_meal_explanation_prompt(
            recipe_name=selected.get("recipe_name", ""),
            ingredients_list=self._ensure_list(selected.get("ingredients_list")),
            preparation=selected.get("preparation", ""),
            nutrition=self._extract_nutrition(selected),
            omit_or_reduce_items=self._ensure_list(selected.get("omit_or_reduce_items")),
            child_age_months=child_age_months,
            liked_foods=liked_foods,
            prep_methods=prep_methods,
            fhb_guideline=fhb_guideline,
        )

        ai_explanation = gemini_client.generate_explanation(prompt)

        # STEP 6: Return response
        return {
            "recipe_name": selected.get("recipe_name", ""),
            "ingredients": self._ensure_list(selected.get("ingredients_list")),
            "preparation": selected.get("preparation", ""),
            "nutrition": self._extract_nutrition(selected),
            "ai_explanation": ai_explanation,
            "modification_required": bool(selected.get("modification_required", False)),
            "omit_or_reduce": self._ensure_list(selected.get("omit_or_reduce_items")),
            "texture": selected.get("texture", ""),
            "fhb_guideline_id": selected.get("fhb_guideline_id", ""),
        }

    def _get_fhb_guideline(self, age_months: int) -> Optional[Dict]:
        """
        Query ChromaDB for the FHB guideline that covers this age.
        """
        try:
            results = guidelines_collection.query(
                query_texts=[f"complementary feeding guidelines for {age_months} month old baby"],
                n_results=1,
                where={
                    "$and": [
                        {"age_min_months": {"$lte": age_months}},
                        {"age_max_months": {"$gte": age_months}},
                    ]
                },
            )

            if results.get("metadatas") and len(results["metadatas"][0]) > 0:
                return results["metadatas"][0][0]

            return None

        except Exception as e:
            logger.error(f"Error fetching FHB guideline: {e}")
            return None

    def _build_search_query(
        self,
        age_months: int,
        liked_foods: List[str],
        prep_methods: List[str],
    ) -> str:
        """
        Build semantic search query for ChromaDB.
        """
        query = f"nutritious baby food recipe for {age_months} months"

        if liked_foods:
            query += f" with {' '.join(liked_foods)}"

        if prep_methods:
            query += f" preferably {' or '.join(prep_methods)}"

        return query

    def _hard_filter_recipes(
        self,
        search_results: Dict,
        disliked_foods: List[str],
        harmful_substances: List[str],
    ) -> List[Dict]:
        """
        Filter out recipes containing disliked foods or harmful substances.
        """
        safe = []

        for metadata in search_results["metadatas"][0]:
            ingredients = self._ensure_list(metadata.get("ingredients_list", []))

            has_disliked = any(
                disliked.lower() in ing.lower()
                for disliked in disliked_foods
                for ing in ingredients
            )
            if has_disliked:
                logger.debug(f"Filtered out (disliked): {metadata.get('recipe_name', 'Unknown')}")
                continue

            has_harmful = any(
                harmful.lower() in ing.lower()
                for harmful in harmful_substances
                for ing in ingredients
            )
            if has_harmful:
                logger.debug(f"Filtered out (harmful): {metadata.get('recipe_name', 'Unknown')}")
                continue

            safe.append(metadata)

        return safe

    def _extract_nutrition(self, recipe_metadata: Dict) -> Dict:
        """
        Extract nutrition values from ChromaDB metadata.
        """
        serving_g = float(recipe_metadata.get("serving_size_g") or 100)

        return {
            "calories": float(recipe_metadata.get("calories") or 0),
            "protein_g": float(recipe_metadata.get("protein_g") or 0),
            "iron_mg": float(recipe_metadata.get("iron_mg") or 0),
            "serving_size_g": serving_g,
            "serving_size_ml": round(serving_g / 1.05, 1),
            "source": "Sri Lanka MRI + USDA FoodData Central",
            "note": (
                "Nutrition values from verified food composition tables. "
                "Not estimated by AI."
            ),
        }

    def _ensure_list(self, value) -> List[str]:
        """
        Ensure value is always returned as a list.

        Handles:
        - None -> []
        - list -> same list
        - "" -> []
        - "fish, potato, breadcrumbs" -> ["fish", "potato", "breadcrumbs"]
        """
        if value is None:
            return []

        if isinstance(value, list):
            return [str(v).strip() for v in value if str(v).strip()]

        if isinstance(value, str):
            cleaned = value.strip()
            if not cleaned:
                return []
            return [item.strip() for item in cleaned.split(",") if item.strip()]

        return []


ai_service = AIService()