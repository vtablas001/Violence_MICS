"""Verifica la paginacion real del PDF; no reestima datos de la encuesta."""
import argparse
from pathlib import Path
from pypdf import PdfReader

parser = argparse.ArgumentParser()
parser.add_argument("pdf", type=Path)
parser.add_argument("--max-pages", type=int, default=25)
args = parser.parse_args()
reader = PdfReader(args.pdf)
pages = len(reader.pages)
if not 1 <= pages <= args.max_pages:
    raise SystemExit(f"Extension invalida: {pages} paginas; maximo {args.max_pages}.")
text = "\n".join(page.extract_text() or "" for page in reader.pages)
if "??" in text:
    raise SystemExit("Hay referencias sin resolver en el PDF: repetir la compilacion.")
if "Nota de integridad temporal y empírica" in text:
    raise SystemExit("Se encontro la nota introductoria eliminada.")
for required in ["Disciplina", "Referencias", "Trazabilidad", "Sensibilidad"]:
    if required.casefold() not in text.casefold():
        raise SystemExit(f"No se encontro la seccion requerida: {required}")
print(f"PDF verificado: {pages} paginas; maximo {args.max_pages}, incluidos anexos.")
