# Validacion de llaves, elegibilidad y ponderadores, antes de estimar.
assert_unique <- function(data, keys, label) {
  require_vars(data, keys, label)
  if (anyNA(data[keys]) || any(duplicated(data[keys])))
    stop(label, ": llaves ausentes o duplicadas")
}

assert_design <- function(data) {
  if (any(!is.finite(data$peso) | data$peso <= 0) ||
      anyNA(data$upm) || anyNA(data$estrato))
    stop("Diseno incompleto: se requieren pesos positivos, psu y stratum")
  if (any(data$upm != floor(data$upm)) || any(data$estrato != floor(data$estrato)))
    stop("psu y stratum deben ser identificadores enteros")
}

household_covariates <- function(hh) {
  hh |>
    dplyr::transmute(hh1, hh2, upm = psu, estrato = stratum,
      area = factor(hh6, levels = c(1, 2), labels = c("Urbana", "Rural")),
      quintil = factor(windex5, levels = 1:5),
      departamento = factor(hh7a))
}

prepare_data <- function(hh, hl, wm) {
  require_vars(hh, c("hh1", "hh2", "hh9", "sl1", "sl9b", "sl9c", "cd2",
    paste0("cd3", letters[1:11]), "hh6", "hh7a", "windex5", "hhweight",
    "psu", "stratum"), "hh.sav")
  require_vars(hl, c("hh1", "hh2", "hl1", "hl4", "hl6"), "hl.sav")
  require_vars(wm, c("hh1", "hh2", "wm4", "wm7", "wb2", "ma1", "ma5",
    "ma9", paste0("dv1", letters[1:10]), "wmweight"), "wm.sav")
  # Convertir solo despues del inventario de etiquetas/codigos SPSS del ejecutor.
  hh <- hh |> dplyr::select(hh1, hh2, hh9, sl1, sl9b, sl9c, cd2,
    dplyr::all_of(paste0("cd3", letters[1:11])), hh6, hh7a, windex5,
    hhweight, psu, stratum) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), num))
  hl <- hl |> dplyr::select(hh1, hh2, hl1, hl4, hl6) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), num))
  wm <- wm |> dplyr::select(hh1, hh2, wm4, wm7, wb2, ma1, ma5, ma9,
    dplyr::all_of(paste0("dv1", letters[1:10])), wmweight) |>
    dplyr::mutate(dplyr::across(dplyr::everything(), num))
  assert_unique(hh, c("hh1", "hh2"), "hh")
  assert_unique(hl, c("hh1", "hh2", "hl1"), "hl")
  assert_unique(wm, c("hh1", "hh2", "wm4"), "wm")
  hh <- dplyr::filter(hh, hh9 == 1)
  wm <- dplyr::filter(wm, wm7 == 1)
  if (!nrow(hh) || !nrow(wm)) stop("No hay entrevistas completas")
  if (anyNA(wm$wb2) || any(!dplyr::between(wm$wb2, 15, 49)))
    stop("WB2 fuera del universo de mujeres 15-49")
  assert_codes(hh$hh6, c(1, 2), "HH6")
  assert_codes(hh$windex5, 1:5, "windex5")
  if (anyNA(hh$sl1) || any(hh$sl1 < 0 | hh$sl1 != floor(hh$sl1)))
    stop("SL1 debe contar ninos de 1-17, sin ausencias")
  counts <- hl |> dplyr::group_by(hh1, hh2) |>
    dplyr::summarise(n_1_17 = sum(dplyr::between(hl6, 1, 17), na.rm = TRUE),
                     .groups = "drop")
  children <- hh |>
    dplyr::left_join(counts, by = c("hh1", "hh2"), relationship = "one-to-one")
  if (anyNA(children$n_1_17) || any(children$sl1 != children$n_1_17))
    stop("SL1 no coincide con el conteo de miembros HL6 de 1-17 anos")
  roster <- hl |> dplyr::transmute(hh1, hh2, sl9b = hl1,
                                  edad = hl6, sexo_raw = hl4)
  children <- children |> dplyr::left_join(roster,
    by = c("hh1", "hh2", "sl9b"), relationship = "many-to-one",
    na_matches = "never")
  eligible_hh <- children$sl1 > 0
  if (any(eligible_hh & (is.na(children$edad) |
      !dplyr::between(children$edad, 1, 17))))
    stop("No se puede vincular al nino seleccionado SL9B con HL1")
  if (any(eligible_hh & (is.na(children$sl9c) |
                        children$edad != children$sl9c)))
    stop("SL9C y HL6 no coinciden para el nino seleccionado")
  domain <- eligible_hh & !is.na(children$edad) & children$edad <= 14
  if (any(domain & (is.na(children$cd2) | children$cd2 != children$sl9b)))
    stop("CD2 debe identificar al mismo nino que SL9B")
  indicators <- discipline(children)
  indicators[!domain, ] <- NA_integer_
  children <- dplyr::bind_cols(children, indicators) |>
    dplyr::mutate(dominio = domain,
      # Mantener TODOS los hogares entrevistados en el diseno para dominios.
      # El peso positivo de hogares sin ninos es auxiliar: no aporta al dominio.
      peso = hhweight * ifelse(sl1 > 0, sl1, 1),
      grupo_edad = cut(edad, c(0, 4, 9, 14, 17),
                       labels = c("1-4", "5-9", "10-14", "15-17")),
      sexo = factor(sexo_raw, c(1, 2), c("Masculino", "Femenino"))) |>
    dplyr::left_join(household_covariates(hh), by = c("hh1", "hh2"),
                     relationship = "one-to-one")
  # La seleccion explicita evita sufijos .x/.y cuando wm incluye el diseno.
  women <- wm |> dplyr::select(hh1, hh2, wm4, wb2, ma1, ma5, ma9, wmweight,
                               dplyr::all_of(paste0("dv1", letters[1:10])))
  if (nrow(dplyr::anti_join(women, hh, by = c("hh1", "hh2"))))
    stop("Hay mujeres sin hogar entrevistado vinculado")
  women <- dplyr::bind_cols(
    dplyr::select(women, -dplyr::starts_with("dv1")), attitudes(women),
    early_union(women$wb2, women$ma1, women$ma5, women$ma9)) |>
    dplyr::left_join(household_covariates(hh), by = c("hh1", "hh2"),
                     relationship = "many-to-one") |>
    dplyr::mutate(edad = wb2, peso = wmweight, dominio = TRUE,
      grupo_edad = cut(edad, c(14, 19, 24, 34, 49),
                       labels = c("15-19", "20-24", "25-34", "35-49")),
      cohorte_20_24 = edad >= 20 & edad <= 24)
  assert_design(children); assert_design(women)
  list(children = children, women = women)
}
