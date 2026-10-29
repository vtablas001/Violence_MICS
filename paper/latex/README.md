# Artículo LaTeX: violencia familiar y ENS MICS El Salvador 2014

Abrir `main.tex` como documento principal. Proyecto autocontenido: los gráficos
se dibujan en LaTeX con TikZ/PGFPlots y leen agregados de `data/`. No requiere
archivos de imagen externos, BibTeX ni acceso a microdatos para compilar.

La fecha editorial de referencia es noviembre de 2019; se identifica como
edición retrospectiva preparada en 2026. No se reincorpora la nota introductoria
que se eliminó del manuscrito Markdown.

## Contenido y evidencia

- Cinco figuras: arquitectura de archivos; disciplina; diez escenarios de
  actitudes; primera unión en la cohorte 20-24; sensibilidad analítica.
- Once cuadros, incluido el diccionario extenso y una plantilla de resultados
  propios pendientes.
- Cinco anexos: diccionario, trazabilidad, sensibilidad, replicación y
  correcciones.

Tres gráficos presentan **cifras secundarias publicadas** del informe oficial:
CP.5 p.282, CP.10 p.296 y CP.7 p.288. Se verificaron las celdas visualmente.
No son reestimaciones propias y no contienen IC inventados. La figura de
sensibilidad es una identidad matemática bajo un ejemplo hipotético explícito.
El diagrama de archivos es metodológico. La reestimación con microdatos sigue
pendiente. No se usan las filas departamentales inconsistentes detectadas en
CP.10 ni el texto introductorio incorrecto de CP.5.

Fuente original: [informe oficial de UNICEF](https://www.unicef.org/elsalvador/media/1261/file/mics_final.pdf).
El anexo de trazabilidad identifica cada conjunto y su página impresa.

## Compilación

Se puede importar esta carpeta en Overleaf, abrirla en el editor LaTeX de Codex,
o usar una distribución TeX con los paquetes del preámbulo.

```sh
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
pdflatex -interaction=nonstopmode -halt-on-error main.tex
```

En PowerShell, `./build.ps1` ejecuta las tres pasadas y comprueba el máximo
de 25 páginas a partir del registro del compilador. Como verificación
independiente del archivo PDF:

```sh
python -m pip install pypdf
python check_pdf.py main.pdf
```

El límite de **25 páginas incluye título, resumen, referencias, gráficos,
tabulados y anexos**. Al editar el contenido debe repetirse la comprobación.
Los paquetes de TeX se instalan mediante la distribución del usuario si faltan.

## Verificación de esta edición

El PDF entregado tiene **15 páginas**, incluidas las referencias y los cinco
anexos. Se compiló con pdfLaTeX (MiKTeX 26.2) y también con el compilador del
editor de Codex. Se comprobaron referencias cruzadas, ausencia de cajas
desbordadas en el registro y la representación de todas las páginas. La
verificación independiente con `pypdf` confirmó el máximo de 25 páginas y la
ausencia de la nota introductoria eliminada. Fecha de revisión: 29-10-2026.

Los porcentajes usan punto decimal en CSV por compatibilidad de lectura y
coma decimal en el texto. Los tres CSV son transcripciones de agregados y no
permiten reconstruir personas. No deben sumarse marginales para construir
compuestos de disciplina o de actitudes.
