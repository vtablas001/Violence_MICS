# Integración de MICS e Infosegura

La versión principal del paper tiene fecha editorial de referencia **noviembre
de 2021**, actualizada por indicación del usuario. Infosegura se incorpora al
resumen, introducción, marco, fuentes, metodología, resultados, discusión,
conclusiones y un anexo específico. No se limita a una cita o un apéndice.

La fuente suministrada es *Análisis Multidimensional de Seguridad Ciudadana.
Primer Semestre 2021. El Salvador*, presentación DATACCIÓN, versión 3.0,
14 diapositivas. Los pies atribuyen las cifras a PNUD a través de Infosegura
y a sus productores: mesas técnicas, PNC, DIGESTYC y Cultura de Paz.
Su nombre de archivo y SHA256 se registran en
`paper/latex/data/infosegura_fuente.json`. La huella es
`7d81a940e6b9f6f7bee15fd14174e0b97b4ffa1d69427b36c8253668d2ddf154`.

Se extrajeron cachés XML de gráficos nativos y se cotejaron con una conversión
de lectura en PowerPoint. Los libros Excel enlazados no están incluidos. No
se consultaron enlaces privados ni se publica el PPTX original. El script
`paper/latex/extract_infosegura.py` repite la extracción usando únicamente
la biblioteca estándar de Python.

| Lámina | Uso en el estudio | Precaución |
| --- | --- | --- |
| 4 y 5 | Tasas de homicidio total, mujeres y feminicidio | El extremo de 2021 es una proyección, no cierre anual |
| 5 | Denuncias intrafamiliares | Promedio mensual; corte 2021 no precisado en la lámina |
| 7 | Principal problema del país | Opiniones, no victimización; COVID-19 no consta antes de 2021 |
| 8 | Variación de privaciones | Puntos porcentuales 2019-2020, no tasa de desempleo |
| 10 | Victimización por sexo y área | Delincuencia en doce meses; edad del universo no explicitada |
| 12 | Percepción en transporte y comunidad | No trasladar la base 18+ del gráfico de uso de espacios al de percepción |
| 13 | Agenda de prevención | Recomendaciones, no efectos evaluados |

No se cuantifican migración y revictimización por bases insuficientemente
documentadas. Tampoco se utiliza la serie histórica mixta de la lámina 3,
que incluye series auxiliares. La separación por índices XML impide emparejar
valores con años incorrectos cuando una caché omite observaciones.

La vinculación con MICS es **documental y conceptual**. No se construye una
serie 2014-2021 de violencia familiar ni se enlazan personas de encuestas
distintas. Los agregados no identifican transmisión individual de violencia,
impactos de políticas o efectos del desempleo sobre prácticas observadas
en 2014. No se producen intervalos de confianza a partir de cifras publicadas.

El script `scripts/run_infosegura.R` comprueba años, proyecciones y rangos,
exporta brechas descriptivas de victimización y calcula el cambio de la tasa
general de homicidio entre 2015 y 2020. Mantiene aparte las proyecciones de
2021. Sus salidas permanecen en `results/`, excluido de Git.
