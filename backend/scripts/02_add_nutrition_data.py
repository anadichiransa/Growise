"""
Script 2: Add Nutrition Data
==============================
Adds verified nutrition values to each recipe.
Values are from Sri Lanka MRI + USDA FoodData Central.

Input:  data/processed/recipes_with_ingredients.csv
Output: data/processed/recipes_with_nutrition.csv

New columns: calories, protein_g, iron_mg, serving_size_g
"""

import pandas as pd
import ast
from pathlib import Path

# ------------------------------------------------------------------
# NUTRITION DATABASE
# Values per 100g of cooked/prepared ingredient.
# Source: Sri Lanka MRI food composition tables + USDA FoodData Central
# ------------------------------------------------------------------
NUTRITION_DB = {
    # key: {calories (kcal), protein_g, iron_mg} per 100g cooked

    # Grains
    'rice':                {'calories': 130, 'protein_g': 2.7,  'iron_mg': 0.20},
    'red_rice':            {'calories': 111, 'protein_g': 2.6,  'iron_mg': 0.80},
    'rice_flour':          {'calories': 109, 'protein_g': 2.0,  'iron_mg': 0.35},
    'bread':               {'calories': 265, 'protein_g': 9.0,  'iron_mg': 3.60},
    'semolina':            {'calories': 100, 'protein_g': 3.0,  'iron_mg': 1.20},
    'pasta':               {'calories': 131, 'protein_g': 5.0,  'iron_mg': 1.00},
    'rice string hoppers': {'calories': 130, 'protein_g': 2.0,  'iron_mg': 0.50},
    'wheat_flour':         {'calories': 340, 'protein_g': 13.2, 'iron_mg': 3.90},

    # Legumes / Proteins
    'red_lentils':      {'calories': 116, 'protein_g': 9.0,  'iron_mg': 3.30},
    'mung_beans':       {'calories': 105, 'protein_g': 7.0,  'iron_mg': 1.40},
    'boiled_chickpeas': {'calories': 164, 'protein_g': 8.9,  'iron_mg': 1.70},
    'chicken':          {'calories': 165, 'protein_g': 31.0, 'iron_mg': 0.90},
    'chicken_mince':    {'calories': 165, 'protein_g': 27.0, 'iron_mg': 1.50},
    'chicken_liver':    {'calories': 172, 'protein_g': 26.0, 'iron_mg': 11.6},
    'fish':             {'calories': 96,  'protein_g': 20.0, 'iron_mg': 0.40},
    'sprats':           {'calories': 158, 'protein_g': 21.0, 'iron_mg': 2.90},
    'egg':              {'calories': 155, 'protein_g': 13.0, 'iron_mg': 1.80},
    'egg_yolk':         {'calories': 322, 'protein_g': 16.0, 'iron_mg': 2.70},
    'dhal curry':       {'calories': 132, 'protein_g': 4.0,  'iron_mg': 2.90},

    # Vegetables
    'pumpkin':      {'calories': 26, 'protein_g': 1.0, 'iron_mg': 0.80},
    'carrot':       {'calories': 35, 'protein_g': 0.8, 'iron_mg': 0.30},
    'sweet_potato': {'calories': 90, 'protein_g': 2.0, 'iron_mg': 0.70},
    'potato':       {'calories': 87, 'protein_g': 2.0, 'iron_mg': 0.30},
    'gotukola':     {'calories': 25, 'protein_g': 2.5, 'iron_mg': 3.50},
    'beetroot':     {'calories': 44, 'protein_g': 1.7, 'iron_mg': 0.80},
    'leeks':        {'calories': 31, 'protein_g': 0.8, 'iron_mg': 2.10},
    'beans':        {'calories': 31, 'protein_g': 1.8, 'iron_mg': 1.00},
    'tomato':       {'calories': 18, 'protein_g': 0.9, 'iron_mg': 0.30},

    # Fruits
    'banana':             {'calories': 89, 'protein_g': 1.1, 'iron_mg': 0.26},
    'ripe ambul banana':  {'calories': 89, 'protein_g': 1.1, 'iron_mg': 0.30},
    'papaya':             {'calories': 43, 'protein_g': 0.5, 'iron_mg': 0.25},
    'avocado':            {'calories': 160,'protein_g': 2.0, 'iron_mg': 0.55},
    'jakfruit':           {'calories': 95, 'protein_g': 1.7, 'iron_mg': 0.60},
    'breadfruit':         {'calories': 103,'protein_g': 1.1, 'iron_mg': 0.50},
    'apple':              {'calories': 52, 'protein_g': 0.3, 'iron_mg': 0.12},
    'pears':              {'calories': 39, 'protein_g': 0.3, 'iron_mg': 0.20},
    'ripe mango':         {'calories': 60, 'protein_g': 0.4, 'iron_mg': 0.20},

    # Dairy / Fats
    'curd':         {'calories': 98,  'protein_g': 11.0, 'iron_mg': 0.10},
    'yoghurt':      {'calories': 59,  'protein_g': 10.0, 'iron_mg': 0.10},
    'milk':         {'calories': 61,  'protein_g': 3.3,  'iron_mg': 0.10},
    'coconut':      {'calories': 354, 'protein_g': 3.3,  'iron_mg': 2.40},
    'coconut_milk': {'calories': 230, 'protein_g': 2.3,  'iron_mg': 3.30},
    'breast_milk':  {'calories': 65,  'protein_g': 1.0,  'iron_mg': 0.03},
    'butter':       {'calories': 717, 'protein_g': 0.9,  'iron_mg': 0.02},
    'oil':          {'calories': 884, 'protein_g': 0.0,  'iron_mg': 0.03},
    'king_coconut_water': {'calories': 19, 'protein_g': 0.7, 'iron_mg': 0.29},

    # Other
    'turmeric':     {'calories': 312, 'protein_g': 9.7,  'iron_mg': 41.4},
    'cinnamon':     {'calories': 247, 'protein_g': 4.0,  'iron_mg': 8.32},
    'curry_leaves': {'calories': 108, 'protein_g': 6.1,  'iron_mg': 0.93},
    'cardamom':     {'calories': 311, 'protein_g': 11.0, 'iron_mg': 14.0},
    'water':        {'calories': 0,   'protein_g': 0.0,  'iron_mg': 0.00},
}

