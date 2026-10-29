# Auditoría de la propuesta anterior

El repositorio fue inspeccionado con el plugin conectado de GitHub y clonado el
29-10-2026: estaba vacío, sin commits. La comparación siguiente corresponde al
script visible en la conversación “Script PSM MICS El Salvador”, recuperada
mediante su identificador `6ae3b3a3-b04c-83e8-b72b-56b4b0c2bc79`.
No se afirma haber modificado un archivo anterior que estuviera en GitHub.

| Problema anterior | Corrección implementada | Implicación |
| --- | --- | --- |
| `paste0("cd3", LETTERS[1:11])` y DV con mayúsculas después de `clean_names()` | Usar `letters` consistentemente | El script deja de exigir nombres que no existen |
| Disciplina con `hhweight` y selección pendiente | `hhweight * SL1`, contrastado con nota 5 p.306 | Representa selección de un niño entre miembros 1-17 |
| Nunca unida con `MA5 == 2` | `MA1 == 3 & MA5 == 3` | No clasifica antiguas convivientes como nunca unidas |
| Edad de unión 0-49 sin coherencia con edad actual/estado | Control trayectoria, edad actual, enteros y códigos 98/99 | Evita usar edades desconocidas como eventos o negativos |
| Uniones en todas las edades si se interpretan como tasa estándar | Dominio 20-24, incluidas nunca unidas | Evita exposición incompleta de menores de 18 |
| Nombres de diseño pueden duplicarse al unir hh a wm | Selección explícita de campos antes de unir | Evita perder `peso`, `upm` o `estrato` por sufijos |
| Filtrar niños antes de construir diseño | Diseño con hogares entrevistados y dominio posterior | Conserva información de conglomerados para varianza |
| Entrevistas incompletas no excluidas por código de resultado | HH9=1 y WM7=1 | Alinea universos con cuestionarios completos |
| Borrar pesos/diseño ausentes silenciosamente | Fallar ante pesos inválidos, llaves ambiguas y diseño incompleto | Hace revisable la pérdida de cobertura |
| `disciplina_no_violenta` confundible con “solo no violenta” | Publicar ambos con nombres distintos | Reconoce coexistencia de prácticas |
| Golpear con objeto presentado como severo automáticamente | Subgrupo severo I/K, objetos G en físico total | Alinea agrupación con contenido MICS |
| IC normales potencialmente fuera de 0-100 | IC logit; tratar fronteras y gl insuficientes | Evita intervalos imposibles o precisión ficticia |
| NA omitidos sin denominadores | Casos clasificables por indicador, faltantes ponderados y límites extremos | Hace visible sensibilidad a no respuesta |
| Actitudes llamadas variable latente o proxy causal validado | Justificación declarada, sin asumir validación psicométrica | Evita inferencias no sustentadas |

Se mantiene la distinción entre los cinco escenarios internacionales y los
diez del cuestionario salvadoreño. Se conserva la recodificación parcial
prudente del script anterior, ahora con pruebas automatizadas. Los códigos
individuales y las fuentes se detallan en [codigos.md](codigos.md).

No se retomó el análisis inicial de saneamiento/diarrea: el encargo actual
abarca los tres módulos de violencia y protección. No hay tratamiento causal
definido que justifique trasladar automáticamente el PSM a estos indicadores.
