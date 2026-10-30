# Violencia familiar y seguridad ciudadana: MICS 2014 e Infosegura 2021

**[Leer el paper completo (PDF)](https://github.com/vtablas001/Violence_MICS/blob/main/paper/latex/main.pdf)**

Análisis **descriptivo**, reproducible en R, de disciplina infantil, actitudes
hacia la violencia contra la esposa y primera unión antes de los 15 y 18 años.
La versión principal del artículo está disponible como
[PDF de 25 páginas](paper/latex/main.pdf) y como
[proyecto LaTeX editable](paper/latex/README.md), con trece figuras, quince
cuadros y seis anexos. Su fecha de referencia es **noviembre de 2021** y
articula MICS con el análisis multidimensional de Infosegura. Se conserva el
[borrador inicial en Markdown](paper/manuscrito_noviembre_2019.md).

El máximo autorizado es **27 páginas**, incluidas referencias y anexos.

La ampliación añade seis figuras y análisis de coexistencia de prácticas,
edad y riqueza, cohortes de primera unión, prioridades, percepción y
privaciones. Incluye una tabla del cambio observado de cuatro tasas de
violencia letal entre 2015 y 2020. Los cálculos se regeneran con R base desde
la carpeta `paper/latex`: `Rscript --vanilla rebuild_analysis.R`.

Los gráficos empíricos del artículo LaTeX presentan cifras **secundarias del
informe MICS y de la presentación Infosegura**, cotejadas con sus tablas,
páginas o diapositivas. No son reestimaciones
propias. El gráfico de sensibilidad es una ilustración matemática identificada.

**Estado:** código probado con archivos SPSS artificiales. No se dispuso de los
microdatos reales en esta entrega y no se reestimaron prevalencias con ellos.
La fecha de referencia del manuscrito es **noviembre de 2021**.

La integración de Infosegura añade tasas de homicidio y feminicidio,
victimización, preocupaciones económicas y privaciones. Conserva las
proyecciones de 2021 como proyecciones, sin unir esos agregados a las personas
de MICS ni atribuirles efectos causales. Ver
[procedencia y límites](docs/infosegura.md).

## Qué corrige

- `MA5 = 3` significa **nunca unida**. `MA5 = 2` significa acompañada en el pasado.
- Disciplina está en `hh.sav`, vinculada a `hl.sav`; no en `ch.sav`.
- Peso infantil: `hhweight * SL1`, donde `SL1` cuenta niños de **1 a 17** años.
- Peso de mujeres: `wmweight`, sin sustitución por el peso del hogar.
- Los nombres se limpian a minúsculas antes de validarlos. Se evitan sufijos
  `.x/.y` al incorporar el diseño a mujeres.
- Se distinguen métodos no violentos de **solo** disciplina no violenta.
- “No sabe” y faltantes no se convierten en “no”. Se informan sus denominadores.

La [auditoría del script anterior](docs/correcciones.md) y el
[diccionario contrastado](docs/codigos.md) explican las decisiones y sus límites.

## Datos necesarios

Obtener legalmente los archivos originales `hh.sav`, `hl.sav` y `wm.sav` de
**ENS MICS El Salvador 2014**, referencia `SLV_2014_MICS_v01_M`, mediante el
[catálogo oficial de microdatos](https://microdata.worldbank.org/index.php/catalog/2780).
Respetar el registro, la confidencialidad y las condiciones del proveedor.
Colocarlos en `data/raw/`, o indicar otra carpeta al ejecutar. No se requiere
`ch.sav`. No se descargan ni publican automáticamente microdatos.

Registrar por separado la fecha de descarga y citar a MINSAL-INS, DIGESTYC y
UNICEF. El ejecutor calcula huellas MD5 para identificar la versión de los
archivos locales; no son medidas criptográficas de seguridad.

## Ejecución

Trabajar desde la raíz del repositorio. R 4.5.1 fue la versión utilizada en las
pruebas; se incluye `renv.lock` con las versiones efectivamente instaladas.
Primero instalar `renv` y restaurar la biblioteca del proyecto:

```r
install.packages("renv", repos = "https://cloud.r-project.org")
renv::load()
renv::restore(prompt = FALSE)
```

Para que cada sesión utilice esa biblioteca, se carga explícitamente. No se
requiere modificar la configuración global de R:

```sh
Rscript -e 'renv::load(); source("tests/run_tests.R")'
Rscript -e 'renv::load(); source("scripts/run_analysis.R")' data/raw results/real
```

En PowerShell, Bash y terminales habituales, las comillas simples exteriores
preservan las comillas dobles del código R. Alternativamente, en una sesión R:

```r
renv::load()
# Las pruebas no requieren microdatos:
source("tests/run_tests.R")
# Para analizar datos use el comando de terminal anterior con sus dos rutas.
```

Si se decide usar versiones actuales sin restaurar el entorno fijado:

```sh
Rscript scripts/install.R
Rscript tests/run_tests.R
Rscript scripts/run_analysis.R data/raw results/real
```

Para verificar y tabular únicamente los agregados secundarios de Infosegura:

```sh
Rscript -e 'renv::load(); source("scripts/run_infosegura.R")' results/infosegura
```

La carpeta de salida debe ser nueva o estar vacía. Un error de validación
detiene el análisis. Revisar las etiquetas exportadas y la documentación;
no modificar códigos para hacer pasar un archivo de otra encuesta.

## Productos de una ejecución con datos

| Archivo local | Contenido |
| --- | --- |
| `estimaciones.csv` | Prevalencias, EE, IC95, tamaños sin ponderar, faltantes, límites de sensibilidad y estados |
| `auditoria_diseno.csv` | Filas, estratos, UPM, estratos con una UPM y rango de pesos |
| `diccionario_observado.csv` | Etiquetas y códigos SPSS de variables utilizadas |
| `huellas_archivos.csv` | Huellas de los tres archivos de entrada |
| `sessionInfo.txt` | Versión de R, plataforma y paquetes cargados |
| `indicadores.png` | Estimaciones nacionales por módulo, con IC disponibles |
| `LEAME.txt` | Fecha real de ejecución y decisiones metodológicas |

Las desagregaciones son por residencia, quintil y edad; disciplina también por
sexo. Las uniones usan mujeres **20-24** y se desagregan por residencia y quintil.
Los diez ítems DV se presentan individualmente, además de los compuestos de
cinco y diez escenarios. Estos dos compuestos no son intercambiables.

## Interpretación y límites

El estimador principal usa **respuestas clasificables para cada indicador**.
Una respuesta afirmativa basta para clasificar un compuesto como uno; todas
deben ser negativas para clasificarlo como cero. Otros casos son desconocidos.
Se incluyen porcentaje ponderado faltante y límites extremos considerando a
todos los desconocidos como cero o como uno. **Estos límites no son IC.**
La regla puede diferir de la tabulación oficial ante no respuesta; no se afirma
una réplica certificada de las tablas oficiales. Ver [metodología](docs/metodologia.md).

Se utilizan `psu`, `stratum`, Taylor y dominios sobre el diseño completo.
Los IC95 son logit con grados de libertad del diseño. Los resultados con menos
de 25 observaciones clasificables se omiten (`n_menor_25`); estimaciones en cero
o uno conservan su punto y EE, pero no se genera un IC logit (`frontera_sin_ic`).
La opción `survey.lonely.psu = "adjust"` se declara y audita: requiere revisión
si aparecen estratos solitarios. Las sumas de pesos normalizados no son totales
poblacionales. Las tablas locales necesitan revisión de divulgación antes de
compartirse; el umbral de 25 es una regla analítica, no certificación de anonimato.

El proyecto no mide homicidios, violencia de pandillas ni toda la violencia de
pareja. Las actitudes no son victimización ni un instrumento econométrico de
variables instrumentales. No se aplica PSM: no se ha definido un tratamiento,
su temporalidad ni supuestos de identificación causal.

## Organización

```text
R/                 recodificación, validación y estimación
scripts/           instalación y ejecutor
tests/             pruebas unitarias y ejecución completa con SPSS artificial
docs/              fuentes, códigos, metodología y correcciones
paper/             manuscrito en español y proyecto LaTeX
data/raw/          microdatos locales excluidos de Git
results/           resultados locales excluidos de Git
renv.lock          entorno de paquetes fijado
```

No se atribuye autoría personal ni afiliación sin confirmación. La licencia del
código/manuscrito queda pendiente del titular; los materiales de terceros
mantienen sus propias condiciones.
