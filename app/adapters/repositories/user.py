from app.adapters.repositories.base import AbstractSQLAlchemyRepository

from app.domain.models.user import User


class UserRepository(AbstractSQLAlchemyRepository):
    def create(self, username: str, email: str):
        user = User(username=username, email=email)
        self.session.add(user)
        self.session.commit()



