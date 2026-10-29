# Artículo LaTeX: violencia familiar y seguridad ciudadana en El Salvador

**[Leer el paper completo (PDF)](https://github.com/vtablas001/Violence_MICS/blob/main/paper/latex/main.pdf)**

Abrir `main.tex` como documento principal. Proyecto autocontenido: los gráficos
se dibujan en LaTeX con TikZ/PGFPlots y leen agregados de `data/`. No requiere
archivos de imagen externos, BibTeX ni acceso a microdatos para compilar.

La portada incluye el logo de Infosegura, USAID y PNUD suministrado por el
usuario, conservado sin modificaciones en `images/`. Esta carpeta debe
acompañar a `main.tex` al compilar o importar el proyecto.

La fecha editorial de referencia se actualizó a **noviembre de 2021**.
Integra ENS MICS 2014 y la presentación Infosegura DATACCIÓN 2021 suministrada.

## Contenido y evidencia

- Siete figuras: arquitectura de archivos; disciplina; diez escenarios de
  actitudes; primera unión; violencia letal; victimización; sensibilidad.
- Quince cuadros, incluido el diccionario extenso y una plantilla de resultados
  propios pendientes.
- Seis anexos: diccionario, trazabilidad MICS, sensibilidad, replicación,
  correcciones y extracción de Infosegura.

Tres gráficos presentan **cifras secundarias publicadas** del informe oficial:
CP.5 p.282, CP.10 p.296 y CP.7 p.288. Se verificaron las celdas visualmente.
No son reestimaciones propias y no contienen IC inventados. La figura de
sensibilidad es una identidad matemática bajo un ejemplo hipotético explícito.
El diagrama de archivos es metodológico. La reestimación con microdatos sigue
pendiente. No se usan las filas departamentales inconsistentes detectadas en
CP.10 ni el texto introductorio incorrecto de CP.5.

Fuente original: [informe oficial de UNICEF](https://www.unicef.org/elsalvador/media/1261/file/mics_final.pdf).
El anexo de trazabilidad identifica cada conjunto y su página impresa.

## Integración de Infosegura

El argumento conecta protección familiar, normas de género y uniones tempranas
con violencia letal, victimización por delincuencia y condiciones materiales.
Las series de Infosegura son agregados secundarios, no registros vinculados a
las personas de MICS. Las figuras preservan la proyección de homicidios de 2021
con trazo discontinuo y no la reemplazan con cifras anuales publicadas después.
Las denuncias son promedios mensuales con corte 2021 no precisado en la lámina;
la variación de privación por desempleo está en puntos porcentuales.

Los seis CSV `data/infosegura_*.csv` proceden de las cachés de gráficos nativos
del PPTX y se cotejaron visualmente en PowerPoint. El manifiesto
`data/infosegura_fuente.json` registra huella del archivo, gráficos y láminas.
El libro Excel original no está incluido en la presentación. No se abren
sus enlaces privados, no se publica la presentación completa y no se imputan
denominadores que las láminas no documentan.

Para regenerar los agregados con una copia autorizada del archivo:

```sh
python extract_infosegura.py "ruta/presentacion.pptx" --output-dir data
```

La extracción requiere solo la biblioteca estándar de Python. El repositorio
incluye `scripts/run_infosegura.R` para verificar los agregados y exportar
contrastes descriptivos sin mezclar registros individuales de MICS.

## Compilación

Se puede importar esta carpeta en Overleaf, abrirla en el editor LaTeX de Codex,
o usar una distribución TeX con los paquetes del preámbulo.

```sh
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

En PowerShell, `./build.ps1` ejecuta las tres pasadas y comprueba el máximo
de 27 páginas a partir del registro del compilador. Como verificación
independiente del archivo PDF:

```sh
python -m pip install pypdf
python check_pdf.py main.pdf
```

El límite de **27 páginas incluye título, resumen, referencias, gráficos,
tabulados y anexos**. Al editar el contenido debe repetirse la comprobación.
Los paquetes de TeX se instalan mediante la distribución del usuario si faltan.

## Verificación de esta edición

El PDF entregado tiene **20 páginas**, incluidas las referencias y los seis
anexos. Se compiló con pdfLaTeX (MiKTeX 26.2) y también con el compilador del
editor de Codex. Se comprobaron referencias cruzadas, ausencia de cajas
desbordadas en el registro y la representación de todas las páginas. La
verificación independiente con `pypdf` confirmó el máximo de 27 páginas y la
ausencia de la nota introductoria eliminada. Fecha de revisión: 29-10-2026.

Los porcentajes usan punto decimal en CSV por compatibilidad de lectura y
coma decimal en el texto. Los CSV contienen agregados secundarios y no
permiten reconstruir personas. No deben sumarse marginales para construir
compuestos de disciplina o de actitudes.
