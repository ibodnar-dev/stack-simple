from fastapi import FastAPI

from app.core.config import Settings

settings = Settings()
app = FastAPI()


@app.get("/")
def root():
    return {"message": settings.postgres_db}
