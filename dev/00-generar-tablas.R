library(usethis)
library(tibble)
library(purrr)
library(jsonlite)
library(data.table)

use_directory("data-raw", ignore = T)

download.file("https://mindicador.cl/api", "data-raw/indicadores.json")

indicadores <- fromJSON("https://mindicador.cl/api")
indicadores <- indicadores[!names(indicadores) %in% c("version", "autor", "fecha")]

codigos <- names(indicadores)

mindicador_indicadores <- map_df(
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

mindicador_indicadores <- as.data.table(mindicador_indicadores)
# sacado de tabla html en home de mindicador.cl
mindicador_indicadores$desde <- c(1977,1990,1984,1988,1999,1928,1990,1997,2001,2012,2009,2009)

use_data(mindicador_indicadores)
