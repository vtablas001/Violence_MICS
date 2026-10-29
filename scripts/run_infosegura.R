# Analisis descriptivo de agregados secundarios; no une personas con MICS.
# Desde la raiz: Rscript -e 'renv::load(); source("scripts/run_infosegura.R")' results/infosegura
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Indique una carpeta nueva de salida")
out <- args[1]
if (dir.exists(out) && length(list.files(out))) stop("La salida debe estar vacia")
path <- file.path("paper", "latex", "data")
read <- function(name) readr::read_csv(file.path(path, name), show_col_types = FALSE)
h <- read("infosegura_homicidios.csv")
v <- read("infosegura_victimizacion.csv")
concerns <- read("infosegura_preocupaciones.csv")
stopifnot(identical(h$anio, as.numeric(2013:2021)),
          identical(v$anio, c(2017, 2018, 2019, 2021)),
          all(h$feminicidios <= h$mujeres), all(h$total >= 0),
          all(h$proyeccion == as.integer(h$anio == 2021)),
          all(v$total >= 0 & v$total <= 100),
          all(is.na(concerns$covid19[concerns$anio != 2021])))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
point <- function(year, field) h[[field]][h$anio == year]
changes <- dplyr::tibble(
  indicador = "homicidios_total", inicio = 2015, fin = 2020,
  valor_inicial = point(2015, "total"), valor_final = point(2020, "total"),
  cambio_tasa = valor_final - valor_inicial,
  cambio_porcentual = 100 * (valor_final / valor_inicial - 1),
  unidad = "tasa por 100000 habitantes; ambos puntos no proyectados",
  fuente = "Infosegura 2021, diapositiva 4")
gaps <- v |> dplyr::mutate(brecha_sexo_pp = hombres - mujeres,
  brecha_area_pp = urbana - rural,
  fuente = "Infosegura 2021, diapositiva 10; sin IC propios")
readr::write_csv(changes, file.path(out, "cambio_homicidios_2015_2020.csv"))
readr::write_csv(gaps, file.path(out, "victimizacion_y_brechas.csv"))
readr::write_csv(dplyr::filter(h, proyeccion == 1),
  file.path(out, "proyecciones_2021_no_cierre_anual.csv"))
readr::write_csv(concerns, file.path(out, "preocupaciones_pais.csv"))
writeLines(c("Resultados descriptivos de caches de graficos de Infosegura.",
  "No son reestimaciones con microdatos ni inferencias causales.",
  "Las diferencias de encuestas carecen de IC propios; no afirmar significacion.",
  "2021 en homicidios es proyeccion de la presentacion, no cierre anual.",
  "No se combinan estas filas con los registros individuales de MICS."),
  file.path(out, "LEAME.txt"))
capture.output(sessionInfo(), file = file.path(out, "sessionInfo.txt"))
message("Agregados verificados y exportados, manteniendo proyecciones separadas.")
