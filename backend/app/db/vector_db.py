"""
ChromaDB Vector Database Setup
================================
Initializes the persistent ChromaDB client and creates two collections:
  1. sri_lankan_recipes  — for semantic recipe search + metadata filtering
  2. fhb_guidelines      — for age-appropriate guideline lookup

The chroma_data/ directory is created automatically and persists between
server restarts. You only need to run ingest_into_chromadb.py once.
"""

import chromadb
from chromadb.config import Settings
from pathlib import Path

# The database lives at backend/chroma_data/
# This path works whether you run from backend/ or backend/app/
chroma_path = Path(__file__).parent.parent.parent / 'chroma_data'
chroma_path.mkdir(exist_ok=True)

# PersistentClient saves everything to disk automatically
client = chromadb.PersistentClient(
    path=str(chroma_path),
    settings=Settings(anonymized_telemetry=False)
)

# Collection 1: Recipes
# get_or_create_collection is safe to call on every startup —
# if the collection exists it returns it, if not it creates it.
recipe_collection = client.get_or_create_collection(
    name='sri_lankan_recipes',
    metadata={'description': 'FHB-tagged Sri Lankan baby food recipes'}
)

# Collection 2: FHB Guidelines
guidelines_collection = client.get_or_create_collection(
    name='fhb_guidelines',
    metadata={'description': 'FHB complementary feeding guidelines by age'}
)

# Log on import so you can see the state at startup
print(" ChromaDB ready")
print(f"   Recipes:    {recipe_collection.count()} items")
print(f"   Guidelines: {guidelines_collection.count()} items")