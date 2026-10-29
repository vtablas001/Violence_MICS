"""Extrae solo agregados seleccionados de la copia PPTX facilitada por el usuario.

No abre enlaces externos ni intenta recuperar los libros Excel vinculados.
Los valores proceden de las caches de los graficos nativos del archivo.
"""
import argparse
import csv
import hashlib
import json
from pathlib import Path
from xml.etree import ElementTree as ET
from zipfile import ZipFile

NS = {"c": "http://schemas.openxmlformats.org/drawingml/2006/chart"}
parser = argparse.ArgumentParser()
parser.add_argument("pptx", type=Path)
parser.add_argument("--output-dir", type=Path, default=Path("data"))
args = parser.parse_args()
args.output_dir.mkdir(parents=True, exist_ok=True)

def points(parent):
    if parent is None:
        return {}
    return {int(p.attrib["idx"]): p.find("c:v", NS).text
            for p in parent.findall(".//c:pt", NS)}

def chart(z, number):
    root = ET.fromstring(z.read(f"ppt/charts/chart{number}.xml"))
    result = []
    for series in root.findall(".//c:ser", NS):
        result.append({"category": points(series.find("c:cat", NS)),
                       "value": {k: float(v) for k, v in
                                 points(series.find("c:val", NS)).items()}})
    return result

def write_csv(name, rows):
    with (args.output_dir / name).open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)

with ZipFile(args.pptx) as z:
    homicide = chart(z, 3)
    femicide = chart(z, 5)
    assert len(homicide[0]["category"]) == 9
    assert homicide[0]["category"][8] == "2021 (pr)"
    years = list(range(2013, 2022))
    rows = [{"anio": year, "total": homicide[2]["value"][i],
             "hombres": homicide[0]["value"][i],
             "mujeres": homicide[1]["value"][i],
             "feminicidios": femicide[0]["value"][i],
             "proyeccion": int(year == 2021)} for i, year in enumerate(years)]
    write_csv("infosegura_homicidios.csv", rows)
    total = chart(z, 16)[0]; sex = chart(z, 17); area = chart(z, 18)
    assert list(total["category"].values()) == ["2017", "2018", "2019", "2021"]
    years = [2017, 2018, 2019, 2021]
    rows = [{"anio": year, "total": total["value"][i],
             "hombres": sex[0]["value"][i], "mujeres": sex[1]["value"][i],
             "urbana": area[0]["value"][i], "rural": area[1]["value"][i]}
            for i, year in enumerate(years)]
    write_csv("infosegura_victimizacion.csv", rows)
    concern = chart(z, 11)
    rows = [{"anio": year, "seguridad": concern[0]["value"][i],
             "economia": concern[1]["value"][i],
             "covid19": concern[4]["value"].get(i, "")}
            for i, year in enumerate(years)]
    write_csv("infosegura_preocupaciones.csv", rows)
    complaints = chart(z, 4)[0]
    rows = [{"anio": int(complaints["category"][i]),
             "promedio_mensual": complaints["value"][i],
             "corte_2021_no_explicitado": int(i == 2)} for i in range(3)]
    write_csv("infosegura_denuncias.csv", rows)
    poverty = chart(z, 12)[0]
    rows = [{"indicador": poverty["category"][i],
             "variacion_pp_2019_2020": poverty["value"][i]}
            for i in range(len(poverty["value"]))]
    write_csv("infosegura_privaciones.csv", rows)
    perception = chart(z, 21)
    selected = {"transporte_publico": 0, "comunidad": 6}
    rows = [{"anio": year, **{name: perception[3-i]["value"][j]
             for name, j in selected.items()}}
            for i, year in enumerate(years)]
    write_csv("infosegura_percepcion.csv", rows)

metadata = {
    "source_filename": args.pptx.name,
    "sha256": hashlib.sha256(args.pptx.read_bytes()).hexdigest(),
    "title": "Analisis Multidimensional de Seguridad Ciudadana. Primer Semestre 2021. El Salvador",
    "attribution": "PNUD a traves de Infosegura, segun los pies de las diapositivas",
    "source_year": 2021,
    "extraction": "XML de caches de graficos nativos; cotejo visual con PowerPoint",
    "origins": {
        "infosegura_homicidios.csv": {"slides": [4, 5], "charts": [3, 5],
            "unit": "tasa por 100000 del grupo correspondiente", "projection_year": 2021},
        "infosegura_victimizacion.csv": {"slides": [10], "charts": [16, 17, 18],
            "unit": "porcentaje, delincuencia ultimos 12 meses", "age_universe": "no explicitado en la diapositiva"},
        "infosegura_preocupaciones.csv": {"slides": [7], "charts": [11],
            "unit": "porcentaje, principal problema del pais", "covid_before_2021": "no consta; no imputar cero"},
        "infosegura_denuncias.csv": {"slides": [5], "charts": [4],
            "unit": "promedio mensual de denuncias", "cutoff_2021": "no explicitado en la diapositiva"},
        "infosegura_privaciones.csv": {"slides": [8], "charts": [12],
            "unit": "variacion 2019-2020 en puntos porcentuales, no tasa de desempleo"},
        "infosegura_percepcion.csv": {"slides": [12], "charts": [21],
            "unit": "porcentaje que declara inseguridad; base de cada espacio no documentada",
            "warning": "el grafico de uso de espacios de personas 18+ es distinto"}
    },
    "limitations": [
        "No se dispone de libros Excel fuente ni microdatos de Cultura de Paz",
        "No se actualizan proyecciones con cifras anuales posteriores",
        "No se usan series auxiliares ni la serie historica mixta de la diapositiva 3",
        "No se cuantifica migracion o revictimizacion por bases no verificadas",
        "No se publican enlaces privados a libros externos ni el PPTX original"
    ]
}
(args.output_dir / "infosegura_fuente.json").write_text(
    json.dumps(metadata, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("Extraidos seis CSV y metadatos de fuente, sin abrir enlaces externos.")
