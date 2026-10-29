# Registro de verificación de la entrega

Fecha efectiva: **29 de octubre de 2026**. Sistema: Windows, R 4.5.1.

**Resultado observado:** seis bloques de prueba y 35 comprobaciones aprobados,
sin fallas. Se restauraron los 72 paquetes de `renv.lock` en una biblioteca
aislada y se repitió la ejecución con resultado satisfactorio. El aviso de que
`testthat` fue construido con R 4.5.3 no impidió las pruebas en R 4.5.1.

Se ejecutó `tests/run_tests.R` con `testthat`. Incluye recodificación de
desconocidos y etiquetas SPSS, separación de severidad y exclusividad de
disciplina no violenta, códigos de historia conyugal, umbrales exactos,
coherencia de edad, selección infantil, pesos, llaves duplicadas y errores de
diseño. La estimación se compara con una razón ponderada calculada
independientemente. Se comprueban dominio 20-24, límites por información
faltante, intervalos y celdas pequeñas.

La prueba de integración escribe tres archivos SPSS **artificiales**, invoca
el ejecutor en un proceso de R separado y verifica la exportación de tablas,
diccionario, auditoría, huellas, sesión y gráfico. Las salidas de prueba llevan
la marca `SINTETICO_PRUEBA` y se eliminan al terminar. No se guardan porcentajes
artificiales como resultados del estudio.

No se ha ejecutado el programa sobre microdatos reales ni se han validado
prevalencias nacionales, errores estándar o coincidencia con cifras oficiales.
Las pruebas verifican la implementación bajo casos controlados; no sustituyen
la inspección empírica pendiente. La fecha de referencia del manuscrito no
altera este registro de verificación.
