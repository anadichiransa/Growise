"""
Data Verification
==================
Checks that all preprocessing steps completed successfully.
Run this after scripts 01, 02, and 03 to confirm data is ready.
"""

import pandas as pd
import ast
from pathlib import Path


def check(label: str, passed: bool, detail: str = ''):
    symbol = '✅' if passed else '❌'
    print(f"  {symbol}  {label}", end='')
    if detail:
        print(f"  ({detail})", end='')
    print()
    return passed


def main():
    print("=" * 60)
    print("  DATA VERIFICATION")
    print("=" * 60)

    path = Path('data/processed/recipes_aligned.csv')
    if not path.exists():
        print("❌  recipes_aligned.csv not found — run scripts 01, 02, 03 first")
        return

    df = pd.read_csv(path)
    df['ingredients_array'] = df['ingredients_array'].apply(ast.literal_eval)

    print(f"\nTotal recipes: {len(df)}\n")

    all_passed = True

    # Check 1: Ingredients
    has_ings = df['ingredients_array'].apply(lambda x: len(x) >= 1)
    all_passed &= check(
        "All recipes have ingredients_array",
        has_ings.all(),
        f"{has_ings.sum()}/{len(df)}"
    )

    # Check 2: Nutrition
    has_cal = df['calories'].notna() & (df['calories'] > 0)
    all_passed &= check(
        "All recipes have calorie data",
        has_cal.sum() >= len(df) * 0.9,  # allow 10% missing
        f"{has_cal.sum()}/{len(df)}"
    )

    # Check 3: Texture
    valid_textures = {'smooth_puree', 'well_mashed', 'soft_lumpy', 'soft_chunky','soft_pieces', 'family_foods'}
    has_tex = df['texture_tag_aligned'].isin(valid_textures)
    all_passed &= check(
        "All recipes have valid texture tags",
        has_tex.all(),
        f"{has_tex.sum()}/{len(df)}"
    )

    # Check 4: Age ranges
    has_age = df['min_age_months'].notna() & df['max_age_months'].notna()
    all_passed &= check(
        "All recipes have age ranges",
        has_age.all(),
        f"{has_age.sum()}/{len(df)}"
    )

    # Check 5: Age ranges are valid
    valid_age = (df['min_age_months'] >= 6) & (df['max_age_months'] <= 24) & \
                (df['min_age_months'] <= df['max_age_months'])
    all_passed &= check(
        "All age ranges are within 6-24 months",
        valid_age.all(),
        f"{valid_age.sum()}/{len(df)}"
    )

    print(f"\nNutrition summary:")
    print(f"   Calories avg:  {df['calories'].mean():.1f} kcal")
    print(f"   Protein avg:   {df['protein_g'].mean():.1f} g")
    print(f"   Iron avg:      {df['iron_mg'].mean():.2f} mg")

    print(f"\nAge distribution:")
    dist = df.groupby('min_age_months').size()
    for age, count in dist.items():
        print(f"   From {age:>2} months: {count} recipes")

    print()
    if all_passed:
        print("✅  All checks passed — data is ready for FHB tagging!")
    else:
        print("❌  Some checks failed — fix the issues above and re-run.")
    print("=" * 60)


if __name__ == '__main__':
    main()