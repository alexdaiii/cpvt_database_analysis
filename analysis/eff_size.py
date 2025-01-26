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