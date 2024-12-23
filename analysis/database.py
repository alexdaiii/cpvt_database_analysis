from contextlib import contextmanager

from cpvt_database_models.database import Base
from sqlalchemy import Engine
from sqlalchemy.orm import mapped_column, Mapped
import sqlalchemy as sa

class PublicationROBType(Base):
    """
    What type of ROB analysis was performed on the publication
    """
    __tablename__ = 'publication_rob_type'

    rob_publication_type_id: Mapped[int] = mapped_column(primary_key=True)
    rob_publication_type: Mapped[str] = mapped_column()


class PublicationType(Base):
    """
    General publication type.

    Article, Letter, Brief Communication, Article (according to the journal), Review, etc.
    """
    __tablename__ = 'publication_type'

    publication_type_id: Mapped[int] = mapped_column(primary_key=True)
    publication_type: Mapped[str] = mapped_column()


# make sqalchemy create these tables (note all the other tables are already created)
@contextmanager
def get_engine():
    _engine: Engine | None = None

    try:
        _engine = sa.create_engine(
            "postgresql+psycopg://postgres:postgres@localhost:5432/postgres"
        )
        yield _engine
    except Exception as e:
        print("Error")
        raise e
    finally:
        if _engine:
            _engine.dispose()

__all__ = ["PublicationROBType", "PublicationType", "get_engine"]