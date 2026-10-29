# Ejecutar desde la raiz. Las pruebas nunca utilizan microdatos reales.
for (f in c("indicators", "prepare", "estimation")) source(paste0("R/", f, ".R"))
root <- normalizePath(".", winslash = "/")
testthat::test_dir("tests/testthat", reporter = "summary", stop_on_failure = TRUE,
                   env = environment())
