

from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from enum import Enum


# ─── Enums ────────────────────────────────────────────────────────────────────

class VaccineStatus(str, Enum):
    PENDING = "pending"
    DONE = "done"
    OVERDUE = "overdue"
    SKIPPED = "skipped"


class SupplementType(str, Enum):
    VITAMIN_A = "vitamin_a"
    MMN = "mmn"
    WORM_TREATMENT = "worm_treatment"
    IRON_DAILY = "iron_daily"


# ─── Master Schedule (Firestore seed reference) ────────────────────────────────

class VaccineMasterRecord(BaseModel):
    vaccine_id: str
    vaccine_name: str
    age_months: int
    age_label: str
    diseases_prevented: List[str]
    dose_number: int
    vaccine_group: str
    is_conditional: bool
    gender_restriction: Optional[str] = None
    is_booster: bool
    notes: str = ""


# ─── Per-Child Immunization Record ────────────────────────────────────────────

class ChildImmunizationRecord(BaseModel):
    vaccine_id: str
    vaccine_name: str
    age_label: str
    age_months: int
    diseases_prevented: List[str]
    status: VaccineStatus
    scheduled_date: datetime
    administered_date: Optional[datetime] = None
    administered_by: Optional[str] = None
    batch_number: Optional[str] = None
    days_until_due: Optional[int] = None
    is_booster: bool = False
    notes: str = ""


# ─── Supplement Record ─────────────────────────────────────────────────────────

class SupplementRecord(BaseModel):
    record_id: str
    type: SupplementType
    scheduled_date: datetime
    status: str  # "pending" | "done"
    notes: str = ""


# ─── Request Bodies ────────────────────────────────────────────────────────────

class MarkVaccineDoneRequest(BaseModel):
    administered_date: datetime
    administered_by: str
    batch_number: Optional[str] = None
    notes: Optional[str] = None


# ─── Notification Payload ──────────────────────────────────────────────────────

class NotificationPayload(BaseModel):
    child_id: str
    child_name: str
    vaccine_name: str
    scheduled_date: datetime
    urgency: str        # "today" | "tomorrow" | "this_week" | "overdue"
    days_until_due: int
    show_on_home: bool
    show_on_notifications: bool