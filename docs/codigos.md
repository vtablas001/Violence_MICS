# Diccionario contrastado: ENS MICS El Salvador 2014

Verificación documental realizada el **29-10-2026**. Fuente principal:
[informe oficial y cuestionarios del apéndice F](https://www.unicef.org/elsalvador/media/1261/file/mics_final.pdf).
Páginas **impresas**, no números del visor: selección p. 471; disciplina p. 474;
actitudes p. 507; matrimonio p. 508; ponderación infantil, nota 5, p. 306.
La numeración del archivo PDF es dos páginas mayor (por ejemplo, p. 474 = PDF 476).

## Archivos, llaves y diseño

| Archivo | Campos originales | Uso verificado |
| --- | --- | --- |
| hh | HH1, HH2 | Llave única del hogar |
| hl | HH1, HH2, HL1 | Llave única de miembro |
| wm | HH1, HH2, WM4 | Llave única de mujer; WM4 es línea individual |
| hh | HH9 | Resultado entrevista del hogar; 1 completa |
| wm | WM7 | Resultado entrevista de mujer; 1 completa |
| hh | SL1 | Número de miembros de 1-17 años; denominador de selección |
| hh | SL9B, SL9C | Línea y edad del niño seleccionado de 1-17 años |
| hh | CD2 | Línea del mismo niño si tiene 1-14 años |
| hl | HL4, HL6 | Sexo (1 masculino, 2 femenino) y edad cumplida en años |
| hh | HH6 | Área: 1 urbana, 2 rural |
| hh | HH7A | Departamento, conservado como factor; no se inventan etiquetas |
| hh | windex5 | Quintil combinado nacional, 1 más pobre a 5 más rico |
| hh | hhweight | Peso normalizado del hogar |
| hh | psu, stratum | UPM y estrato publicados; no se reconstruyen desde región |
| wm | wmweight | Peso normalizado de mujer |

La nota 5 del informe prescribe multiplicar el peso del hogar por el número
de niños **1-17**, aunque el indicador de disciplina abarque **1-14**.
No se utiliza el número de niños 1-14 ni el número de menores de cinco.
El programa exige coincidencia entre SL1 y el conteo HL6 y entre las líneas
SL9B, CD2 y HL1. Se retienen hogares con selección 15-17 y sin niños en el
diseño para estimar el dominio, sin asignarles respuestas de disciplina.

Diccionarios oficiales: [hh](https://microdata.worldbank.org/index.php/catalog/2780/data-dictionary/F3?file_name=hh),
[hl](https://microdata.worldbank.org/index.php/catalog/2780/data-dictionary/F4),
[wm, primera página](https://microdata.worldbank.org/index.php/catalog/2780/data-dictionary/F5),
[wm, campos derivados y peso](https://microdata.worldbank.org/index.php/catalog/2780/data-dictionary/F5/?offset=300).

## Disciplina, último mes: CD3A-CD3K

Todos los ítems del cuestionario: **1 sí, 2 no**. Otros valores o perdidos SPSS
no se tratan como respuestas sustantivas. El programa admite 8/9 como
desconocidos de distribución, sin afirmar que sean categorías impresas de CD3.

| Campo | Contenido resumido | Grupo |
| --- | --- | --- |
| CD3A | Quitar privilegios | No violento |
| CD3B | Explicar conducta incorrecta | No violento |
| CD3C | Sacudir | Físico, ítem fuera del subgrupo severo |
| CD3D | Gritar | Psicológico |
| CD3E | Dar otra actividad | No violento |
| CD3F | Nalgada con mano | Físico, ítem fuera del subgrupo severo |
| CD3G | Golpear con objeto duro | Físico, ítem fuera del subgrupo severo |
| CD3H | Insultar | Psicológico |
| CD3I | Golpear cara, cabeza u orejas | Físico severo |
| CD3J | Golpear mano, brazo o pierna | Físico, ítem fuera del subgrupo severo |
| CD3K | Paliza repetida y fuerte | Físico severo |

`CD3G` por sí solo no pertenece al subgrupo severo de la definición MICS.
`CD3K` no exige que se haya usado un objeto. El nombre
`fisico_items_no_severos` describe esos ítems, **no** niños libres de castigo
severo: puede coexistir con CD3I/CD3K. No se minimiza la gravedad de esos actos.
`solo_disciplina_no_violenta` exige algún A/B/E y ausencia de todos los actos
violentos. `CD4` es una actitud hacia el castigo físico, no una práctica, y no
entra en el indicador de violencia experimentada.

## Actitudes: DV1A-DV1J

Cuestionario: **1 sí, 2 no, 8 no sabe**. Los cinco escenarios A-E son salir sin
avisar, descuidar niños, discutir, negarse a relaciones sexuales y quemar comida.
Los cinco adicionales F-J son hablar con otro hombre, salir con amistades,
hablar con familiares, no compartir ingresos y tocar pertenencias del esposo.
`justifica_5` usa A-E; `justifica_10` usa A-J. Universo: mujeres entrevistadas
de 15-49 años, independientemente del estado conyugal.

## Primera unión

| Campo | Código o unidad verificados |
| --- | --- |
| WB2 | Edad actual en años cumplidos |
| MA1 | 1 casada actualmente; 2 acompañada; 3 no en unión |
| MA5 | Solo si MA1=3: 1 casada en el pasado; 2 acompañada en el pasado; **3 nunca** |
| MA9 | Edad en años al empezar a vivir con primer esposo/pareja |
| MA8M, MA8Y | Mes/año de primera unión; no sabe 98/9998 en cuestionario |
| wage, wagem | Variables derivadas de edad actual y primera unión disponibles en wm |

Esta versión utiliza **WB2 y MA9 declarados**, con MA1/MA5 para establecer
historia conyugal. No sustituye silenciosamente MA9 por `wagem`. Un análisis
de réplica oficial deberá cotejar ambas y documentar edición e imputación de
fechas; esta es una limitación explícita del presente estimando.

Nunca unida: MA1=3 **y** MA5=3, resultado cero. Unida actualmente: MA1=1/2;
unida antes: MA1=3 y MA5=1/2. En estas últimas, MA9 faltante/desconocida produce
NA. Se reconocen 98/99 como edades desconocidas; una edad futura, fraccionaria
o incompatible con la trayectoria detiene el programa. No hay imputación de
edad o fecha. Edades de unión muy bajas ameritan revisión sustantiva del
diccionario observado, sin imponer un mínimo arbitrario que borre eventos.

Indicadores principales: edad de primera unión **<15** y **<18**, en todas las
mujeres 20-24. No restringir el denominador a alguna vez unidas. El informe
también publica grupos más amplios (15-49 y 20-49); no se confunden con la cohorte
20-24 aquí seleccionada. Una edad exactamente 15 no es “antes de 15”.

## Alcance de la verificación

Se verificaron nombres y contenidos contra documentación pública. No se
inspeccionaron registros reales ni se certificó la distribución de códigos
en un archivo del usuario. Cada ejecución exporta el diccionario observado y
se detiene ante códigos no admitidos, llaves inválidas o diseño incompleto.