# Default serving size by texture/category (in grams)
SERVING_SIZE_BY_TEXTURE = {
    'smooth_puree': 60,
    'well_mashed':  80,
    'soft_lumpy':   100,
    'soft_chunky':  120,
    'family_foods': 150,
}


def calculate_nutrition(ingredients_array: list, serving_size_g: float) -> dict:
    """
    Calculate estimated nutrition for a recipe.
    
    Method: Each ingredient contributes equally to the serving size.
    This is an approximation — the exact split depends on the recipe,
    but it gives a reasonable baseline from verified values.
    """
    if not ingredients_array:
        return {'calories': 0.0, 'protein_g': 0.0, 'iron_mg': 0.0}

    # Only count ingredients we have data for
    known = [ing for ing in ingredients_array if ing in NUTRITION_DB]
    if not known:
        return {'calories': 0.0, 'protein_g': 0.0, 'iron_mg': 0.0}

    total_cal = total_prot = total_iron = 0.0
    weight_per_ing = serving_size_g / len(known)

    for ing in known:
        n = NUTRITION_DB[ing]
        factor = weight_per_ing / 100  # values are per 100g
        total_cal  += n['calories']  * factor
        total_prot += n['protein_g'] * factor
        total_iron += n['iron_mg']   * factor

    return {
        'calories':  round(total_cal,  1),
        'protein_g': round(total_prot, 1),
        'iron_mg':   round(total_iron, 2),
    }


def main():
    print("=" * 60)
    print("  SCRIPT 2: ADD NUTRITION DATA")
    print("=" * 60)

    input_path  = Path('data/processed/recipes_with_ingredients.csv')
    output_path = Path('data/processed/recipes_with_nutrition.csv')

    df = pd.read_csv(input_path)
    # ingredients_array was saved as a string — convert back to Python list
    df['ingredients_array'] = df['ingredients_array'].apply(ast.literal_eval)

    print(f"\nProcessing {len(df)} recipes...")

    # Assign serving sizes based on texture (default 100g if texture unknown)
    if 'texture' in df.columns:
        df['serving_size_g'] = df['texture'].str.lower().map(SERVING_SIZE_BY_TEXTURE).fillna(100)
    else:
        df['serving_size_g'] = 100.0

    # Calculate nutrition for each recipe
    nutrition_rows = df.apply(
        lambda r: calculate_nutrition(r['ingredients_array'], r['serving_size_g']),
        axis=1
    ).apply(pd.Series)

    df = pd.concat([df, nutrition_rows], axis=1)

    # Print nutrition summary
    print("\nNutrition averages across all recipes:")
    print(f"  Calories:  {df['calories'].mean():.1f} kcal")
    print(f"  Protein:   {df['protein_g'].mean():.1f} g")
    print(f"  Iron:      {df['iron_mg'].mean():.2f} mg")

    # Warn about zero-nutrition recipes (means we don't have DB entries for those ingredients)
    zero_nutr = df[df['calories'] == 0]
    if len(zero_nutr) > 0:
        print(f"\n⚠️  {len(zero_nutr)} recipes have zero nutrition — ingredients not in DB:")
        for _, r in zero_nutr.iterrows():
            print(f"   - {r['recipe_name']}: {r['ingredients_array']}")
        print("   Add these ingredients to NUTRITION_DB above and re-run.")

    df.to_csv(output_path, index=False)
    print(f"\n✅ Saved → {output_path}")
    print("=" * 60)


if __name__ == '__main__':
    main()