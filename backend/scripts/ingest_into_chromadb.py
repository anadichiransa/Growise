"""
ChromaDB Ingestion Script
==========================
Loads recipes and FHB guidelines into ChromaDB.
Run once — data persists in chroma_data/ between server restarts.

If you need to reload (e.g. after re-running the pipeline):
  1. Delete the chroma_data/ directory
  2. Re-run this script

Input:  data/processed/recipes_fhb_tagged.csv
        data/raw/fhb_guidelines.json
Output: chroma_data/  (ChromaDB persistent storage)
"""

import pandas as pd
import json
import ast
import sys
from pathlib import Path

# Add backend/ to path so we can import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.db.vector_db import recipe_collection, guidelines_collection


def ingest_recipes():
    """Load all FHB-tagged recipes into the recipe collection."""
    print("\n" + "=" * 60)
    print("  LOADING RECIPES INTO CHROMADB")
    print("=" * 60)

    csv_path = Path('data/processed/recipes_fhb_tagged.csv')
    df = pd.read_csv(csv_path)

    # Convert string representations back to Python lists
    df['ingredients_array'] = df['ingredients_array'].apply(ast.literal_eval)
    df['omit_or_reduce_items'] = df['omit_or_reduce_items'].apply(
        lambda x: ast.literal_eval(x) if pd.notna(x) and str(x).strip() not in ('', '[]') else []
    )

    print(f"\nLoading {len(df)} recipes...\n")

    documents = []
    metadatas = []
    ids       = []

    for idx, row in df.iterrows():
        # ------------------------------------------------------------------
        # DOCUMENT TEXT — this is what ChromaDB embeds and searches against.
        # Include everything a mother might search for: ingredients, texture,
        # category, preparation method. The richer this text, the better
        # the semantic search results.
        # ------------------------------------------------------------------
        document = (
            f"Recipe: {row['recipe_name']}\n"
            f"Category: {row.get('category', 'complementary food')}\n"
            f"Age: {row['min_age_months']}-{row['max_age_months']} months\n"
            f"Ingredients: {', '.join(row['ingredients_array'])}\n"
            f"Texture: {row['texture_tag_aligned']}\n"
            f"Preparation: {row.get('preparation', '')}\n"
            f"Nutrition: {row.get('calories', 0):.0f} calories, "
            f"{row.get('protein_g', 0):.1f}g protein, "
            f"{row.get('iron_mg', 0):.2f}mg iron"
        )

        # ------------------------------------------------------------------
        # METADATA — structured fields used for filtering in queries.
        # ChromaDB metadata values must be: str, int, float, or bool.
        # Lists must be stored as lists of str/int/float/bool.
        # ------------------------------------------------------------------
        metadata = {
            'recipe_name':           str(row['recipe_name']),
            'category':              str(row.get('category', 'complementary food')),
            'min_age_months':        int(row['min_age_months']),
            'max_age_months':        int(row['max_age_months']),
            'ingredients_list':      ", ".join([str(i) for i in row['ingredients_array']]),
            'texture':               str(row['texture_tag_aligned']),
            'preparation':           str(row.get('preparation', '')),
            'calories':              float(row.get('calories') or 0),
            'protein_g':             float(row.get('protein_g') or 0),
            'iron_mg':               float(row.get('iron_mg') or 0),
            'serving_size_g':        float(row.get('serving_size_g') or 100),
            'omit_or_reduce_items':  ", ".join([str(i) for i in row['omit_or_reduce_items']]),
            'modification_required': bool(row.get('modification_required', False)),
            'fhb_safe':              bool(row.get('fhb_safe', True)),
            'fhb_guideline_id':      str(row.get('fhb_guideline_id', '')),
        }

        documents.append(document)
        metadatas.append(metadata)
        ids.append(f"recipe_{idx}")

        print(f"  ✅ {row['recipe_name']}")

    # Add everything to ChromaDB in one batch call
    recipe_collection.add(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )

    print(f"\n✅ Loaded {len(documents)} recipes into ChromaDB")


def ingest_guidelines():
    """Load all FHB guidelines into the guidelines collection."""
    print("\n" + "=" * 60)
    print("  LOADING FHB GUIDELINES INTO CHROMADB")
    print("=" * 60)

    fhb_path = Path('data/raw/fhb_guidelines.json')
    with open(fhb_path) as f:
        fhb_data = json.load(f)

    guidelines = fhb_data['guidelines']
    print(f"\nLoading {len(guidelines)} guidelines...\n")

    documents = []
    metadatas = []
    ids       = []

    for g in guidelines:
        document = (
            f"FHB Guideline: {g.get('guideline_id', '')}\n"
            f"Age Range: {g['age_min_months']}-{g['age_max_months']} months\n"
            f"Harmful Substances (discard recipe): "
            f"{', '.join(g.get('harmful_substances', []))}\n"
            f"Omit or Reduce for baby: "
            f"{', '.join(g.get('omit_or_reduce', []))}\n"
            f"Texture Requirements: "
            f"{', '.join(g['texture_requirements']['tags'])}\n"
            f"Frequency: {g.get('frequency', '')}\n"
            f"Portion Size: {g.get('portion_size', '')}"
        )

        metadata = {
            'guideline_id':       str(g.get('guideline_id', '')),
            'age_min_months':     int(g['age_min_months']),
            'age_max_months':     int(g['age_max_months']),
            'harmful_substances': ", ".join([str(s) for s in g.get('harmful_substances', [])]),
            'omit_or_reduce':     ", ".join([str(s) for s in g.get('omit_or_reduce', [])]),
            'texture_tags':       ", ".join([str(t) for t in g['texture_requirements']['tags']]),
            'frequency':          str(g.get('frequency', '')),
            'portion_size':       str(g.get('portion_size', '')),
        }

        doc_id = g.get('guideline_id', f"guideline_{g['age_min_months']}")

        documents.append(document)
        metadatas.append(metadata)
        ids.append(doc_id)

        print(f"  ✅ {doc_id}  ({g['age_min_months']}-{g['age_max_months']} months)")

    guidelines_collection.add(
        documents=documents,
        metadatas=metadatas,
        ids=ids
    )

    print(f"\n✅ Loaded {len(documents)} guidelines into ChromaDB")


if __name__ == '__main__':
    # Clear existing data to avoid duplicate IDs if re-running
    existing_recipes    = recipe_collection.count()
    existing_guidelines = guidelines_collection.count()

    if existing_recipes > 0 or existing_guidelines > 0:
        print(f"⚠️  ChromaDB already has {existing_recipes} recipes and "
              f"{existing_guidelines} guidelines.")
        print("Deleting existing data and re-ingesting...\n")
        # Reset by deleting all items
        if existing_recipes > 0:
            all_ids = recipe_collection.get()['ids']
            recipe_collection.delete(ids=all_ids)
        if existing_guidelines > 0:
            all_ids = guidelines_collection.get()['ids']
            guidelines_collection.delete(ids=all_ids)

    ingest_recipes()
    ingest_guidelines()

    print("\n" + "=" * 60)
    print("   CHROMADB INGESTION COMPLETE!")
    print("=" * 60)
    print(f"  Recipes loaded:    {recipe_collection.count()}")
    print(f"  Guidelines loaded: {guidelines_collection.count()}")
    print("=" * 60)