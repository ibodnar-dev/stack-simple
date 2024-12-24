
from sqlalchemy import create_engine, Boolean, MetaData, Table, Column, Integer, String
from sqlalchemy.orm import sessionmaker, registry

from app.core import settings
from app.domain.models.user import User

engine = create_engine(url=settings.postgres_url, isolation_level="REPEATABLE READ")
session_factory = sessionmaker(
    bind=engine
)

mapper_registry = registry()

users = Table(
    "users",
    mapper_registry.metadata,
    Column("id", Integer, primary_key=True, autoincrement=True),
    Column("username", String(255), nullable=False),
    Column("email", String(100))
)

def start_mappers():
    mapper_registry.map_imperatively(User, users)


def start_db():
    start_mappers()
    mapper_registry.metadata.create_all(bind=engine)
