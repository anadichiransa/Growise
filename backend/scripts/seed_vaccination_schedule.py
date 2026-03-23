import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import firebase_admin
from firebase_admin import credentials, firestore

# Init Firebase 

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

#  Master Vaccine Data
VACCINES = [
    {
        "vaccine_id": "bcg",
        "vaccine_name": "BCG Vaccine",
        "age_months": 0,
        "age_label": "At Birth",
        "diseases_prevented": ["Tuberculosis (TB)"],
        "dose_number": 1,
        "vaccine_group": "bcg",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "Given at birth",
    },
    {
        "vaccine_id": "pentavalent_1",
        "vaccine_name": "Pentavalent 1",
        "age_months": 2,
        "age_label": "2 Months",
        "diseases_prevented": [
            "Diphtheria", "Whooping Cough", "Tetanus",
            "Hepatitis B", "Haemophilus Influenzae Type B"
        ],
        "dose_number": 1,
        "vaccine_group": "pentavalent",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "opv_1",
        "vaccine_name": "Polio (OPV) 1",
        "age_months": 2,
        "age_label": "2 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 1,
        "vaccine_group": "opv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "ipv_1",
        "vaccine_name": "Injectable Polio (IPV) 1",
        "age_months": 2,
        "age_label": "2 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 1,
        "vaccine_group": "ipv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "pentavalent_2",
        "vaccine_name": "Pentavalent 2",
        "age_months": 4,
        "age_label": "4 Months",
        "diseases_prevented": [
            "Diphtheria", "Whooping Cough", "Tetanus",
            "Hepatitis B", "Haemophilus Influenzae Type B"
        ],
        "dose_number": 2,
        "vaccine_group": "pentavalent",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "opv_2",
        "vaccine_name": "Polio (OPV) 2",
        "age_months": 4,
        "age_label": "4 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 2,
        "vaccine_group": "opv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "ipv_2",
        "vaccine_name": "Injectable Polio (IPV) 2",
        "age_months": 4,
        "age_label": "4 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 2,
        "vaccine_group": "ipv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "pentavalent_3",
        "vaccine_name": "Pentavalent 3",
        "age_months": 6,
        "age_label": "6 Months",
        "diseases_prevented": [
            "Diphtheria", "Whooping Cough", "Tetanus",
            "Hepatitis B", "Haemophilus Influenzae Type B"
        ],
        "dose_number": 3,
        "vaccine_group": "pentavalent",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "opv_3",
        "vaccine_name": "Polio (OPV) 3",
        "age_months": 6,
        "age_label": "6 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 3,
        "vaccine_group": "opv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "mmr_1",
        "vaccine_name": "MMR 1 (Measles, Mumps, Rubella)",
        "age_months": 9,
        "age_label": "9 Months",
        "diseases_prevented": ["Measles", "Mumps", "Rubella"],
        "dose_number": 1,
        "vaccine_group": "mmr",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "je",
        "vaccine_name": "Live Japanese Encephalitis (JE)",
        "age_months": 12,
        "age_label": "12 Months",
        "diseases_prevented": ["Japanese Encephalitis"],
        "dose_number": 1,
        "vaccine_group": "je",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "opv_4",
        "vaccine_name": "Polio (OPV) 4",
        "age_months": 18,
        "age_label": "18 Months",
        "diseases_prevented": ["Polio"],
        "dose_number": 4,
        "vaccine_group": "opv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": True,
        "notes": "Booster dose",
    },
    {
        "vaccine_id": "dpt_booster",
        "vaccine_name": "D.P.T. (Triple) Booster",
        "age_months": 18,
        "age_label": "18 Months",
        "diseases_prevented": ["Diphtheria", "Whooping Cough", "Tetanus"],
        "dose_number": 1,
        "vaccine_group": "dpt",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": True,
        "notes": "Booster dose",
    },
    {
        "vaccine_id": "mmr_2",
        "vaccine_name": "MMR 2 (Measles, Mumps, Rubella)",
        "age_months": 36,
        "age_label": "3 Years",
        "diseases_prevented": ["Measles", "Mumps", "Rubella"],
        "dose_number": 2,
        "vaccine_group": "mmr",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "opv_5",
        "vaccine_name": "Polio (OPV) 5",
        "age_months": 60,
        "age_label": "5 Years",
        "diseases_prevented": ["Polio"],
        "dose_number": 5,
        "vaccine_group": "opv",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "dt",
        "vaccine_name": "Double Vaccine (DT)",
        "age_months": 60,
        "age_label": "5 Years",
        "diseases_prevented": ["Diphtheria", "Tetanus"],
        "dose_number": 1,
        "vaccine_group": "dt",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
    {
        "vaccine_id": "hpv_1",
        "vaccine_name": "H.P.V. Vaccine 1",
        "age_months": 120,
        "age_label": "10 Years",
        "diseases_prevented": ["Cervical Cancer"],
        "dose_number": 1,
        "vaccine_group": "hpv",
        "is_conditional": True,
        "gender_restriction": "female",
        "is_booster": False,
        "notes": "Girls only",
    },
    {
        "vaccine_id": "hpv_2",
        "vaccine_name": "H.P.V. Vaccine 2",
        "age_months": 126,
        "age_label": "10 Years (6 months after HPV 1)",
        "diseases_prevented": ["Cervical Cancer"],
        "dose_number": 2,
        "vaccine_group": "hpv",
        "is_conditional": True,
        "gender_restriction": "female",
        "is_booster": False,
        "notes": "Girls only — 6 months after HPV 1",
    },
    {
        "vaccine_id": "atd",
        "vaccine_name": "a.T.d. Vaccine (Adult Tetanus & Diphtheria)",
        "age_months": 132,
        "age_label": "11 Years",
        "diseases_prevented": ["Tetanus", "Diphtheria"],
        "dose_number": 1,
        "vaccine_group": "atd",
        "is_conditional": False,
        "gender_restriction": None,
        "is_booster": False,
        "notes": "",
    },
]


#  Seed Function
def seed():
    print("🌱 Starting vaccination schedule seed...")
    batch = db.batch()

    for vaccine in VACCINES:
        ref = db.collection("vaccination_schedule").document(vaccine["vaccine_id"])
        batch.set(ref, vaccine)
        print(f"   ✅ Queued: {vaccine['vaccine_id']} — {vaccine['vaccine_name']}")

    batch.commit()
    print(f"\n🎉 Successfully seeded {len(VACCINES)} vaccines into Firestore!")


if __name__ == "__main__":
    seed()