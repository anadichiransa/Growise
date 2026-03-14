from app.api.v1 import vaccines

app.include_router(vaccines.router)