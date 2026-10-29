testthat::test_that("respuestas parciales no fabrican negativos", {
  testthat::expect_equal(yes_no(c(1, 2, 8, 9, NA)), c(1L, 0L, NA, NA, NA))
  testthat::expect_error(yes_no(c(0, 1)), "no documentados")
  testthat::expect_equal(any_yes(data.frame(a = c(1, 0, 0, NA),
    b = c(NA, 0, NA, NA))), c(1L, 0L, NA, NA))
  x <- haven::labelled_spss(c(1, 2, 9), labels = c(Si = 1, No = 2), na_values = 9)
  testthat::expect_equal(yes_no(x), c(1L, 0L, NA))
})

testthat::test_that("severidad y solo no violenta siguen CD3", {
  d <- as.data.frame(matrix(2, 4, 11)); names(d) <- paste0("cd3", letters[1:11])
  d$cd3a <- 1; d$cd3g[1] <- 1; d$cd3i[2] <- 1; d$cd3k[3] <- 1
  z <- discipline(d)
  testthat::expect_equal(z$fisico_severo, c(0L, 1L, 1L, 0L))
  testthat::expect_equal(z$castigo_fisico, c(1L, 1L, 1L, 0L))
  testthat::expect_equal(z$solo_disciplina_no_violenta, c(0L, 0L, 0L, 1L))
})

testthat::test_that("MA5=3 es nunca unida; limites son estrictos", {
  z <- early_union(rep(23, 7), c(3, 3, 1, 2, 3, 1, 1),
    c(3, 2, NA, NA, 1, NA, NA), c(NA, NA, 14, 15, 17, 18, 98))
  testthat::expect_equal(z$union_antes_15, c(0L, NA, 1L, 0L, 0L, 0L, NA))
  testthat::expect_equal(z$union_antes_18, c(0L, NA, 1L, 1L, 1L, 0L, NA))
  testthat::expect_error(early_union(23, 3, 3, 14), "incompatible")
  testthat::expect_error(early_union(23, 1, NA, 24), "incompatible")
})
