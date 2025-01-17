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
