from fastapi import FastAPI

from app.adapters.repositories.user import UserRepository
from app.core.db import start_db, session_factory

app = FastAPI()
start_db()

@app.get("/")
def root():
    return {"message": "root"}


@app.post("/create")
def create(user_name: str, email: str):
    ur = UserRepository(session=session_factory())
    created_user = ur.create(username=user_name, email=email)
    return ur.get_by_username(username=created_user.username)
