from functools import cached_property

from pydantic_settings import BaseSettings
from sqlalchemy import URL


class Settings(BaseSettings):
    postgres_server: str
    postgres_port: int
    postgres_db: str
    postgres_user: str
    postgres_password: str

    @cached_property
    def postgres_url(self):
        return URL.create(
            "postgresql+psycopg2",
            username=self.postgres_user,
            password=self.postgres_password,
            host=self.postgres_host,
            database=self.postgres_db
        )


settings = Settings()
