"""
FHB Harmful Substance Tagging
================================
Reads fhb_guidelines.json and tags every recipe.

DISCARD: recipe contains honey, raw egg, or any FHB harmful substance
KEEP:    recipe is safe or only needs modification (salt, sugar)

Input:  data/processed/recipes_aligned.csv
        data/raw/fhb_guidelines.json
Output: data/processed/recipes_fhb_tagged.csv

New columns:
  omit_or_reduce_items  — list of items mother should omit for baby's portion
  modification_required — True if omit_or_reduce_items is not empty
  fhb_safe              — True if no omit/reduce items at all
  fhb_guideline_id      — which guideline was applied
"""

import pandas as pd
import json
import ast
from pathlib import Path


def find_guideline(age_months: int, guidelines: list) -> dict:
    """Find the FHB guideline that covers a given age in months."""
    for g in guidelines:
        if g['age_min_months'] <= age_months <= g['age_max_months']:
            return g
    # Fallback: return the most permissive (highest age) guideline
    return guidelines[-1]


def tag_recipes():
    print("=" * 60)
    print("  FHB HARMFUL SUBSTANCE TAGGING")
    print("=" * 60)

    csv_path = Path('data/processed/recipes_aligned.csv')
    fhb_path = Path('data/raw/fhb_guidelines.json')

    df = pd.read_csv(csv_path)
    df['ingredients_array'] = df['ingredients_array'].apply(ast.literal_eval)

    with open(fhb_path) as f:
        fhb_data = json.load(f)

    guidelines = fhb_data['guidelines']
    print(f"\nTagging {len(df)} recipes against {len(guidelines)} FHB guidelines...\n")

    kept     = []
    discarded = 0

    for _, row in df.iterrows():
        guideline = find_guideline(int(row['min_age_months']), guidelines)

        harmful_substances = guideline.get('harmful_substances', [])
        omit_or_reduce     = guideline.get('omit_or_reduce', [])
        ings               = row['ingredients_array']

        # Check if recipe contains any HARMFUL substances
        found_harmful = []
        for substance in harmful_substances:
            for ing in ings:
                if substance.lower() in ing.lower():
                    found_harmful.append(substance)

        if found_harmful:
            print(f"  ❌ DISCARD: {row['recipe_name']}")
            print(f"             Contains harmful: {list(set(found_harmful))}")
            discarded += 1
            continue  # Do not add to kept list

        # Check for items that need MODIFICATION (salt, sugar, etc.)
        found_omit = []
        for item in omit_or_reduce:
            for ing in ings:
                if item.lower() in ing.lower():
                    found_omit.append(item)
        found_omit = list(set(found_omit))  # deduplicate

        # Add the recipe with FHB tags
        recipe = row.to_dict()
        recipe['omit_or_reduce_items']   = found_omit
        recipe['modification_required']  = bool(found_omit)
        recipe['fhb_safe']               = not bool(found_omit)
        recipe['fhb_guideline_id']       = guideline.get('guideline_id', f"FHB_{row['min_age_months']}_MONTHS")

        if found_omit:
            print(f"  ⚠️  KEEP (modify): {row['recipe_name']}")
            print(f"                    Mother should omit: {found_omit}")
        else:
            print(f"  ✅ KEEP (safe): {row['recipe_name']}")

        kept.append(recipe)

    # Summary
    print("\n" + "=" * 60)
    print("TAGGING SUMMARY")
    print("=" * 60)
    print(f"Total recipes processed:  {len(df)}")
    print(f"Discarded (harmful):      {discarded}")
    print(f"Kept (safe as-is):        {sum(1 for r in kept if r['fhb_safe'])}")
    print(f"Kept (needs modification):{sum(1 for r in kept if r['modification_required'])}")
    print(f"Total kept:               {len(kept)}")

    output_path = Path('data/processed/recipes_fhb_tagged.csv')
    pd.DataFrame(kept).to_csv(output_path, index=False)
    print(f"\n✅ Saved {len(kept)} tagged recipes → {output_path}")
    print("=" * 60)


if __name__ == '__main__':
    tag_recipes()