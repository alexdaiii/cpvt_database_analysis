import os
from enum import Enum
from functools import lru_cache
from typing import Literal

from pydantic import (
    PostgresDsn,
    computed_field,
)
from pydantic_settings import BaseSettings
from .utils import get_location


class TargetDatabase(Enum):
    """
    This is an enum that represents the target database

    Available options are:
    - POSTGRESQL
    """

    POSTGRESQL = "postgresql"


class LogLevels(Enum):
    info = "INFO"
    warn = "WARN"
    error = "ERROR"
    debug = "DEBUG"


class Settings(BaseSettings):
    # PostgreSQL
    postgresql_host: str = "localhost"
    postgresql_username: str = "postgres"
    postgresql_password: str = "postgres"
    postgresql_database: str = "postgres"
    postgresql_schema: str = "public"
    postgresql_port: int = 5432

    @computed_field
    @property
    def postgresql_dsn(self) -> PostgresDsn:
        return PostgresDsn.build(
            scheme="postgresql+psycopg",
            username=self.postgresql_username,
            password=self.postgresql_password,
            host=self.postgresql_host,
            port=self.postgresql_port,
            path=self.postgresql_database,
        )

    # sqlalchemy
    sqlalchemy_echo: bool = True

    class Config:
        env_file = os.path.join(get_location(), "../../.env")
        env_file_encoding = "utf-8"
        extra = "ignore"


@lru_cache()
def get_settings() -> Settings:
    print(f"Loading settings ...")
    settings = Settings()

    return settings


__all__ = [
    "Settings",
    "get_settings",
]
