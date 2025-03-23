from sqlalchemy import select

from app.adapters.repositories.base import AbstractPostgresRepository
from app.domain.models.user import User


class UserRepository(AbstractPostgresRepository):
    def create(self, username: str, email: str):
        user = User(username=username, email=email)
        self.session.add(user)
        self.session.commit()
        return user

    def get_by_username(self, username: str):
        return self.session.scalar(select(User).where(User.username == username))
