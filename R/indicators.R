# Funciones puras. Codigos contrastados con el cuestionario ENS 2014,
# apendice F, paginas impresas 474, 507 y 508 (ver docs/codigos.md).
num <- function(x) as.numeric(haven::zap_missing(x))

require_vars <- function(data, vars, label = "datos") {
  absent <- setdiff(vars, names(data))
  if (length(absent)) stop(label, ": faltan ", paste(absent, collapse = ", "))
}

assert_codes <- function(x, allowed, label) {
  bad <- setdiff(unique(num(x)), c(allowed, NA_real_))
  if (length(bad)) stop(label, ": codigos no documentados: ", paste(bad, collapse = ", "))
}

yes_no <- function(x, label = "item") {
  # 8 = no sabe (DV); 9 = sin respuesta en distribuciones SPSS.
  # Una etiqueta SPSS de valor perdido tambien se convierte en NA.
  assert_codes(x, c(1, 2, 8, 9), label)
  dplyr::case_when(num(x) == 1 ~ 1L, num(x) == 2 ~ 0L,
                  TRUE ~ NA_integer_)
}

any_yes <- function(data) {
  # Una respuesta afirmativa identifica el evento aun con otros items perdidos.
  # Para identificar ausencia hacen falta todas las respuestas negativas.
  m <- as.matrix(data)
  if (!ncol(m)) stop("Se requiere al menos un item")
  dplyr::case_when(rowSums(m == 1, na.rm = TRUE) > 0 ~ 1L,
                  rowSums(is.na(m)) == 0 ~ 0L, TRUE ~ NA_integer_)
}

discipline <- function(data) {
  cols <- paste0("cd3", letters[1:11])
  require_vars(data, cols)
  z <- as.data.frame(lapply(cols, function(v) yes_no(data[[v]], v)))
  names(z) <- cols
  take <- function(suffix) any_yes(z[paste0("cd3", suffix)])
  physical <- take(c("c", "f", "g", "i", "j", "k"))
  violent <- take(c("c", "d", "f", "g", "h", "i", "j", "k"))
  peaceful <- take(c("a", "b", "e"))
  dplyr::tibble(
    agresion_psicologica = take(c("d", "h")),
    fisico_items_no_severos = take(c("c", "f", "g", "j")),
    fisico_severo = take(c("i", "k")),
    castigo_fisico = physical,
    disciplina_violenta = violent,
    algun_metodo_no_violento = peaceful,
    # Los metodos no violentos pueden coexistir con violencia.
    solo_disciplina_no_violenta = dplyr::case_when(
      violent == 1 | peaceful == 0 ~ 0L,
      violent == 0 & peaceful == 1 ~ 1L, TRUE ~ NA_integer_)
  )
}

attitudes <- function(data) {
  cols <- paste0("dv1", letters[1:10])
  require_vars(data, cols)
  z <- as.data.frame(lapply(cols, function(v) yes_no(data[[v]], v)))
  names(z) <- cols
  dplyr::bind_cols(dplyr::as_tibble(z), dplyr::tibble(
    justifica_5 = any_yes(z[1:5]), justifica_10 = any_yes(z)))
}

early_union <- function(age, ma1, ma5, ma9) {
  age <- num(age); ma1 <- num(ma1); ma5 <- num(ma5); ma9 <- num(ma9)
  assert_codes(ma1, c(1, 2, 3, 8, 9), "MA1")
  assert_codes(ma5, c(1, 2, 3, 8, 9), "MA5")
  never <- !is.na(ma1) & ma1 == 3 & !is.na(ma5) & ma5 == 3
  ever <- (!is.na(ma1) & ma1 %in% c(1, 2)) |
    (!is.na(ma1) & ma1 == 3 & !is.na(ma5) & ma5 %in% c(1, 2))
  reported <- !is.na(ma9) & !ma9 %in% c(98, 99)
  # No convertir contradicciones ni edades futuras en ceros.
  if (any(reported & (!ever | ma9 < 0 | ma9 > age | ma9 != floor(ma9))))
    stop("MA9 incompatible con edad actual o trayectoria MA1/MA5")
  first <- ifelse(ever & reported, ma9, NA_real_)
  indicator <- function(threshold) dplyr::case_when(
    never ~ 0L, ever & !is.na(first) ~ as.integer(first < threshold),
    TRUE ~ NA_integer_)
  dplyr::tibble(edad_primera_union = first,
                union_antes_15 = indicator(15), union_antes_18 = indicator(18))
}
