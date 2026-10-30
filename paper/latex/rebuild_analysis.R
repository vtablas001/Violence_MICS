# Reproduce only arithmetic on published aggregates. Base R; no SAV needed.
# Run from this LaTeX directory: Rscript rebuild_analysis.R
# Input transcriptions remain unchanged. Only named derived files are replaced.
if (.Platform$OS.type == "windows") {
  # Windows does not recognize the C.UTF-8 locale inherited in some terminals.
  locale <- Sys.setlocale("LC_CTYPE", "English_United States.utf8")
  if (!nzchar(locale)) stop("Se requiere una configuracion regional UTF-8")
}
read <- function(name) read.csv(file.path("data", name), check.names = FALSE,
                               na.strings = c("", "NA"), fileEncoding = "UTF-8")
write <- function(x, name) write.csv(x, file.path("data", name), row.names = FALSE, quote = FALSE,
                                   na = "", fileEncoding = "UTF-8")
d <- read("disciplina.csv")
value <- function(key) d$porcentaje[match(key, d$indicador)]
psy <- value("agresion_psicologica")
phy <- value("castigo_fisico")
any <- value("disciplina_violenta")
both <- psy + phy - any
partition <- c(psy - both, both, phy - both, 100 - any)
stopifnot(length(partition) == 4L, all(is.finite(partition)),
          all(partition >= 0), abs(sum(partition) - 100) < 1e-8,
          abs(partition[1] + partition[2] - psy) < 1e-8,
          abs(partition[2] + partition[3] - phy) < 1e-8)
write(data.frame(pos = 0:3, categoria = c("Solo psicologica", "Ambas",
  "Solo fisica", "Ninguna de las dos"), porcentaje = round(partition, 1)),
  "derivada_solapamiento.csv")

h <- read("infosegura_homicidios.csv")
stopifnot(all(h$proyeccion == as.integer(h$anio == 2021)),
          all(h$proyeccion[h$anio %in% c(2015, 2020)] == 0))
fields <- c("total", "hombres", "mujeres", "feminicidios")
initial <- as.numeric(h[h$anio == 2015, fields])
final <- as.numeric(h[h$anio == 2020, fields])
changes <- data.frame(indicador = fields, tasa2015 = initial, tasa2020 = final,
  cambio_tasa = final - initial, cambio_porcentual = 100 * (final / initial - 1))
write(changes, "derivada_homicidios_cambios.csv")
# Typeset table rows from full-precision calculations, display one decimal.
labels <- c("Homicidios, total", "Homicidios, hombres", "Homicidios, mujeres",
            "Feminicidios")
num <- function(x) chartr(".", ",", sprintf("%.1f", x))
rows <- sprintf("%s & %s & %s & %s & %s\\\\", labels, num(initial),
  num(final), num(changes$cambio_tasa), num(changes$cambio_porcentual))
writeLines(enc2utf8(c(rows, "\\bottomrule")), "data/derivada_homicidios_filas.tex", useBytes = TRUE)

age <- read("disciplina_edad.csv")
wealth <- read("disciplina_riqueza.csv")
cohort <- read("union_cohortes.csv")
stopifnot(all(age$severa <= age$fisica), all(wealth$severa <= wealth$fisica),
          all(age$violenta >= pmax(age$psicologica, age$fisica)),
          all(wealth$violenta >= pmax(wealth$psicologica, wealth$fisica)),
          all(cohort$antes15 <= cohort$antes18), nrow(cohort) == 6L)
v <- read("infosegura_victimizacion.csv")
write(transform(v, brecha_sexo_pp = hombres - mujeres,
  brecha_area_pp = urbana - rural), "derivada_victimizacion_brechas.csv")
p <- read("infosegura_preocupaciones.csv")
stopifnot(all(is.na(p$covid19[p$anio != 2021])))
perception <- read("infosegura_percepcion.csv")
delta <- function(x, field, start = 2019, end = 2021)
  x[[field]][x$anio == end] - x[[field]][x$anio == start]
summary <- data.frame(contraste = c("Ambas entre disciplina violenta (porcentaje)",
  "Fisica edad 3-4 menos 10-14 (pp)", "Psicologica 10-14 menos 1-2 (pp)",
  "Violenta Q5 menos Q1 (pp)", "Union antes18 20-24 menos 45-49 (pp)",
  "Union desde15 antes18 en 20-24 (porcentaje)",
  "Union desde15 antes18 entre unidas antes18 en 20-24 (porcentaje)",
  "Economia 2021 menos 2019 (pp)", "Seguridad 2021 menos 2019 (pp)",
  "Inseguridad transporte 2021 menos 2019 (pp)",
  "Inseguridad comunidad 2021 menos 2019 (pp)"),
  valor = c(100 * both / any, age$fisica[2] - age$fisica[4],
    age$psicologica[4] - age$psicologica[1], wealth$violenta[5] - wealth$violenta[1],
    cohort$antes18[1] - cohort$antes18[6],
    cohort$antes18[1] - cohort$antes15[1],
    100 * (cohort$antes18[1] - cohort$antes15[1]) / cohort$antes18[1],
    delta(p, "economia"),
    delta(p, "seguridad"), delta(perception, "transporte_publico"),
    delta(perception, "comunidad")))
write(summary, "derivada_contrastes.csv")
deprivation <- read("infosegura_privaciones.csv")
stopifnot(nrow(deprivation) == 20L, !anyNA(deprivation),
          sum(deprivation$variacion_pp_2019_2020 > 0) == 7L,
          sum(deprivation$variacion_pp_2019_2020 < 0) == 11L)
write(data.frame(pos = 0:19, cambio = deprivation$variacion_pp_2019_2020),
      "derivada_privaciones.csv")
message("Identidades, dominios y proyecciones verificados; derivados regenerados.")
