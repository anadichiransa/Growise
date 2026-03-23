"""
Script 3: Align Texture Tags with FHB Standard
================================================
Maps recipe texture descriptions to FHB-standard tags and
derives min/max age ranges from those tags.

Input:  data/processed/recipes_with_nutrition.csv
Output: data/processed/recipes_aligned.csv

New columns: texture_tag_aligned, min_age_months, max_age_months
"""

import pandas as pd
from pathlib import Path

# ------------------------------------------------------------------
# TEXTURE MAPPING
# Maps how textures are described in your CSV to the FHB standard tags.
# Add more entries if your CSV uses different wording.
# ------------------------------------------------------------------
TEXTURE_MAP = {
    'smooth':              'smooth_puree',
    'smooth puree':        'smooth_puree',
    'smooth_puree':        'smooth_puree',
    'pureed':              'smooth_puree',
    'puree':               'smooth_puree',
    'liquid':              'smooth_puree',
    'well mashed':         'well_mashed',
    'well-mashed':         'well_mashed',
    'well_mashed':         'well_mashed',
    'mashed':              'well_mashed',
    'soft':                'soft_lumpy',
    'soft lumpy':          'soft_lumpy',
    'soft_lumpy':          'soft_lumpy',
    'lumpy':               'soft_lumpy',
    'chunky':              'soft_chunky',
    'soft chunky':         'soft_chunky',
    'soft_chunky':         'soft_chunky',
    'coarsely_chopped':    'soft_pieces',
    'finger_food':         'soft_pieces',
    'finger food':         'soft_pieces',
    'family':              'family_foods',
    'family foods':        'family_foods',
    'family_foods':        'family_foods',
    'normal':              'family_foods',
}

# ------------------------------------------------------------------
# AGE RANGES PER TEXTURE TAG
# (min_age_months, max_age_months) — aligns with FHB guidelines
# ------------------------------------------------------------------
AGE_RANGE = {
    'smooth_puree': (6, 7),
    'well_mashed':  (6, 9),
    'soft_lumpy':   (8, 11),
    'soft_chunky':  (9, 24),
    'soft_pieces':  (12, 24),
    'family_foods': (12, 24),
}


def main():
    print("=" * 60)
    print("  SCRIPT 3: ALIGN TEXTURE TAGS")
    print("=" * 60)

    input_path  = Path('data/processed/recipes_with_nutrition.csv')
    output_path = Path('data/processed/recipes_aligned.csv')

    df = pd.read_csv(input_path)
    print(f"\nProcessing {len(df)} recipes...")

    # Find the texture column — it might be named 'texture' or 'texture_tag'
    texture_col = None
    for col in ['texture', 'texture_tag', 'Texture', 'food_texture']:
        if col in df.columns:
            texture_col = col
            break

    if texture_col is None:
        print("⚠️  No texture column found. Defaulting all recipes to 'well_mashed'.")
        df['texture_raw'] = 'well_mashed'
    else:
        df['texture_raw'] = df[texture_col].str.lower().str.strip()

    # Apply the mapping
    df['texture_tag_aligned'] = df['texture_raw'].map(TEXTURE_MAP)

    # Unmapped textures — show them so you can add to TEXTURE_MAP
    unmapped = df[df['texture_tag_aligned'].isna()]['texture_raw'].unique()
    if len(unmapped) > 0:
        print("\n⚠️  These texture values were not mapped (defaulting to 'well_mashed'):")
        for t in unmapped:
            print(f"   '{t}' — add to TEXTURE_MAP if needed")
    df['texture_tag_aligned'] = df['texture_tag_aligned'].fillna('well_mashed')

    # Assign age ranges from texture
    df['min_age_months'] = df['texture_tag_aligned'].map(lambda t: AGE_RANGE.get(t, (6, 24))[0])
    df['max_age_months'] = df['texture_tag_aligned'].map(lambda t: AGE_RANGE.get(t, (6, 24))[1])

    # Show distribution
    print("\nTexture distribution after alignment:")
    dist = df.groupby('texture_tag_aligned').size()
    for texture, count in dist.items():
        age = AGE_RANGE.get(texture, ('?', '?'))
        print(f"   {texture:<18} {count:>3} recipes   age {age[0]}-{age[1]} months")

    df.to_csv(output_path, index=False)
    print(f"\n✅ Saved → {output_path}")
    print("=" * 60)


if __name__ == '__main__':
    main()