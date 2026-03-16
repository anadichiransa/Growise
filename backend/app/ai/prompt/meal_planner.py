"""
AI Prompt Templates for the Meal Planner
==========================================
Contains the prompt-building functions used by AIService.

BUG FIX APPLIED:
  Fix #2 — create_meal_explanation_prompt() now accepts prep_methods parameter
  Fix #3 — Prompt now includes a cooking method education section
"""


def create_meal_explanation_prompt(
    recipe_name: str,
    ingredients_list: list,
    preparation: str,
    nutrition: dict,
    omit_or_reduce_items: list,
    child_age_months: int,
    liked_foods: list,
    prep_methods: list,          # ← FIX #2: this parameter was missing before
    fhb_guideline: dict
) -> str:
    """
    Build the prompt that Groq uses to generate a recipe explanation.

    The prompt is structured into sections so the AI knows exactly
    what to say, in what order, and what not to do (e.g. don't recalculate
    nutrition, don't change ingredients).

    Args:
        recipe_name:          Name of the selected recipe
        ingredients_list:     List of standardized ingredient names
        preparation:          Preparation method description from the recipe
        nutrition:            Dict of {calories, protein_g, iron_mg, serving_size_g}
        omit_or_reduce_items: Items the mother must omit from baby's portion
        child_age_months:     Baby's age in months
        liked_foods:          Foods the baby likes (from mother's selection)
        prep_methods:         Mother's preferred cooking methods (FIX #2)
        fhb_guideline:        The FHB guideline metadata from ChromaDB

    Returns:
        A complete prompt string ready to send to Groq
    """

    # ------------------------------------------------------------------
    # MODIFICATION SECTION
    # Only included if the recipe contains salt, sugar, or other
    # items that FHB says to omit from baby's portion.
    # ------------------------------------------------------------------
    modification_section = ""
    if omit_or_reduce_items:
        items_str = ', '.join(omit_or_reduce_items).upper()
        modification_section = f"""
⚠️ CRITICAL MODIFICATION REQUIRED:
This recipe contains: {items_str}

You MUST instruct the mother to:
1. Prepare the recipe for the whole family as written
2. SEPARATE the baby's portion BEFORE adding {items_str}
3. Add {items_str} ONLY to the adult portions afterwards

Use a practical example in your explanation:
"Cook the dhal until soft. Remove {nutrition.get('serving_size_g', 80):.0f}g for baby.
Then add salt to the rest for the adults."
"""

    # ------------------------------------------------------------------
    # COOKING METHOD EDUCATION SECTION — FIX #3
    # This section was completely missing before the bug fix.
    # It allows the AI to educate mothers who prefer unhealthy cooking
    # methods (frying) or praise those who already use healthy methods.
    # ------------------------------------------------------------------
    cooking_section = ""   # ← FIX #3: this block was not here before
    if prep_methods:
        unhealthy_keywords = ['fry', 'deep', 'roast']
        healthy_keywords   = ['steam', 'boil', 'mash', 'puree', 'bake', 'poach']

        mother_prefers_unhealthy = any(
            keyword in m.lower()
            for m in prep_methods
            for keyword in unhealthy_keywords
        )
        mother_prefers_healthy = any(
            keyword in m.lower()
            for m in prep_methods
            for keyword in healthy_keywords
        )

        if mother_prefers_unhealthy:
            cooking_section = f"""
COOKING METHOD EDUCATION REQUIRED:
Mother's preferred methods: {', '.join(prep_methods)}
Recipe's FHB-approved method: {preparation}

You MUST educate the mother gently:
- Explain that this recipe uses {preparation}, which is healthier for babies than frying
- Say: "Frying adds oil that is hard for a baby's digestive system to handle, especially under 12 months"
- Say: "Steaming and boiling preserve more nutrients and keep the texture safe"
- Be encouraging and supportive — never judgmental
- Acknowledge that frying is common in Sri Lankan cooking and that is perfectly fine for the family
"""
        elif mother_prefers_healthy:
            cooking_section = f"""
COOKING METHOD ACKNOWLEDGEMENT:
Mother already prefers: {', '.join(prep_methods)}
This is excellent — these methods align perfectly with FHB recommendations.
PRAISE her choice: acknowledge that steaming/boiling is ideal for babies and she is doing a great job.
"""

    # ------------------------------------------------------------------
    # MAIN PROMPT
    # ------------------------------------------------------------------
    prompt = f"""You are a friendly, knowledgeable pediatric nutritionist helping a Sri Lankan mother
feed her {child_age_months}-month-old baby. Speak warmly and practically.

=== RECIPE SELECTED ===
Name: {recipe_name}
Ingredients: {', '.join(ingredients_list)}
Preparation method: {preparation}

=== NUTRITION (from verified database — DO NOT recalculate) ===
Calories:  {nutrition.get('calories', 0):.0f} kcal per serving
Protein:   {nutrition.get('protein_g', 0):.1f} g
Iron:      {nutrition.get('iron_mg', 0):.2f} mg
Serving:   {nutrition.get('serving_size_g', 100):.0f} g

=== CHILD INFORMATION ===
Age: {child_age_months} months old
Liked foods: {', '.join(liked_foods) if liked_foods else 'not specified'}

=== FHB GUIDELINES FOR {child_age_months} MONTHS ===
Never use:    {', '.join(fhb_guideline.get('harmful_substances', []))}
Omit/reduce:  {', '.join(fhb_guideline.get('omit_or_reduce', []))}
Texture:      {', '.join(fhb_guideline.get('texture_tags', []))}
Frequency:    {fhb_guideline.get('frequency', 'as appropriate')}
Portion size: {fhb_guideline.get('portion_size', 'age-appropriate')}

{modification_section}
{cooking_section}

=== YOUR TASK ===
Write a helpful explanation for this mother in 3-4 short paragraphs:

**Why this recipe works:**
Explain the nutritional benefits, mention the liked foods included, and why it is right for {child_age_months} months.

**How to prepare safely:**
{'Include the MODIFICATION INSTRUCTION above — this is critical.' if omit_or_reduce_items else 'Give practical preparation tips.'}
{'Include the COOKING METHOD EDUCATION above.' if cooking_section else ''}

**FHB compliance:**
Briefly explain how this recipe follows FHB guidelines for {child_age_months} months.

**Practical tip:**
One actionable suggestion to help the mother succeed.

=== RULES ===
1. DO NOT change or suggest different ingredients
2. DO NOT recalculate nutrition — use the values given above
3. DO give the modification instruction if it is shown above
4. DO give the cooking education if it is shown above
5. Keep total response under 220 words
6. Use simple, clear language — avoid medical jargon
7. Tone must be warm, supportive, and encouraging
"""
    return prompt


def create_no_recipes_prompt(child_age_months: int, disliked_foods: list) -> str:
    """
    Prompt used when no recipes survive the hard filter
    (all recipes contained disliked foods).

    The AI gives the mother alternative suggestions and
    encouragement about picky eating.
    """
    return f"""A mother is looking for baby food recipes for her {child_age_months}-month-old.
All available recipes contain foods her baby dislikes: {', '.join(disliked_foods)}.

Please:
1. Reassure her that picky eating is completely normal at this age
2. Suggest 2-3 simple Sri Lankan baby foods that do NOT contain {', '.join(disliked_foods)}
3. Give one tip for gradually reintroducing disliked foods

Keep your response to 3 short sentences. Be warm and supportive.
"""
