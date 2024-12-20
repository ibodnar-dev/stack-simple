from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core import settings

session_factory = sessionmaker(
    bind=create_engine(url=settings.postgres_url, isolation_level="REPEATABLE READ")
)
