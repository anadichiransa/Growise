from datetime import datetime
from dateutil.relativedelta import relativedelta

def add_months(start_date: datetime, months: int) -> datetime:
    return start_date + relativedelta(months=months)