"""
Script 1: Ingredient Standardization
=====================================
Converts raw ingredient text into standardized arrays.

Input:  data/raw/sri_lankan_recipes_raw.csv
Output: data/processed/recipes_with_ingredients.csv

New column added: ingredients_array (Python list as string)
"""

import pandas as pd
import re
from pathlib import Path

# ------------------------------------------------------------------
# INGREDIENT MAPPING
# Maps all the different ways an ingredient is written in recipes
# to one standardized name. Add more entries if your CSV uses
# different spellings.
# ------------------------------------------------------------------
INGREDIENT_MAPPING = {
    # Grains
    'rice':           'rice',
    'red rice':       'red_rice',
    'rice flour':     'rice_flour',
    'white bread':    'bread',
    'bread':          'bread',

    # Legumes / Proteins
    'red lentils':    'red_lentils',
    'dhal':           'red_lentils',
    'dal':            'red_lentils',
    'green gram':     'mung_beans',
    'mung bean':      'mung_beans',
    'mung beans':     'mung_beans',
    'dried sprats':   'sprats',
    'sprats powder':  'sprats',
    'sprats':         'sprats',
    'chicken':        'chicken',
    'chicken breast': 'chicken',
    'chicken liver':  'chicken_liver',
    'liver':          'chicken_liver',
    'fish':           'fish',
    'thalapath fish': 'fish',
    'egg':            'egg',
    'egg yolk':       'egg_yolk',
    'boiled egg yolk':'egg_yolk',

    # Vegetables
    'pumpkin':        'pumpkin',
    'carrot':         'carrot',
    'sweet potato':   'sweet_potato',
    'potato':         'potato',
    'gotukola':       'gotukola',
    'gotu kola':      'gotukola',
    'beetroot':       'beetroot',
    'leeks':          'leeks',
    'beans':          'beans',
    'green beans':    'beans',

    # Fruits
    'ripe papaya':    'papaya',
    'papaya':         'papaya',
    'ripe banana':    'banana',
    'ambul banana':   'banana',
    'banana':         'banana',
    'ripe avocado':   'avocado',
    'avocado':        'avocado',
    'ripe jakfruit':  'jakfruit',
    'jakfruit':       'jakfruit',
    'jackfruit':      'jakfruit',
    'breadfruit':     'breadfruit',
    'apple':          'apple',

    # Dairy / Fats
    'curd':           'curd',
    'yoghurt':        'yoghurt',
    'plain yoghurt':  'yoghurt',
    'coconut milk':   'coconut_milk',
    'thick coconut milk': 'coconut_milk',
    'expressed breast milk': 'breast_milk',
    'breast milk':    'breast_milk',
    'water':          'water',
    'king coconut water': 'king_coconut_water',
    'unsalted butter':'butter',
    'butter':         'butter',
    'oil':            'oil',
    'coconut oil':    'oil',

    # Spices / Seasonings
    'turmeric':       'turmeric',
    'cinnamon':       'cinnamon',
    'curry leaves':   'curry_leaves',
    'salt':           'salt',       # FHB says to omit for babies
    'sugar':          'sugar',      # FHB says to omit for babies
    'pepper':         'pepper',
    'chili':          'chili',
    'chilli':         'chili',
}


def clean_ingredient_text(ingredient: str) -> str:
    """
    Remove measurements and extra words from a single ingredient string.
    
    Examples:
        "2 tbsp rice"         → "rice"
        "1/2 cup coconut milk"→ "coconut milk"
        "carrot (small)"      → "carrot"
    """
    ingredient = ingredient.strip().lower()
    # Remove quantities and units
    ingredient = re.sub(r'\d+\s*(tbsp|tsp|cup|cups|ml|g|piece|pieces|small|medium|large)', '', ingredient)
    # Remove fractions like 1/2
    ingredient = re.sub(r'\d+/\d+', '', ingredient)
    # Remove standalone numbers
    ingredient = re.sub(r'^\d+\s*', '', ingredient)
    # Remove anything in brackets
    ingredient = re.sub(r'\([^)]*\)', '', ingredient)
    return ingredient.strip()


def standardize_ingredients(ingredients_text: str) -> list:
    """
    Convert a raw ingredients string into a standardized list.
    
    Input:  "rice, red lentils, 1 tsp turmeric, water"
    Output: ['rice', 'red_lentils', 'turmeric', 'water']
    """
    if pd.isna(ingredients_text) or not str(ingredients_text).strip():
        return []

    # Split on commas (most recipes use comma-separated ingredients)
    raw_parts = [p.strip() for p in str(ingredients_text).split(',')]

    standardized = []
    for raw in raw_parts:
        cleaned = clean_ingredient_text(raw)
        if not cleaned:
            continue
        # Look up in mapping — if not found, keep the cleaned name as-is
        std = INGREDIENT_MAPPING.get(cleaned, cleaned)
        if std and std not in standardized:
            standardized.append(std)

    return standardized


def main():
    print("=" * 60)
    print("  SCRIPT 1: INGREDIENT STANDARDIZATION")
    print("=" * 60)

    input_path  = Path('data/raw/sri_lankan_recipes_raw.csv')
    output_path = Path('data/processed/recipes_with_ingredients.csv')
    output_path.parent.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(input_path)
    print(f"\nLoaded {len(df)} recipes from {input_path}")

    # Apply standardization
    df['ingredients_array'] = df['ingredients'].apply(standardize_ingredients)
    df['ingredient_count']  = df['ingredients_array'].apply(len)

    # Show examples so you can verify the mapping is correct
    print("\nSample results:")
    for _, row in df.head(5).iterrows():
        print(f"\n  Recipe: {row['recipe_name']}")
        print(f"  Raw:    {row['ingredients'][:80]}...")
        print(f"  Array:  {row['ingredients_array']}")

    # Warn about any recipes with very few ingredients (likely a parse problem)
    few_ings = df[df['ingredient_count'] < 2]
    if len(few_ings) > 0:
        print(f"\n⚠️  {len(few_ings)} recipes have fewer than 2 ingredients — check these:")
        for _, r in few_ings.iterrows():
            print(f"   - {r['recipe_name']}: {r['ingredients_array']}")

    df.to_csv(output_path, index=False)
    print(f"\n✅ Saved {len(df)} recipes → {output_path}")
    print("=" * 60)


if __name__ == '__main__':
    main()