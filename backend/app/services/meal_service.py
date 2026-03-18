"""
AI Meal Planning Service
==========================
Orchestrates the complete meal plan generation pipeline.

Pipeline:
  1. Get FHB guideline for child's age     (ChromaDB query)
  2. Semantic recipe search                 (ChromaDB query, includes prep_methods)
  3. Hard filter in Python                  (disliked + harmful — NOT AI)
  4. Select best recipe                     (top result after filter)
  5. AI generates explanation               (Groq, prompt includes prep_methods)
  6. Return response with database nutrition
"""

from typing import List, Dict, Optional
import logging

from app.db.vector_db import recipe_collection, guidelines_collection
from app.ai.groq_client import groq_client
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
            liked_foods:      Foods the baby enjoys
            disliked_foods:   Foods the baby refuses (hard-filtered in Python)
            prep_methods:     Mother's preferred cooking methods (used for AI education)

        Returns:
            Dict with recipe_name, ingredients, preparation, nutrition,
            ai_explanation, modification_required, omit_or_reduce, texture,
            fhb_guideline_id.
            Or a Dict with 'error' key if something went wrong.
        """

        # ──────────────────────────────────────────────────────────────
        # STEP 1: Get the FHB guideline that applies to this child's age
        # ──────────────────────────────────────────────────────────────
        fhb_guideline = self._get_fhb_guideline(child_age_months)

        if not fhb_guideline:
            return {
                'error': 'No FHB guideline found',
                'message': f'No FHB guideline found for {child_age_months} months. '
                           f'Age must be between 6 and 24 months.'
            }

        # ──────────────────────────────────────────────────────────────
        # STEP 2: Semantic search in ChromaDB
        # The query now includes prep_methods — FIX #1
        # ChromaDB's age filter ensures we only get age-appropriate recipes
        # ──────────────────────────────────────────────────────────────
        search_query = self._build_search_query(
            child_age_months,
            liked_foods,
            prep_methods        # ← FIX #1: was not passed before
        )

        logger.info(f"ChromaDB search query: {search_query}")

        search_results = recipe_collection.query(
            query_texts=[search_query],
            n_results=20,       # Get 20, we will filter down in Python
            where={
                "$and": [
                    {"min_age_months": {"$lte": child_age_months}},
                    {"max_age_months": {"$gte": child_age_months}}
                ]
            }
        )

        if not search_results['metadatas'] or len(search_results['metadatas'][0]) == 0:
            return {
                'error': 'No recipes found',
                'message': 'No recipes found for this age group. '
                           'Please check the database has been populated.'
            }

        # ──────────────────────────────────────────────────────────────
        # STEP 3: HARD FILTER in Python — not AI!
        # Remove recipes that contain disliked foods or harmful substances.
        # This must be deterministic. AI could "forget" to filter.
        # ──────────────────────────────────────────────────────────────
        harmful_substances = fhb_guideline.get('harmful_substances', [])

        safe_recipes = self._hard_filter_recipes(
            search_results,
            disliked_foods,
            harmful_substances
        )

        logger.info(f"Recipes after filter: {len(safe_recipes)} of "
                    f"{len(search_results['metadatas'][0])}")

        if not safe_recipes:
            # No recipes survived filtering — ask AI for alternative advice
            advice = groq_client.generate_explanation(
                create_no_recipes_prompt(child_age_months, disliked_foods)
            )
            return {
                'error': 'No matching recipes',
                'message': 'All available recipes contain one or more disliked foods.',
                'advice': advice
            }

        # ──────────────────────────────────────────────────────────────
        # STEP 4: Select the best recipe
        # ChromaDB already ranked by semantic similarity — take the top.
        # ──────────────────────────────────────────────────────────────
        selected = safe_recipes[0]
        logger.info(f"Selected recipe: {selected['recipe_name']}")

        # ──────────────────────────────────────────────────────────────
        # STEP 5: Generate AI explanation via Groq
        # prep_methods is now passed to the prompt — FIX #4
        # ──────────────────────────────────────────────────────────────
        prompt = create_meal_explanation_prompt(
            recipe_name=selected['recipe_name'],
            ingredients_list=selected.get('ingredients_list', []),
            preparation=selected.get('preparation', ''),
            nutrition=self._extract_nutrition(selected),
            omit_or_reduce_items=selected.get('omit_or_reduce_items', []),
            child_age_months=child_age_months,
            liked_foods=liked_foods,
            prep_methods=prep_methods,      # ← FIX #4: was not passed before
            fhb_guideline=fhb_guideline
        )

        ai_explanation = groq_client.generate_explanation(prompt)

        # ──────────────────────────────────────────────────────────────
        # STEP 6: Return the complete response
        # Nutrition comes from the DATABASE, not from AI calculation.
        # ──────────────────────────────────────────────────────────────
        return {
            'recipe_name':           selected['recipe_name'],
            'ingredients':           selected.get('ingredients_list', []),
            'preparation':           selected.get('preparation', ''),
            'nutrition':             self._extract_nutrition(selected),
            'ai_explanation':        ai_explanation,
            'modification_required': bool(selected.get('modification_required', False)),
            'omit_or_reduce':        selected.get('omit_or_reduce_items', []),
            'texture':               selected.get('texture', ''),
            'fhb_guideline_id':      selected.get('fhb_guideline_id', ''),
        }

    # ──────────────────────────────────────────────────────────────────
    # PRIVATE METHODS
    # ──────────────────────────────────────────────────────────────────

    def _get_fhb_guideline(self, age_months: int) -> Optional[Dict]:
        """
        Query ChromaDB for the FHB guideline that covers this age.
        Uses metadata filter ($lte / $gte) for exact age matching.
        """
        try:
            results = guidelines_collection.query(
                query_texts=[f"complementary feeding guidelines for {age_months} month old baby"],
                n_results=1,
                where={
                    "$and": [
                        {"age_min_months": {"$lte": age_months}},
                        {"age_max_months": {"$gte": age_months}}
                    ]
                }
            )
            if results['metadatas'] and len(results['metadatas'][0]) > 0:
                return results['metadatas'][0][0]
            return None
        except Exception as e:
            logger.error(f"Error fetching FHB guideline: {e}")
            return None

    def _build_search_query(
        self,
        age_months: int,
        liked_foods: List[str],
        prep_methods: List[str]     # ← FIX #1: added this parameter
    ) -> str:
        """
        Build the semantic search query for ChromaDB.
        
        The query is text that ChromaDB will embed and compare against
        the recipe documents. Including prep_methods means ChromaDB will
        naturally rank recipes that match the cooking style higher.
        
        Before fix:  "nutritious baby food recipe for 8 months with rice chicken"
        After fix:   "nutritious baby food recipe for 8 months with rice chicken
                      preferably steamed or boiled"
        """
        query = f"nutritious baby food recipe for {age_months} months"

        if liked_foods:
            query += f" with {' '.join(liked_foods)}"

        if prep_methods:                                      # ← FIX #1
            query += f" preferably {' or '.join(prep_methods)}"   # ← FIX #1

        return query

    def _hard_filter_recipes(
        self,
        search_results: Dict,
        disliked_foods: List[str],
        harmful_substances: List[str]
    ) -> List[Dict]:
        """
        Filter recipes in Python — not AI.
        
        Removes any recipe that contains:
        1. A food the baby dislikes
        2. A harmful substance per FHB (should already be tagged out, but double-checked)
        
        The case-insensitive check (`.lower()`) handles 'Pumpkin' vs 'pumpkin'.
        The `in` substring check handles 'red_lentils' matching 'lentils'.
        """
        safe = []

        for metadata in search_results['metadatas'][0]:
            ingredients = metadata.get('ingredients_list', [])

            # Check 1: Disliked foods — if any disliked food appears, skip
            has_disliked = any(
                disliked.lower() in ing.lower()
                for disliked in disliked_foods
                for ing in ingredients
            )
            if has_disliked:
                logger.debug(f"Filtered out (disliked): {metadata['recipe_name']}")
                continue

            # Check 2: Harmful substances — double-check even though they
            # should have been removed during tagging
            has_harmful = any(
                harmful.lower() in ing.lower()
                for harmful in harmful_substances
                for ing in ingredients
            )
            if has_harmful:
                logger.debug(f"Filtered out (harmful): {metadata['recipe_name']}")
                continue

            safe.append(metadata)

        return safe

    def _extract_nutrition(self, recipe_metadata: Dict) -> Dict:
        """
        Extract nutrition values from ChromaDB metadata.
        
        These values were calculated from the verified Sri Lanka MRI + USDA
        database during the data pipeline (Script 02). They are stored in
        ChromaDB metadata and returned as-is — we do NOT ask AI to calculate
        or adjust them.
        """
        serving_g = float(recipe_metadata.get('serving_size_g') or 100)

        return {
            'calories':       float(recipe_metadata.get('calories') or 0),
            'protein_g':      float(recipe_metadata.get('protein_g') or 0),
            'iron_mg':        float(recipe_metadata.get('iron_mg') or 0),
            'serving_size_g': serving_g,
            'serving_size_ml': round(serving_g / 1.05, 1),  # approximate for liquids
            'source': 'Sri Lanka MRI + USDA FoodData Central',
            'note':   'Nutrition values from verified food composition tables. '
                      'Not estimated by AI.',
        }


# Singleton — one instance shared across all API requests
ai_service = AIService()