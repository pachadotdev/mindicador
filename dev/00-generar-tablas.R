library(usethis)
library(purrr)
library(jsonlite)

use_directory("data-raw", ignore = T)

download.file("https://mindicador.cl/api", "data-raw/indicadores.json")

indicadores <- fromJSON("https://mindicador.cl/api")
indicadores <- indicadores[!names(indicadores) %in% c("version", "autor", "fecha")]

codigos <- names(indicadores)

indicadores <- map_df(
  seq_len(length(indicadores)),
  function(j) {
    d <- indicadores[codigos[j]]
    d <- d[[1]]

    tibble(
      nombre = d$nombre,
      codigo = d$codigo,
      unidad = d$unidad_medida
    )
  }
)

use_data(indicadores)
