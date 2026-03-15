"""
WHO Growth Standards Data Seeder
Run this ONCE to populate Firestore with WHO 2006 data.

Usage:
    cd backend/app
    python seed_who_data.py

Collections created:
    - whoWeightBoys   (Weight-for-Age, boys, 0-24 months)
    - whoHeightBoys   (Height-for-Age, boys, 0-24 months)
    - whoBMIBoys      (BMI-for-Age, boys, 0-24 months)

Each document has:
    - month: int (0-24)
    - sd_minus3: float
    - sd_minus2: float
    - sd_minus1: float
    - median: float
    - sd_plus1: float
    - sd_plus2: float
    - sd_plus3: float
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

# ── Firebase init ─────────────────────────────────────────────────────────────

def init_firebase():
    key_path = os.path.join(os.path.dirname(__file__), "firebase", "serviceAccountKey.json")
    cred = credentials.Certificate(key_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()


# ── WHO Weight-for-Age Boys (0–24 months) ─────────────────────────────────────
# Source: WHO Child Growth Standards, 2006
# Columns: month, -3SD, -2SD, -1SD, median, +1SD, +2SD, +3SD

WHO_WEIGHT_BOYS = [
    {"month": 0,  "sd_minus3": 2.1, "sd_minus2": 2.5, "sd_minus1": 2.9, "median": 3.3, "sd_plus1": 3.9, "sd_plus2": 4.4, "sd_plus3": 5.0},
    {"month": 1,  "sd_minus3": 2.9, "sd_minus2": 3.4, "sd_minus1": 3.9, "median": 4.5, "sd_plus1": 5.1, "sd_plus2": 5.8, "sd_plus3": 6.6},
    {"month": 2,  "sd_minus3": 3.8, "sd_minus2": 4.3, "sd_minus1": 4.9, "median": 5.6, "sd_plus1": 6.3, "sd_plus2": 7.1, "sd_plus3": 8.0},
    {"month": 3,  "sd_minus3": 4.4, "sd_minus2": 5.0, "sd_minus1": 5.7, "median": 6.4, "sd_plus1": 7.2, "sd_plus2": 8.0, "sd_plus3": 9.0},
    {"month": 4,  "sd_minus3": 4.9, "sd_minus2": 5.6, "sd_minus1": 6.2, "median": 7.0, "sd_plus1": 7.8, "sd_plus2": 8.7, "sd_plus3": 9.7},
    {"month": 5,  "sd_minus3": 5.3, "sd_minus2": 6.0, "sd_minus1": 6.7, "median": 7.5, "sd_plus1": 8.4, "sd_plus2": 9.3, "sd_plus3": 10.4},
    {"month": 6,  "sd_minus3": 5.7, "sd_minus2": 6.4, "sd_minus1": 7.1, "median": 7.9, "sd_plus1": 8.8, "sd_plus2": 9.8, "sd_plus3": 10.9},
    {"month": 7,  "sd_minus3": 5.9, "sd_minus2": 6.7, "sd_minus1": 7.4, "median": 8.3, "sd_plus1": 9.2, "sd_plus2": 10.3, "sd_plus3": 11.4},
    {"month": 8,  "sd_minus3": 6.2, "sd_minus2": 7.0, "sd_minus1": 7.7, "median": 8.6, "sd_plus1": 9.6, "sd_plus2": 10.7, "sd_plus3": 11.9},
    {"month": 9,  "sd_minus3": 6.4, "sd_minus2": 7.2, "sd_minus1": 8.0, "median": 8.9, "sd_plus1": 9.9, "sd_plus2": 11.0, "sd_plus3": 12.3},
    {"month": 10, "sd_minus3": 6.6, "sd_minus2": 7.5, "sd_minus1": 8.2, "median": 9.2, "sd_plus1": 10.2, "sd_plus2": 11.4, "sd_plus3": 12.7},
    {"month": 11, "sd_minus3": 6.8, "sd_minus2": 7.7, "sd_minus1": 8.5, "median": 9.4, "sd_plus1": 10.5, "sd_plus2": 11.7, "sd_plus3": 13.0},
    {"month": 12, "sd_minus3": 6.9, "sd_minus2": 7.8, "sd_minus1": 8.6, "median": 9.6, "sd_plus1": 10.8, "sd_plus2": 12.0, "sd_plus3": 13.3},
    {"month": 13, "sd_minus3": 7.1, "sd_minus2": 8.0, "sd_minus1": 8.9, "median": 9.9, "sd_plus1": 11.0, "sd_plus2": 12.3, "sd_plus3": 13.7},
    {"month": 14, "sd_minus3": 7.2, "sd_minus2": 8.1, "sd_minus1": 9.0, "median": 10.1, "sd_plus1": 11.3, "sd_plus2": 12.6, "sd_plus3": 14.0},
    {"month": 15, "sd_minus3": 7.4, "sd_minus2": 8.3, "sd_minus1": 9.2, "median": 10.3, "sd_plus1": 11.5, "sd_plus2": 12.8, "sd_plus3": 14.3},
    {"month": 16, "sd_minus3": 7.5, "sd_minus2": 8.4, "sd_minus1": 9.4, "median": 10.5, "sd_plus1": 11.7, "sd_plus2": 13.1, "sd_plus3": 14.6},
    {"month": 17, "sd_minus3": 7.6, "sd_minus2": 8.6, "sd_minus1": 9.5, "median": 10.7, "sd_plus1": 11.9, "sd_plus2": 13.3, "sd_plus3": 14.9},
    {"month": 18, "sd_minus3": 7.8, "sd_minus2": 8.8, "sd_minus1": 9.7, "median": 10.9, "sd_plus1": 12.2, "sd_plus2": 13.6, "sd_plus3": 15.2},
    {"month": 19, "sd_minus3": 7.9, "sd_minus2": 8.9, "sd_minus1": 9.9, "median": 11.1, "sd_plus1": 12.4, "sd_plus2": 13.8, "sd_plus3": 15.5},
    {"month": 20, "sd_minus3": 8.0, "sd_minus2": 9.0, "sd_minus1": 10.1, "median": 11.3, "sd_plus1": 12.6, "sd_plus2": 14.1, "sd_plus3": 15.7},
    {"month": 21, "sd_minus3": 8.2, "sd_minus2": 9.2, "sd_minus1": 10.2, "median": 11.5, "sd_plus1": 12.9, "sd_plus2": 14.4, "sd_plus3": 16.1},
    {"month": 22, "sd_minus3": 8.3, "sd_minus2": 9.3, "sd_minus1": 10.4, "median": 11.8, "sd_plus1": 13.1, "sd_plus2": 14.7, "sd_plus3": 16.4},
    {"month": 23, "sd_minus3": 8.4, "sd_minus2": 9.5, "sd_minus1": 10.6, "median": 11.9, "sd_plus1": 13.4, "sd_plus2": 14.9, "sd_plus3": 16.7},
    {"month": 24, "sd_minus3": 8.6, "sd_minus2": 9.7, "sd_minus1": 10.8, "median": 12.2, "sd_plus1": 13.6, "sd_plus2": 15.3, "sd_plus3": 17.1},
]

# ── WHO Height-for-Age Boys (0–24 months) ─────────────────────────────────────

WHO_HEIGHT_BOYS = [
    {"month": 0,  "sd_minus3": 44.2, "sd_minus2": 46.1, "sd_minus1": 48.0, "median": 49.9, "sd_plus1": 51.8, "sd_plus2": 53.7, "sd_plus3": 55.6},
    {"month": 1,  "sd_minus3": 48.9, "sd_minus2": 50.8, "sd_minus1": 52.8, "median": 54.7, "sd_plus1": 56.7, "sd_plus2": 58.6, "sd_plus3": 60.6},
    {"month": 2,  "sd_minus3": 52.4, "sd_minus2": 54.4, "sd_minus1": 56.4, "median": 58.4, "sd_plus1": 60.4, "sd_plus2": 62.4, "sd_plus3": 64.4},
    {"month": 3,  "sd_minus3": 55.3, "sd_minus2": 57.3, "sd_minus1": 59.4, "median": 61.4, "sd_plus1": 63.5, "sd_plus2": 65.5, "sd_plus3": 67.6},
    {"month": 4,  "sd_minus3": 57.6, "sd_minus2": 59.7, "sd_minus1": 61.8, "median": 63.9, "sd_plus1": 66.0, "sd_plus2": 68.0, "sd_plus3": 70.1},
    {"month": 5,  "sd_minus3": 59.6, "sd_minus2": 61.7, "sd_minus1": 63.8, "median": 65.9, "sd_plus1": 68.0, "sd_plus2": 70.1, "sd_plus3": 72.2},
    {"month": 6,  "sd_minus3": 61.2, "sd_minus2": 63.3, "sd_minus1": 65.5, "median": 67.6, "sd_plus1": 69.8, "sd_plus2": 71.9, "sd_plus3": 74.0},
    {"month": 7,  "sd_minus3": 62.7, "sd_minus2": 64.8, "sd_minus1": 67.0, "median": 69.2, "sd_plus1": 71.3, "sd_plus2": 73.5, "sd_plus3": 75.7},
    {"month": 8,  "sd_minus3": 64.0, "sd_minus2": 66.2, "sd_minus1": 68.4, "median": 70.6, "sd_plus1": 72.8, "sd_plus2": 75.0, "sd_plus3": 77.2},
    {"month": 9,  "sd_minus3": 65.2, "sd_minus2": 67.5, "sd_minus1": 69.7, "median": 72.0, "sd_plus1": 74.2, "sd_plus2": 76.5, "sd_plus3": 78.7},
    {"month": 10, "sd_minus3": 66.4, "sd_minus2": 68.7, "sd_minus1": 71.0, "median": 73.3, "sd_plus1": 75.6, "sd_plus2": 77.9, "sd_plus3": 80.2},
    {"month": 11, "sd_minus3": 67.6, "sd_minus2": 69.9, "sd_minus1": 72.2, "median": 74.5, "sd_plus1": 76.9, "sd_plus2": 79.2, "sd_plus3": 81.5},
    {"month": 12, "sd_minus3": 68.6, "sd_minus2": 71.0, "sd_minus1": 73.4, "median": 75.7, "sd_plus1": 78.1, "sd_plus2": 80.5, "sd_plus3": 82.9},
    {"month": 13, "sd_minus3": 69.8, "sd_minus2": 72.1, "sd_minus1": 74.5, "median": 76.9, "sd_plus1": 79.3, "sd_plus2": 81.8, "sd_plus3": 84.2},
    {"month": 14, "sd_minus3": 70.8, "sd_minus2": 73.1, "sd_minus1": 75.6, "median": 78.0, "sd_plus1": 80.5, "sd_plus2": 82.9, "sd_plus3": 85.4},
    {"month": 15, "sd_minus3": 71.7, "sd_minus2": 74.1, "sd_minus1": 76.6, "median": 79.1, "sd_plus1": 81.6, "sd_plus2": 84.1, "sd_plus3": 86.6},
    {"month": 16, "sd_minus3": 72.7, "sd_minus2": 75.2, "sd_minus1": 77.7, "median": 80.2, "sd_plus1": 82.7, "sd_plus2": 85.2, "sd_plus3": 87.8},
    {"month": 17, "sd_minus3": 73.6, "sd_minus2": 76.1, "sd_minus1": 78.7, "median": 81.2, "sd_plus1": 83.7, "sd_plus2": 86.3, "sd_plus3": 88.8},
    {"month": 18, "sd_minus3": 74.5, "sd_minus2": 77.1, "sd_minus1": 79.7, "median": 82.3, "sd_plus1": 84.9, "sd_plus2": 87.5, "sd_plus3": 90.1},
    {"month": 19, "sd_minus3": 75.3, "sd_minus2": 78.0, "sd_minus1": 80.6, "median": 83.2, "sd_plus1": 85.9, "sd_plus2": 88.5, "sd_plus3": 91.2},
    {"month": 20, "sd_minus3": 76.2, "sd_minus2": 78.9, "sd_minus1": 81.5, "median": 84.2, "sd_plus1": 86.8, "sd_plus2": 89.5, "sd_plus3": 92.2},
    {"month": 21, "sd_minus3": 77.0, "sd_minus2": 79.7, "sd_minus1": 82.4, "median": 85.1, "sd_plus1": 87.9, "sd_plus2": 90.6, "sd_plus3": 93.3},
    {"month": 22, "sd_minus3": 77.8, "sd_minus2": 80.5, "sd_minus1": 83.3, "median": 86.0, "sd_plus1": 88.8, "sd_plus2": 91.5, "sd_plus3": 94.3},
    {"month": 23, "sd_minus3": 78.6, "sd_minus2": 81.3, "sd_minus1": 84.1, "median": 86.9, "sd_plus1": 89.7, "sd_plus2": 92.5, "sd_plus3": 95.3},
    {"month": 24, "sd_minus3": 79.3, "sd_minus2": 82.1, "sd_minus1": 85.0, "median": 87.8, "sd_plus1": 90.7, "sd_plus2": 93.5, "sd_plus3": 96.4},
]

# ── WHO BMI-for-Age Boys (0–24 months) ────────────────────────────────────────

WHO_BMI_BOYS = [
    {"month": 0,  "sd_minus3": 10.2, "sd_minus2": 11.1, "sd_minus1": 12.2, "median": 13.4, "sd_plus1": 14.8, "sd_plus2": 16.3, "sd_plus3": 18.1},
    {"month": 1,  "sd_minus3": 11.3, "sd_minus2": 12.4, "sd_minus1": 13.6, "median": 14.9, "sd_plus1": 16.3, "sd_plus2": 17.8, "sd_plus3": 19.4},
    {"month": 2,  "sd_minus3": 12.5, "sd_minus2": 13.5, "sd_minus1": 14.7, "median": 16.0, "sd_plus1": 17.4, "sd_plus2": 18.8, "sd_plus3": 20.3},
    {"month": 3,  "sd_minus3": 12.5, "sd_minus2": 13.5, "sd_minus1": 14.6, "median": 15.9, "sd_plus1": 17.2, "sd_plus2": 18.7, "sd_plus3": 20.3},
    {"month": 4,  "sd_minus3": 12.3, "sd_minus2": 13.3, "sd_minus1": 14.4, "median": 15.6, "sd_plus1": 17.0, "sd_plus2": 18.4, "sd_plus3": 20.1},
    {"month": 5,  "sd_minus3": 12.1, "sd_minus2": 13.1, "sd_minus1": 14.2, "median": 15.4, "sd_plus1": 16.7, "sd_plus2": 18.2, "sd_plus3": 19.8},
    {"month": 6,  "sd_minus3": 12.0, "sd_minus2": 13.0, "sd_minus1": 14.1, "median": 15.3, "sd_plus1": 16.6, "sd_plus2": 18.0, "sd_plus3": 19.7},
    {"month": 7,  "sd_minus3": 11.8, "sd_minus2": 12.8, "sd_minus1": 13.9, "median": 15.2, "sd_plus1": 16.5, "sd_plus2": 17.9, "sd_plus3": 19.6},
    {"month": 8,  "sd_minus3": 11.7, "sd_minus2": 12.7, "sd_minus1": 13.8, "median": 15.0, "sd_plus1": 16.3, "sd_plus2": 17.8, "sd_plus3": 19.4},
    {"month": 9,  "sd_minus3": 11.6, "sd_minus2": 12.6, "sd_minus1": 13.7, "median": 14.9, "sd_plus1": 16.2, "sd_plus2": 17.7, "sd_plus3": 19.3},
    {"month": 10, "sd_minus3": 11.5, "sd_minus2": 12.5, "sd_minus1": 13.6, "median": 14.8, "sd_plus1": 16.1, "sd_plus2": 17.6, "sd_plus3": 19.2},
    {"month": 11, "sd_minus3": 11.4, "sd_minus2": 12.4, "sd_minus1": 13.5, "median": 14.7, "sd_plus1": 16.0, "sd_plus2": 17.5, "sd_plus3": 19.1},
    {"month": 12, "sd_minus3": 11.3, "sd_minus2": 12.3, "sd_minus1": 13.4, "median": 14.7, "sd_plus1": 16.0, "sd_plus2": 17.4, "sd_plus3": 19.1},
    {"month": 13, "sd_minus3": 11.2, "sd_minus2": 12.2, "sd_minus1": 13.3, "median": 14.6, "sd_plus1": 15.9, "sd_plus2": 17.4, "sd_plus3": 19.0},
    {"month": 14, "sd_minus3": 11.2, "sd_minus2": 12.1, "sd_minus1": 13.3, "median": 14.5, "sd_plus1": 15.8, "sd_plus2": 17.3, "sd_plus3": 18.9},
    {"month": 15, "sd_minus3": 11.1, "sd_minus2": 12.1, "sd_minus1": 13.2, "median": 14.4, "sd_plus1": 15.8, "sd_plus2": 17.2, "sd_plus3": 18.9},
    {"month": 16, "sd_minus3": 11.0, "sd_minus2": 12.0, "sd_minus1": 13.1, "median": 14.4, "sd_plus1": 15.7, "sd_plus2": 17.2, "sd_plus3": 18.8},
    {"month": 17, "sd_minus3": 11.0, "sd_minus2": 12.0, "sd_minus1": 13.1, "median": 14.3, "sd_plus1": 15.6, "sd_plus2": 17.1, "sd_plus3": 18.7},
    {"month": 18, "sd_minus3": 10.9, "sd_minus2": 11.9, "sd_minus1": 13.0, "median": 14.3, "sd_plus1": 15.6, "sd_plus2": 17.1, "sd_plus3": 18.7},
    {"month": 19, "sd_minus3": 10.9, "sd_minus2": 11.9, "sd_minus1": 13.0, "median": 14.2, "sd_plus1": 15.5, "sd_plus2": 17.0, "sd_plus3": 18.6},
    {"month": 20, "sd_minus3": 10.8, "sd_minus2": 11.8, "sd_minus1": 12.9, "median": 14.2, "sd_plus1": 15.5, "sd_plus2": 17.0, "sd_plus3": 18.6},
    {"month": 21, "sd_minus3": 10.8, "sd_minus2": 11.8, "sd_minus1": 12.9, "median": 14.1, "sd_plus1": 15.5, "sd_plus2": 16.9, "sd_plus3": 18.6},
    {"month": 22, "sd_minus3": 10.7, "sd_minus2": 11.7, "sd_minus1": 12.8, "median": 14.1, "sd_plus1": 15.4, "sd_plus2": 16.9, "sd_plus3": 18.5},
    {"month": 23, "sd_minus3": 10.7, "sd_minus2": 11.7, "sd_minus1": 12.8, "median": 14.0, "sd_plus1": 15.4, "sd_plus2": 16.9, "sd_plus3": 18.5},
    {"month": 24, "sd_minus3": 10.6, "sd_minus2": 11.6, "sd_minus1": 12.8, "median": 14.0, "sd_plus1": 15.4, "sd_plus2": 16.8, "sd_plus3": 18.5},
]


# ── Seed function ─────────────────────────────────────────────────────────────

def seed_collection(db, collection_name: str, data: list):
    col = db.collection(collection_name)

    # Check if already seeded
    existing = list(col.limit(1).stream())
    if existing:
        print(f"⚠️  '{collection_name}' already has data — skipping.")
        return

    print(f"🌱 Seeding '{collection_name}' ({len(data)} documents)...")
    for entry in data:
        doc_id = f"month_{entry['month']:02d}"
        col.document(doc_id).set(entry)

    print(f"✅ '{collection_name}' seeded successfully!")


def main():
    print("=" * 50)
    print("GrowIse WHO Data Seeder")
    print("=" * 50)

    db = init_firebase()

    seed_collection(db, "whoWeightBoys", WHO_WEIGHT_BOYS)
    seed_collection(db, "whoHeightBoys", WHO_HEIGHT_BOYS)
    seed_collection(db, "whoBMIBoys",    WHO_BMI_BOYS)

    print("=" * 50)
    print("✅ All WHO data seeded into Firestore!")
    print("Collections created:")
    print("  - whoWeightBoys (25 documents)")
    print("  - whoHeightBoys (25 documents)")
    print("  - whoBMIBoys    (25 documents)")
    print("=" * 50)


if __name__ == "__main__":
    main()