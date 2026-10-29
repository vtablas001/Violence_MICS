#!/usr/bin/env Rscript
# Ejecutar desde la raiz: Rscript scripts/run_analysis.R data/raw results/real
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% c(2L, 3L) || (length(args) == 3L && args[3] != "--synthetic"))
  stop("Uso: Rscript scripts/run_analysis.R DIRECTORIO_DATOS DIRECTORIO_SALIDA [--synthetic]")
synthetic <- length(args) == 3L
needed <- c("dplyr", "haven", "janitor", "survey", "readr", "ggplot2")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Instale las dependencias: ", paste(missing, collapse = ", "))
for (file in c("indicators", "prepare", "estimation")) source(paste0("R/", file, ".R"))
files <- file.path(args[1], c("hh.sav", "hl.sav", "wm.sav"))
if (!all(file.exists(files))) stop("Se requieren hh.sav, hl.sav y wm.sav originales")
if (dir.exists(args[2]) && length(list.files(args[2], all.files = FALSE)))
  stop("La salida debe ser una carpeta vacia/nueva para evitar mezclar ejecuciones")
dir.create(args[2], recursive = TRUE, showWarnings = FALSE)
read_data <- function(path) janitor::clean_names(haven::read_sav(path, user_na = TRUE))
data <- lapply(files, read_data); names(data) <- c("hh", "hl", "wm")
# El inventario se restringe a las variables del analisis. No exportar nombres,
# identificadores, respuestas libres ni frecuencias de variables identificadoras.
used <- list(hh = c("hh9", "sl1", "sl9c", paste0("cd3", letters[1:11]),
  "hh6", "hh7a", "windex5", "hhweight", "psu", "stratum"),
  hl = c("hl4", "hl6"), wm = c("wm7", "wb2", "ma1", "ma5", "ma9",
  paste0("dv1", letters[1:10]), "wmweight"))
dictionary <- dplyr::bind_rows(lapply(names(data), function(f) {
  dplyr::bind_rows(lapply(intersect(used[[f]], names(data[[f]])), function(v) {
    x <- data[[f]][[v]]; labels <- attr(x, "labels")
    dplyr::tibble(archivo = f, variable = v,
      etiqueta = if (is.null(attr(x, "label", exact = TRUE))) "" else
        as.character(attr(x, "label", exact = TRUE)),
      valores = paste(names(labels), labels, sep = "=", collapse = "; "),
      perdidos_spss = paste(attr(x, "na_values"), collapse = "; "))
  }))
}))
readr::write_csv(dictionary, file.path(args[2], "diccionario_observado.csv"))
prepared <- prepare_data(data$hh, data$hl, data$wm)
results <- dplyr::mutate(analyze(prepared),
  origen = if (synthetic) "SINTETICO_PRUEBA" else "MICRODATOS_USUARIO")
readr::write_csv(results, file.path(args[2], "estimaciones.csv"))
audit <- dplyr::bind_rows(lapply(names(prepared), function(m) {
  d <- prepared[[m]]
  dplyr::tibble(modulo = m, filas_diseno = nrow(d), elegibles = sum(d$dominio),
    estratos = dplyr::n_distinct(d$estrato),
    upm = dplyr::n_distinct(interaction(d$estrato, d$upm)),
    estratos_una_upm = sum(tapply(d$upm, d$estrato,
      function(x) length(unique(x))) == 1),
    peso_min = min(d$peso), peso_max = max(d$peso))
}))
readr::write_csv(audit, file.path(args[2], "auditoria_diseno.csv"))
manifest <- dplyr::tibble(archivo = basename(files), md5 = unname(tools::md5sum(files)))
readr::write_csv(manifest, file.path(args[2], "huellas_archivos.csv"))
capture.output(sessionInfo(), file = file.path(args[2], "sessionInfo.txt"))
writeLines(c(if (synthetic) "SINTETICO: prueba artificial, sin resultados de El Salvador." else
  "ENS MICS El Salvador 2014: resultados descriptivos locales.",
  paste("Ejecucion UTC:", format(Sys.time(), tz = "UTC", usetz = TRUE)),
  "Denominador: respuestas clasificables por indicador; faltantes y limites incluidos.",
  "IC95 logit con gl de diseno; estratos solitarios: adjust; revisar auditoria.",
  "Pesos normalizados: sumas no representan totales poblacionales.",
  "No son estimaciones causales ni una replica oficial certificada."),
  file.path(args[2], "LEAME.txt"))
plot_data <- dplyr::filter(results, desagregacion == "Total", !is.na(porcentaje))
plot <- ggplot2::ggplot(plot_data,
  ggplot2::aes(x = porcentaje, y = indicador)) + ggplot2::geom_point() +
  ggplot2::geom_errorbar(ggplot2::aes(xmin = li_95, xmax = ls_95),
                         orientation = "y", width = 0.2, na.rm = TRUE) +
  ggplot2::facet_wrap(~modulo, scales = "free_y", ncol = 1) +
  ggplot2::scale_x_continuous(limits = c(0, 100)) +
  ggplot2::labs(title = if (synthetic) "SINTETICO: prueba artificial" else
    "ENS MICS El Salvador 2014", x = "Porcentaje e IC95", y = NULL,
    caption = "Descriptivo; respuestas clasificables. Revisar faltantes y estados en estimaciones.csv") +
  ggplot2::theme_minimal(base_size = 11)
ggplot2::ggsave(file.path(args[2], "indicadores.png"), plot, width = 10, height = 12)
message("Completado. Solo se exportaron tablas agregadas, auditoria y grafico.")
