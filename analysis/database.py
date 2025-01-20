from contextlib import contextmanager
from typing import Hashable, Any, Literal

import yaml
from cpvt_database_models.database import Base
from matplotlib import pyplot as plt
import seaborn as sns
from pydantic import BaseModel, computed_field
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




class FigurePalette(BaseModel):
    default_bar: str
    default_hist: str
    default_dot: str
    box_median_props: dict[Hashable, Any] | None = None
    cat_palette: str

class FigureParams(BaseModel):
    fig_size: tuple[float, float] | None = None
    title: str | None = None
    xlabel: str | None = None
    ylabel: str | None = None
    xticklabels: dict[Hashable, str] | None = None
    yticklabels: dict[Hashable, str] | None = None

    x_label_fontsize: int = 10
    y_label_fontsize: int = 10
    title_fontsize: int = 10
    x_tick_fontsize: int = 8
    y_tick_fontsize: int = 8

    panels: dict[str, "FigureParams"] | None = None

class ConfigYaml(BaseModel):
    version: str

    figure_palette: FigurePalette

    figure2: FigureParams
    figure3: FigureParams
    figure4: FigureParams
    figure6: FigureParams

    reviewer2_1: FigureParams

    s_figure_2: FigureParams

    @computed_field
    @property
    def version_for_dir(self) -> str:
        return self.version.replace(".", "_")


def set_figure_size(
        figure_params: FigureParams,
        x_tick_ha: Literal["center", "right", "left"] = "center",
        x_tick_rotation: int = 0,
):
    plt.xlabel(figure_params.xlabel, fontsize=figure_params.x_label_fontsize)
    plt.ylabel(figure_params.ylabel, fontsize=figure_params.y_label_fontsize)
    plt.title(figure_params.title, fontsize=figure_params.title_fontsize)
    plt.xticks(rotation=x_tick_rotation, ha=x_tick_ha,
               fontsize=figure_params.x_tick_fontsize)
    plt.yticks(fontsize=figure_params.y_tick_fontsize)
    sns.despine()
    plt.tight_layout()


def get_config():
    with open("../config.yaml") as f:
        config = yaml.safe_load(f)

    return ConfigYaml(**config)



__all__ = ["PublicationROBType", "PublicationType", "get_engine", "get_config"]
