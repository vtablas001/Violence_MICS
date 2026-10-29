# Estimación, dominios y datos desconocidos

La unidad infantil es el niño seleccionado, no cada fila de `hl.sav`. Solo hay
un registro seleccionado por hogar con miembros 1-17. El peso de selección es
el peso del hogar multiplicado por SL1. Para conservar UPM en la varianza,
el diseño se construye sobre todos los hogares completos: hogares sin niños
reciben un peso auxiliar positivo `hhweight` y contribución cero al dominio;
los seleccionados 15-17 tampoco contribuyen al indicador de disciplina.
Ninguno recibe un resultado cero artificial de disciplina.

Para mujeres se construye el diseño sobre entrevistas completas 15-49 con su
peso individual. La cohorte 20-24 se obtiene mediante `subset` del diseño.
Se utilizan las UPM y estratos distribuidos en hh; la documentación indica
estratificación departamento por área urbana/rural. No se confunde región con
estrato. La varianza es Taylor con aproximación de conglomerado último y sin
corrección por población finita, al no disponer de fracciones de muestreo.

Para un indicador Y, sea O el conjunto clasificable dentro del dominio D:

`p_observado = sum(w_i * Y_i, i en O) / sum(w_i, i en O)`.

Esta razón describe casos con respuesta clasificable; extrapolarla a todo D
requiere supuestos sobre falta de respuesta. No se eliminan personas por
faltar una covariable que no se usa en el indicador. Cada subgrupo es un dominio
del diseño y las covariables desconocidas forman una categoría explícita.

Se exportan, además:

- Fracción ponderada desconocida: `sum(w_desconocidos) / sum(w_D)`.
- Límite inferior: `sum(w_i * Y_i, i en O) / sum(w_D)`.
- Límite superior: `(sum(w_i * Y_i, i en O) + sum(w_desconocidos)) / sum(w_D)`.

Estos últimos son límites descriptivos extremos por falta de información,
sin incorporar incertidumbre muestral. No son intervalos de confianza ni
correcciones por sesgo de medición. En DV, “no sabe” no equivale a rechazo.
No se imputa unión temprana para antiguas convivientes sin edad de unión.

Los errores estándar son de `svymean`; los IC95 son de `svyciprop(method="logit")`
con grados de libertad del diseño del dominio clasificable. Se declara
`survey.lonely.psu="adjust"` y `survey.adjust.domain.lonely=TRUE`. No se asume
que una UPM única sea de certeza. La auditoría informa estratos con una UPM en
el diseño completo; cada fila incluye grados de libertad del dominio.
Los dominios pequeños o degenerados llevan estados explícitos. Una estimación
en 0/100 con EE cero no demuestra certeza poblacional y carece de IC logit.

Las desagregaciones son descriptivas, no pruebas de efectos causales ni
comparaciones múltiples confirmatorias. No se interpreta riqueza actual como
causa de una unión pasada. Las diferencias entre cohortes en una encuesta
transversal tampoco estiman por sí solas tendencias libres de sesgo.

Antes de publicar resultados reales se debe comprobar la versión de los SAV,
sus etiquetas, los códigos especiales, las reglas oficiales de no respuesta,
las edades derivadas `wage`/`wagem` y la correspondencia con las tablas CP.5,
CP.7 y CP.10 del informe. Esta entrega produce un análisis transparente de
edades declaradas; no certifica esa réplica sin microdatos y sintaxis oficial.
