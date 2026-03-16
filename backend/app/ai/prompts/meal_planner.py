def create_meal_explanation_prompt(
    recipe_name: str,
    ingredients_list: list,
    preparation: str,
    nutrition: dict,
    omit_or_reduce_items: list,
    child_age_months: int,
    liked_foods: list,
    prep_methods: list,
    fhb_guideline: dict
) -> str:
    modification_section = ""
    if omit_or_reduce_items:
        items_str = ', '.join(omit_or_reduce_items).upper()
        modification_section = f"""
CRITICAL MODIFICATION REQUIRED:
This recipe contains: {items_str}
Instruct the mother to separate the baby's portion BEFORE adding {items_str}.
"""

    cooking_section = ""
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
Mother prefers: {', '.join(prep_methods)}
You MUST gently explain that frying is not ideal for babies under 12 months.
Explain that steaming/boiling preserves nutrients and is safer.
Be warm and encouraging, never judgmental.
"""
        elif mother_prefers_healthy:
            cooking_section = f"""
COOKING METHOD ACKNOWLEDGEMENT:
Mother prefers: {', '.join(prep_methods)}
PRAISE her choice — steaming/boiling is ideal for babies.
"""

    prompt = f"""You are a friendly pediatric nutritionist helping a Sri Lankan mother
feed her {child_age_months}-month-old baby. Speak warmly and practically.

=== RECIPE SELECTED ===
Name: {recipe_name}
Ingredients: {', '.join(ingredients_list)}
Preparation: {preparation}

=== NUTRITION (DO NOT recalculate) ===
Calories: {nutrition.get('calories', 0):.0f} kcal
Protein:  {nutrition.get('protein_g', 0):.1f} g
Iron:     {nutrition.get('iron_mg', 0):.2f} mg
Serving:  {nutrition.get('serving_size_g', 100):.0f} g

=== CHILD INFO ===
Age: {child_age_months} months
Liked foods: {', '.join(liked_foods) if liked_foods else 'not specified'}

=== FHB GUIDELINES ===
Never use:   {', '.join(fhb_guideline.get('harmful_substances', []))}
Omit/reduce: {', '.join(fhb_guideline.get('omit_or_reduce', []))}
Texture:     {', '.join(fhb_guideline.get('texture_tags', []))}

{modification_section}
{cooking_section}

=== YOUR TASK ===
Write 3-4 short paragraphs covering:
1. Why this recipe works for {child_age_months} months
2. How to prepare safely (include modification/cooking instructions if shown above)
3. How it follows FHB guidelines
4. One practical tip for the mother

RULES: Do not change ingredients. Do not recalculate nutrition. Keep under 220 words. Be warm and supportive.
"""
    return prompt


def create_no_recipes_prompt(child_age_months: int, disliked_foods: list) -> str:
    return f"""A mother needs baby food recipes for her {child_age_months}-month-old.
All available recipes contain foods her baby dislikes: {', '.join(disliked_foods)}.

Please:
1. Reassure her that picky eating is normal at this age
2. Suggest 2-3 simple Sri Lankan baby foods without {', '.join(disliked_foods)}
3. Give one tip for reintroducing disliked foods

Keep response to 3 short sentences. Be warm and supportive.
"""
