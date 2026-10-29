testthat::test_that("seleccion infantil, pesos y llaves son verificables", {
  x <- synthetic_data(); p <- prepare_data(x$hh, x$hl, x$wm)
  testthat::expect_equal(p$children$peso,
    x$hh$hhweight * ifelse(x$hh$sl1 > 0, x$hh$sl1, 1))
  testthat::expect_equal(nrow(p$women), 192L)
  testthat::expect_equal(p$women$peso, x$wm$wmweight)
  testthat::expect_false(any(grepl("\\.x$|\\.y$", names(p$women))))
  testthat::expect_true(any(p$children$edad == 16, na.rm = TRUE))
  testthat::expect_true(all(is.na(p$children$disciplina_violenta[!p$children$dominio])))
  bad <- x; bad$hh$sl1[1] <- 5
  testthat::expect_error(prepare_data(bad$hh, bad$hl, bad$wm), "SL1 no coincide")
  bad <- x; bad$hl <- dplyr::bind_rows(bad$hl, bad$hl[1, ])
  testthat::expect_error(prepare_data(bad$hh, bad$hl, bad$wm), "duplicadas")
  bad <- x; bad$wm$wmweight[1] <- 0
  testthat::expect_error(prepare_data(bad$hh, bad$hl, bad$wm), "pesos positivos")
  bad <- x; bad$hh$cd2[1] <- 9
  testthat::expect_error(prepare_data(bad$hh, bad$hl, bad$wm), "CD2")
})

testthat::test_that("estimacion equivale a razon ponderada y conserva dominios", {
  x <- synthetic_data(); p <- prepare_data(x$hh, x$hl, x$wm)
  d <- make_design(p$children)
  testthat::expect_equal(survey::degf(d), 9L)
  dd <- subset(d, dominio)
  z <- estimate_one(dd, "disciplina_violenta", "prueba")
  testthat::expect_equal(z$porcentaje, 100 * with(dd$variables,
    weighted.mean(disciplina_violenta, peso, na.rm = TRUE)))
  testthat::expect_true(z$li_95 >= 0 && z$ls_95 <= 100)
  dd$variables$disciplina_violenta[1] <- NA
  z <- estimate_one(dd, "disciplina_violenta", "prueba")
  testthat::expect_equal(z$n_faltantes, 1L)
  testthat::expect_lte(z$limite_inferior_faltantes_pct, z$porcentaje)
  testthat::expect_gte(z$limite_superior_faltantes_pct, z$porcentaje)
  small <- estimate_one(dd[1:4, ], "disciplina_violenta", "prueba")
  testthat::expect_true(is.na(small$porcentaje))
  testthat::expect_equal(small$estado, "n_menor_25")
  tab <- analyze(p)
  testthat::expect_setequal(unique(tab$modulo), c("disciplina_1_14", "actitudes_15_49", "union_20_24"))
  testthat::expect_equal(tab$n_elegibles[tab$modulo == "union_20_24" &
    tab$desagregacion == "Total"], rep(sum(p$women$cohorte_20_24), 2))
})

testthat::test_that("lectura SPSS y ejecutor funcionan hasta exportar", {
  dir <- tempfile("MICS_SINTETICO_"); dir.create(dir)
  on.exit(unlink(dir, recursive = TRUE), add = TRUE)
  x <- synthetic_data()
  for (name in names(x)) haven::write_sav(x[[name]], file.path(dir, paste0(name, ".sav")))
  output <- file.path(dir, "SINTETICO_resultados")
  script <- file.path(root, "scripts/run_analysis.R")
  old <- setwd(root); on.exit(setwd(old), add = TRUE)
  old_libs <- Sys.getenv("R_LIBS")
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
  on.exit(Sys.setenv(R_LIBS = old_libs), add = TRUE)
  result <- system2(file.path(R.home("bin"), "Rscript"),
    c(shQuote(script), shQuote(dir), shQuote(output), "--synthetic"),
    stdout = TRUE, stderr = TRUE)
  testthat::expect_null(attr(result, "status"), info = paste(result, collapse = "\n"))
  testthat::expect_true(all(file.exists(file.path(output,
    c("estimaciones.csv", "diccionario_observado.csv", "auditoria_diseno.csv",
      "huellas_archivos.csv", "sessionInfo.txt", "indicadores.png", "LEAME.txt")))))
  tab <- readr::read_csv(file.path(output, "estimaciones.csv"), show_col_types = FALSE)
  testthat::expect_true(all(tab$origen == "SINTETICO_PRUEBA"))
  testthat::expect_false(any(c("hh1", "hh2", "wm4", "cd2") %in% names(tab)))
})
