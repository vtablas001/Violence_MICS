# Documentación técnica complementaria

El paper estudia la violencia familiar con MICS y fuentes complementarias.
Este documento reúne los detalles de ejecución informática que no forman
parte del argumento académico central. El análisis del paper usa agregados
oficiales; el análisis individual de archivos SAV permanece por ejecutar.

## Reproducción de contrastes del paper

Desde `paper/latex`, ejecutar:

```sh
Rscript --vanilla rebuild_analysis.R
```

Usa R base y conserva los CSV fuente. Regenera las descomposiciones de
disciplina, cambios de tasas, brechas y coordenadas derivadas. Los scripts
y sus comentarios están en español; las cifras empíricas no proceden de
los datos artificiales de las pruebas.

## Preparación del análisis con microdatos

Obtener los archivos autorizados `hh.sav`, `hl.sav` y `wm.sav`; consultar
las reglas de acceso en el README. No se redistribuyen personas ni registros.
La biblioteca de paquetes queda fijada en `renv.lock`. Desde la raíz del
repositorio, instalar `renv` si hace falta y restaurar las dependencias:

```r
install.packages("renv")
renv::restore(prompt = FALSE)
```

Ejecutar cada comando en una sola línea:

```sh
Rscript -e 'renv::load(); source("tests/run_tests.R")'
Rscript -e 'renv::load(); source("scripts/run_analysis.R")' data/raw results/real
```

La carpeta de salida debe estar vacía. Revisar el inventario de variables,
etiquetas, llaves, diseño, ponderadores, faltantes y estados de estimación
antes de comparar resultados con los tabulados oficiales. Las edades
declaradas y derivadas requieren reglas de edición coherentes.

## Validaciones ya documentadas

La verificación previa incluyó seis bloques y 35 comprobaciones automatizadas,
lectura y escritura de archivos SPSS artificiales y exportación de tablas y
gráficos. Se restauraron 72 paquetes fijados. Estos controles corresponden
a la implementación y no constituyen resultados de la población salvadoreña.

El ejecutor exige entrevistas completas, identifica al niño seleccionado y
verifica coherencia entre el listado de miembros y el módulo de disciplina.
Comprueba llaves, unicidad y ausencia de multiplicación de filas. Distingue
el peso de mujeres del peso infantil ajustado por la selección intrahogar.
Construye diseños antes de estimar dominios y documenta los estratos con
una sola UPM. Las funciones de estimación utilizan `svymean` y `svyciprop`,
con las condiciones y límites descritos en el código.

Una aplicación a los microdatos debe producir puntos, errores estándar,
intervalos, tamaños válidos y proporciones desconocidas. Esas salidas no se
completan copiando cifras oficiales como si fueran estimaciones propias.
