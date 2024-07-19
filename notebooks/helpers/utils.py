import inspect
import os
from types import NoneType
from Bio.SeqUtils import seq1
import re
from hgvs.sequencevariant import SequenceVariant
from hgvs.parser import Parser

def get_location(file: str | None = None) -> str:
    """
    Get the absolute path of the file that called this function.
    """
    # https://stackoverflow.com/questions/13699283/how-to-get-the-callers-filename-method-name-in-python
    if file is None:
        frame = inspect.stack()[1]
        file = frame[0].f_code.co_filename

    return os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(file)))


def mkdir_p(path: str) -> None:
    """
    Make a directory if it doesn't exist.
    """
    if not os.path.exists(path):
        os.makedirs(path)


def to_dict(obj: object, depth: int = 0, max_depth: int = 3):
    """
    Converts an object into a dictionary
    """
    if depth > max_depth:
        return obj.__str__()

    prim_types = (int, float, str, bool, NoneType)

    return {
        o_attr: (
            getattr(obj, o_attr)
            if isinstance(
                getattr(obj, o_attr),
                prim_types,
            )
            else to_dict(getattr(obj, o_attr), depth + 1, max_depth)
        )
        for o_attr in dir(obj)
        if not o_attr.startswith("_") and not callable(getattr(obj, o_attr))
    } | {"__class": obj.__class__.__name__}


# convert to aa 1 from aa3 using biopython

hgvs_aa3 = set(
    "Ala Cys Asp Glu Phe Gly His Ile Lys Leu Met Asn Pro Gln Arg Ser Thr Val Trp Tyr Asx Glx Xaa Sec".split()
) | {"Ter"}

parser = Parser()


def to_aa1(
        sequence_variant: str | SequenceVariant
):

    if isinstance(sequence_variant, str):
        sequence_variant = parser.parse_hgvs_variant(sequence_variant)


    # hgvs python package gives the AA3 code by default in the
    # str(variant.posedit) - use regex and convert all to 1 letter code
    posedit_str = str(sequence_variant.posedit)

    # strip out any parentheses
    posedit_str = posedit_str.replace("(", "").replace(")", "")

    # remove all non A-Za-z characters with regex
    aa3_codes = re.findall("[A-Z][a-z]{2}", posedit_str)

    # Convert each 3-letter code to a 1-letter code and replace it in the string
    for aa3 in aa3_codes:
        if aa3 not in hgvs_aa3:
            raise ValueError(f"Invalid AA3 code: {aa3}")
        aa1 = seq1(aa3)
        posedit_str = posedit_str.replace(aa3, aa1)

    return posedit_str