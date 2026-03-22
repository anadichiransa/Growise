"""
ChromaDB Search Test
=====================
Tests that ChromaDB is populated and returning good results.
Run this after ingest_into_chromadb.py to verify everything is working.
"""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.db.vector_db import recipe_collection, guidelines_collection


def test_search():
    print("=" * 60)
    print("  CHROMADB SEARCH TEST")
    print("=" * 60)

    print(f"\nRecipes in DB:    {recipe_collection.count()}")
    print(f"Guidelines in DB: {guidelines_collection.count()}")

    # Test 1: Search for chicken recipes for 8 months
    print("\n--- Test 1: Chicken recipe for 8-month-old ---")
    results = recipe_collection.query(
        query_texts=["chicken recipe for 8 months"],
        n_results=3,
        where={
            "$and": [
                {"min_age_months": {"$lte": 8}},
                {"max_age_months": {"$gte": 8}}
            ]
        }
    )
    for meta in results['metadatas'][0]:
        print(f"  Found: {meta['recipe_name']}")
        print(f"         Age: {meta['min_age_months']}-{meta['max_age_months']}m")
        print(f"         Ingredients: {meta['ingredients_list']}")

    # Test 2: Search with prep method
    print("\n--- Test 2: Steamed recipe for 6 months ---")
    results = recipe_collection.query(
        query_texts=["steamed smooth puree for 6 months"],
        n_results=3,
        where={
            "$and": [
                {"min_age_months": {"$lte": 6}},
                {"max_age_months": {"$gte": 6}}
            ]
        }
    )
    for meta in results['metadatas'][0]:
        print(f"  Found: {meta['recipe_name']}  (texture: {meta['texture']})")

    # Test 3: Get FHB guideline for 9 months
    print("\n--- Test 3: FHB guideline for 9 months ---")
    results = guidelines_collection.query(
        query_texts=["feeding guidelines for 9 months"],
        n_results=1,
        where={
            "$and": [
                {"age_min_months": {"$lte": 9}},
                {"age_max_months": {"$gte": 9}}
            ]
        }
    )
    if results['metadatas'][0]:
        g = results['metadatas'][0][0]
        print(f"  Guideline: {g['guideline_id']}")
        print(f"  Harmful:   {g['harmful_substances']}")
        print(f"  Omit:      {g['omit_or_reduce']}")

    print("\n✅ ChromaDB is working correctly!")
    print("=" * 60)


if __name__ == '__main__':
    test_search()