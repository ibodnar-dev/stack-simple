from app.adapters.repositories.user import UserRepository
from app.core.db import session_factory, start_mappers


class TestUserRepository:
    def test_create(self):
        start_mappers()
        s = session_factory()
        ur = UserRepository(s)
        ur.create("test", "test@gmail.com")
