# import os
# from PyPDF2 import PdfWriter, PdfReader
# import pdfplumber

# # Input and output paths
# input_path = "C:\\Users\\noahl\\Downloads\\Replay April 2025 - Blast Player Reports.pdf"
# output_folder = "C:\\Users\\noahl\\OneDrive\\Documents\\Git Repos\\ReplayPlayerDev\\BlastReports"
# os.makedirs(output_folder, exist_ok=True)

# # Open PDF with both PyPDF2 and pdfplumber
# reader = PdfReader(input_path)
# with pdfplumber.open(input_path) as pdf:
#     for i, page in enumerate(pdf.pages):
#         # Extract text
#         text = page.extract_text()
#         name = f"Page_{i+1}"  # fallback name
#         if text:
#             lines = text.strip().split('\n')
#             for line in lines:
#                 if len(line.strip()) > 3 and all(c.isalpha() or c.isspace() for c in line.strip()):
#                     name = line.strip().replace(" ", "_").replace("/", "_")[:50]
#                     break

#         # Save the page as a separate PDF
#         writer = PdfWriter()
#         writer.add_page(reader.pages[i])

#         output_path = os.path.join(output_folder, f"{name}.pdf")
#         with open(output_path, "wb") as f_out:
#             writer.write(f_out)

#         print(f"Saved: {output_path}")

import pdfplumber

input_path = r"C:\Users\noahl\Downloads\Replay April 2025 - Blast Player Reports.pdf"

with pdfplumber.open(input_path) as pdf:
    page = pdf.pages[0]
    im = page.to_image(resolution=150)
    im.draw_rects(page.extract_words())  # Draws all word boxes
    im.save("page_debug.png")

