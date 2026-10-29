# Inferencia descriptiva con estratos y conglomerados; no identifica causalidad.
make_design <- function(data) {
  assert_design(data)
  survey::svydesign(ids = ~upm, strata = ~estrato, weights = ~peso,
                     data = data, nest = TRUE)
}

estimate_one <- function(design, variable, module, group = "Total", level = "Total",
                         min_n = 25L) {
  d <- design$variables
  valid <- !is.na(d[[variable]])
  w <- as.numeric(stats::weights(design))
  n <- nrow(d); observed <- sum(valid); yes <- sum(d[[variable]] == 1, na.rm = TRUE)
  denominator <- sum(w)
  out <- dplyr::tibble(modulo = module, indicador = variable,
    desagregacion = group, categoria = level,
    n_elegibles = n, n_observados = observed, n_si = yes,
    n_faltantes = n - observed, porcentaje = NA_real_, ee_pp = NA_real_,
    li_95 = NA_real_, ls_95 = NA_real_,
    faltantes_ponderados_pct = if (n) 100 * sum(w[!valid]) / denominator else NA_real_,
    limite_inferior_faltantes_pct = if (n) 100 * sum(w[valid] * d[[variable]][valid]) / denominator else NA_real_,
    limite_superior_faltantes_pct = if (n) 100 * (sum(w[valid] * d[[variable]][valid]) + sum(w[!valid])) / denominator else NA_real_,
    gl_diseno = NA_real_, estado = "sin_observaciones")
  if (!observed) return(out)
  vd <- design[valid, ]  # subset del diseno, nunca reconstruir la muestra.
  out$gl_diseno <- survey::degf(vd)
  if (observed < min_n) {out$estado <- "n_menor_25"; return(out)}
  est <- survey::svymean(stats::reformulate(variable), vd)
  out$porcentaje <- 100 * as.numeric(stats::coef(est))
  out$ee_pp <- 100 * as.numeric(survey::SE(est))
  out$estado <- "ok"
  if (yes == 0L || yes == observed) {out$estado <- "frontera_sin_ic"; return(out)}
  if (out$gl_diseno <= 0) {out$estado <- "gl_insuficientes"; return(out)}
  ci <- stats::confint(survey::svyciprop(stats::reformulate(variable), vd,
    method = "logit", df = survey::degf(vd)))
  out$li_95 <- 100 * ci[1]; out$ls_95 <- 100 * ci[2]
  out
}

estimate_module <- function(design, variables, module,
                            groups = c("area", "quintil", "grupo_edad")) {
  rows <- lapply(variables, function(v) estimate_one(design, v, module))
  for (g in groups) {
    # La falta de covariable se conserva como categoria, no elimina personas.
    values <- as.character(design$variables[[g]])
    values[is.na(values)] <- "Sin informacion"
    for (value in sort(unique(values))) {
      dd <- design[values == value, ]
      rows <- c(rows, lapply(variables, function(v) estimate_one(dd, v, module, g, value)))
    }
  }
  dplyr::bind_rows(rows)
}

analyze <- function(prepared) {
  old <- options(survey.lonely.psu = "adjust", survey.adjust.domain.lonely = TRUE)
  on.exit(options(old), add = TRUE)
  child_design <- make_design(prepared$children)
  women_design <- make_design(prepared$women)
  discipline_vars <- names(discipline(prepared$children))
  dplyr::bind_rows(
    estimate_module(subset(child_design, dominio), discipline_vars, "disciplina_1_14",
                    c("area", "quintil", "grupo_edad", "sexo")),
    estimate_module(women_design, c("justifica_5", "justifica_10",
      paste0("dv1", letters[1:10])), "actitudes_15_49"),
    estimate_module(subset(women_design, cohorte_20_24),
      c("union_antes_15", "union_antes_18"), "union_20_24", c("area", "quintil")))
}
