context("testthat.R")

test_that("importar_datos returns valid tables with a valid input", {
  vcr::use_cassette(name = "uf-2020-06-05", {
    # Mock countries test inside ots_create_tidy_data
    cli <- crul::HttpClient$new(url = "https://mindicador.cl/api")
    res <- cli$get("uf/2020")
    expect_is(res, "HttpResponse")

    # default parameters
    test_data <- mindicador_importar_datos()
    expect_is(test_data, "data.frame")
    expect_equal(ncol(test_data), 3)

    # using cache
    test_data_2 <- mindicador_importar_datos(usar_cache = T)
    expect_is(test_data_2, "data.frame")
    expect_equal(ncol(test_data_2), 3)

    test_data_3 <- mindicador_importar_datos(usar_cache = T, archivo = tempfile())
    expect_is(test_data_3, "data.frame")
    expect_equal(ncol(test_data_3), 3)

    # using xts
    test_data_4 <- mindicador_importar_datos(tipo = "xts")
    expect_s3_class(test_data_4, "xts")
  })
})
