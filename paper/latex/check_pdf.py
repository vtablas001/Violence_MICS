"""Verifica la paginacion real del PDF; no reestima datos de la encuesta."""
import argparse
import re
from pathlib import Path
from pypdf import PdfReader

parser = argparse.ArgumentParser()
parser.add_argument("pdf", type=Path)
parser.add_argument("--max-pages", type=int, default=27)
args = parser.parse_args()
reader = PdfReader(args.pdf)
pages = len(reader.pages)
if not 1 <= pages <= args.max_pages:
    raise SystemExit(f"Extension invalida: {pages} paginas; maximo {args.max_pages}.")
text = "\n".join(page.extract_text() or "" for page in reader.pages)
cover = reader.pages[0].extract_text() or ""
bibliography_pages = [(i + 1, page.extract_text() or "")
                      for i, page in enumerate(reader.pages)
                      if re.search(r"(?m)^Referencias\s*$", page.extract_text() or "")]
if len(bibliography_pages) != 1:
    raise SystemExit("No se identifico un unico encabezado de Referencias.")
reference_page, reference_text = bibliography_pages[0]
prefix = re.split(r"(?m)^Referencias\s*$", reference_text, maxsplit=1)[0]
if " ".join(prefix.split()) != "Infosegura":
    raise SystemExit("Las referencias deben comenzar en una pagina nueva.")
if "Noviembre de 2021" not in cover:
    raise SystemExit("La portada no tiene la fecha actualizada a noviembre de 2021.")
if "preparación:" in cover:
    raise SystemExit("Reaparecio la linea eliminada de la portada.")
if "??" in text:
    raise SystemExit("Hay referencias sin resolver en el PDF: repetir la compilacion.")
if "Nota de integridad temporal y empírica" in text:
    raise SystemExit("Se encontro la nota introductoria eliminada.")
for required in ["Disciplina", "Referencias", "Trazabilidad", "Sensibilidad", "Infosegura"]:
    if required.casefold() not in text.casefold():
        raise SystemExit(f"No se encontro la seccion requerida: {required}")
print(f"PDF verificado: {pages} paginas; maximo {args.max_pages}, incluidos anexos.")
print(f"Referencias verificadas: comienzan en pagina nueva ({reference_page}).")
