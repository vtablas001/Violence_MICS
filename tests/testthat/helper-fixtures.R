# Datos completamente artificiales. No calibrados a prevalencias salvadorenas.
synthetic_data <- function() {
  set.seed(2014)
  n <- 96L
  hh <- dplyr::tibble(hh1 = rep(1:12, each = 8), hh2 = rep(1:8, 12),
    hh9 = 1, sl1 = ifelse(seq_len(n) %% 8 == 0, 0, ifelse(seq_len(n) %% 3 == 0, 2, 1)),
    sl9b = ifelse(sl1 > 0, 1, NA_real_),
    sl9c = ifelse(sl1 > 0, rep(c(3, 7, 11, 16), length.out = n), NA_real_),
    cd2 = ifelse(sl9c <= 14, 1, NA_real_), hh6 = rep(1:2, length.out = n),
    hh7a = rep(1:3, each = 32), windex5 = rep(1:5, length.out = n),
    hhweight = seq(0.5, 2, length.out = n), psu = hh1,
    stratum = rep(1:3, each = 32))
  for (v in paste0("cd3", letters[1:11])) {
    hh[[v]] <- sample(c(1, 2), n, replace = TRUE, prob = c(0.15, 0.85))
    hh[[v]][is.na(hh$cd2)] <- NA_real_
    hh[[v]] <- haven::labelled(hh[[v]], c(Si = 1, No = 2))
  }
  hl <- dplyr::bind_rows(lapply(seq_len(n), function(i) {
    count <- max(1L, hh$sl1[i])
    dplyr::tibble(hh1 = hh$hh1[i], hh2 = hh$hh2[i], hl1 = seq_len(count),
      hl4 = rep(1:2, length.out = count),
      hl6 = if (hh$sl1[i] == 0) 35 else c(hh$sl9c[i], rep(15, count - 1L)))
  }))
  wm <- hh[rep(seq_len(n), each = 2), c("hh1", "hh2")]
  wm$wm4 <- rep(c(20, 21), n); wm$wm7 <- 1
  wm$wb2 <- rep(c(21, 35, 23, 28), length.out = nrow(wm))
  wm$ma1 <- rep(c(1, 2, 3, 3), length.out = nrow(wm))
  wm$ma5 <- rep(c(NA, NA, 3, 2), length.out = nrow(wm))
  wm$ma9 <- rep(c(14, 18, NA, 16), length.out = nrow(wm))
  wm$wmweight <- rep(seq(0.6, 1.8, length.out = n), each = 2)
  # Las columnas del archivo wm original no deben generar sufijos al unir tablas.
  wm$psu <- rep(hh$psu, each = 2); wm$stratum <- rep(hh$stratum, each = 2)
  for (v in paste0("dv1", letters[1:10]))
    wm[[v]] <- haven::labelled(sample(c(1, 2, 8), nrow(wm), TRUE), c(Si = 1, No = 2, NS = 8))
  list(hh = hh, hl = hl, wm = wm)
}
