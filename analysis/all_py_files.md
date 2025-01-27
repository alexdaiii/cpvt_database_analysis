# Python files

These files should be inside a directory called `analysis` with a file named `__init__.py` (can be completely empty) to make the directory a Python package.

## database.py

```python
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




@contextmanager
def get_engine(
    db_uri: str = "postgresql+psycopg://postgres:postgres@localhost:5432/postgres"
):
    _engine: Engine | None = None

    try:
        _engine = sa.create_engine(
            db_uri
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
    dot_alpha: float = 0.8
    box_median_props: dict[Hashable, Any] | None = None
    cat_palette: str
    text_fontsize: int = 10

class FigureParams(BaseModel):
    fig_size: tuple[float, float] | None = None
    title: str | None = None
    xlabel: str | None = None
    ylabel: str | None = None
    xticklabels: dict[Hashable, str] | None = None
    yticklabels: dict[Hashable, str] | None = None

    x_label_fontsize: int = 12
    y_label_fontsize: int = 12
    title_fontsize: int = 12
    x_tick_fontsize: int = 10
    y_tick_fontsize: int = 10

    text_fontsize: int = 10

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
    s_figure_3: FigureParams
    s_figure_4: FigureParams

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
```

## write_report.py

```python
from dataclasses import dataclass

import pandas as pd
from reportlab.lib import colors
from reportlab.platypus import Table, TableStyle
from reportlab.lib.pagesizes import A4


@dataclass
class PdfSection:
    section: str
    stuff: list[str | pd.DataFrame]


# Function to add sections to the PDF
def write_sections_to_pdf(canvas_obj, sections):
    width, height = A4
    y_position = height - 50  # Start at top of the page
    line_spacing = 20  # Spacing between lines

    for section in sections:
        # Add section header
        canvas_obj.setFont("Helvetica-Bold", 14)
        canvas_obj.drawString(50, y_position, section.section)
        y_position -= line_spacing

        canvas_obj.setFont("Helvetica", 12)

        for item in section.stuff:
            if isinstance(item, str):
                # Write strings
                canvas_obj.drawString(70, y_position, item)
                y_position -= line_spacing
            elif isinstance(item, pd.DataFrame):

                item = item.reset_index()

                # Draw tables from pandas DataFrame
                data = [item.columns.tolist()] + item.values.tolist()

                # if the value is a string, strip off any "\n" characters
                data = [[str(cell).replace("\n", " ") for cell in row] for row in data]

                table = Table(data)
                table.setStyle(TableStyle([
                    ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                    ('GRID', (0, 0), (-1, -1), 1, colors.black),
                ]))

                # Determine position for the table
                if y_position - len(
                        data) * line_spacing < 50:  # Add page if not enough space
                    canvas_obj.showPage()
                    y_position = height - 50
                table.wrapOn(canvas_obj, width, y_position)
                table.drawOn(canvas_obj, 50, y_position - len(data) * 15)
                y_position -= len(data) * 15 + line_spacing

        y_position -= line_spacing * 2  # Extra space between sections

        if y_position < 50:  # Add new page if space runs out
            canvas_obj.showPage()
            y_position = height - 50


__all__ = [
    "write_sections_to_pdf",
    "PdfSection",
]
```

## eff_size.py

```python
from typing import Literal

import numpy as np


def get_effect_size(measure: float,
                    measure_name: Literal["cliff", "vda"]) -> Literal[
                                                                  "small",
                                                                  "medium",
                                                                  "large"
                                                              ] | None:
    """
    Determines the effect size of Cliff's delta or Vargha-Delaney A measure.

    Cliff's delta:
      - Small: 0.11 < |d| <= 0.28
      - Medium: 0.28 < |d| < 0.43
      - Large: |d| >= 0.43

    Vargha-Delaney A:
        - Small: 0.56 < A <= 0.64 or 0.34 < A <= 0.44
        - Medium: 0.64 < A <= 0.71 or 0.29 < A <= 0.34
        - Large: A >= 0.71 or A <= 0.29

    Args:
        measure: The effect size measure.
        measure_name: The name of the effect size measure. Either "cliff" or "vda".

    Returns: The effect size category.
        None if the measure is not within the bounds (no effect size) or if it is not a valid measure name.

    """


    if measure_name == "cliff":
        if 0.11 < np.abs(measure) <= 0.28:
            return "small"
        elif 0.28 < np.abs(measure) < 0.43:
            return "medium"
        elif np.abs(measure) >= 0.43:
            return "large"
        else:
            return None
    elif measure_name == "vda":
        if 0.56 < measure <= 0.64 or 0.34 < measure <= 0.44:
            return "small"
        elif 0.64 < measure <= 0.71 or 0.29 < measure <= 0.34:
            return "medium"
        elif measure >= 0.71 or measure <= 0.29:
            return "large"
        else:
            return None
    else:
        return None
```
