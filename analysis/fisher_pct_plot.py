import os
from pathlib import Path

import pandas as pd
from IPython.core.display_functions import display

from analysis.database import FigureParams, set_figure_size, get_config
import matplotlib.patches as mpatches
import matplotlib.pyplot as plt
import seaborn as sns

def plot_fisher_pct(
        df_fish: pd.DataFrame,
        panel: FigureParams,
        group_a: str,
        legend_a: str,
        legend_b: str,
        plt_name: str,
        plt_order: list[str] = None,
        *,
        legend_bb_anchor: tuple[float, float] = None,
        frameon: bool = True,
        rotate_x: bool = False,
        figures_dir: Path
):
    sns.set_style("ticks")

    if legend_bb_anchor is None:
        legend_bb_anchor = (0.5, 1.1)
    plt.figure(
        figsize=panel.fig_size
    )

    df_fish_pct = df_fish.copy()
    df_fish_pct[f"{group_a}_pct"] = (
            df_fish[group_a] / df_fish["Total"] * 100
    )
    df_fish_pct["total_pct"] = 100

    display(df_fish_pct)

    color1 = sns.color_palette(get_config().figure_palette.cat_palette)[0]
    color2 = sns.color_palette(get_config().figure_palette.cat_palette)[1]

    plt_order = plt_order if plt_order else df_fish_pct["p_hgvs_string"]

    sns.barplot(
        x="p_hgvs_string",
        y="total_pct",
        data=df_fish_pct,
        color=color1,
        edgecolor="black",
        order=plt_order
    )
    sns.barplot(
        x="p_hgvs_string",
        y=f"{group_a}_pct",
        data=df_fish_pct,
        color=color2,
        edgecolor="black",
        order=plt_order
    )

    top_bar = mpatches.Patch(
        facecolor=color2,
        label=legend_a,
        edgecolor="black"
    )
    bottom_bar = mpatches.Patch(
        facecolor=color1,
        label=legend_b,
        edgecolor="black"
    )

    plt.legend(
        handles=[top_bar, bottom_bar],
        loc="center",
        bbox_to_anchor=legend_bb_anchor,
        ncol=2,
        edgecolor="black",
        frameon=frameon
    )

    set_figure_size(
        panel,
        x_tick_ha="center",
        x_tick_rotation=90 if rotate_x else 0
    )
    save_current_plot(figures_dir=figures_dir, name=plt_name)

    plt.show()


def save_current_plot(figures_dir: Path, name: str):
    for fmt in ["png", "pdf", "svg"]:
        plt.savefig(
            os.path.join(figures_dir / f"{name}.{fmt}"), dpi=300)
