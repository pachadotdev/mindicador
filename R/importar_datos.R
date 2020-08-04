#' @importFrom jsonlite fromJSON
#' @importFrom crul HttpClient
#' @keywords internal
mindicador_importar_datos_interna <- function(serie, anio, tipo, max_intentos) {
  stopifnot(max_intentos > 0)

  anio_inicio <- switch(serie,
                        "uf" = 1977,
                        "ivp" = 1990,
                        "dolar" = 1984,
                        "dolar_intercambio" = 1988,
                        "euro" = 1999,
                        "ipc" = 1928,
                        "utm" = 1990,
                        "imacec" = 1997,
                        "tpm" = 2001,
                        "libra_cobre" = 2012,
                        "tasa_desempleo" = 2009,
                        "bitcoin" = 2009
  )

  stopifnot(anio >= anio_inicio)

  url <- sprintf("api/%s/%s", serie, anio)
  base_url <- "mindicador.cl"

  resp <- HttpClient$new(url = base_url)
  resp <- resp$get(url)

  # on a successful GET, return the response
  if (resp$status_code == 200) {
    data <- try(fromJSON(resp$parse(encoding = "UTF-8")))
    return(data$serie)
  } else if (max_intentos == 0) {
    # when attempts run out, stop with an error
    stop("Se alcanzo el limite de intentos para conectarse a la API. Intenta mas tarde.")
  } else {
    # otherwise, sleep a second and try again
    Sys.sleep(1)
    mindicador_importar_datos(serie, anio, tipo, max_intentos = max_intentos - 1)
  }
}

#' @importFrom data.table rbindlist
#' @keywords internal
mindicador_importar_datos_unmemoised <- function(series, anios, tipo, max_intentos) {
  condensed_parameters <- expand.grid(
    serie = series,
    anio = anios,
    stringsAsFactors = FALSE
  )

  data <- lapply(
    seq_len(nrow(condensed_parameters)),
    function(x) {
      d <- mindicador_importar_datos_interna(
        serie = condensed_parameters$serie[x],
        anio = condensed_parameters$anio[x],
        tipo = tipo,
        max_intentos = max_intentos
      )

      d$serie <- condensed_parameters$serie[x]
      d$fecha <- as.Date(d$fecha)
      d <- d[ , c("serie","fecha","valor")]

      return(d)
    }
  )

  data <- rbindlist(data, fill = TRUE)
  data <- unique(data)
  data <- as.data.frame(data)
  data <- data[order(data$fecha, decreasing = TRUE), ]

  return(data)
}

#' @importFrom memoise memoise
#' @keywords internal
mindicador_importar_datos_memoised <- memoise::memoise(mindicador_importar_datos_unmemoised)

#' Obtiene datos de mindicador.cl
#' @description Se conecta a la API y realiza algunas transformaciones al input en formato JSON
#' para facilitar el uso de estos datos con distintas funciones de R
#' @return un objeto data.frame o xts con los datos solicitados por el usuario
#' @param series Cualquiera de los codigos de \code{mindicador::mindicador_indicadores}
#' @param anios Anios validos para las distintas series (ver \code{mindicador::mindicador_indicadores})
#' @param tipo data.frame o xts
#' @param max_intentos Por defecto son cinco
#' @param usar_cache Valor logico para leer y escribir en cache. Si es \code{TRUE}, los resultados quedan cacheados en
#' memoria si \code{archivo} es \code{NULL} o en disco si `archivo` es una cadena de texto.
#' @importFrom data.table dcast as.data.table
#' @importFrom xts xts
#' @param archivo Ruta del archivo para leer y escribir la cache.
#' @examples
#' mindicador_importar_datos("uf", 2020)
#' @keywords functions
#' @export
mindicador_importar_datos <- function(series = "uf", anios = 2020, tipo = "data.frame", max_intentos = 5, usar_cache = FALSE, archivo = NULL) {
  stopifnot(all(is.character(series)))
  stopifnot(all(series %in% mindicador::mindicador_indicadores$codigo))
  stopifnot(all(is.numeric(anios)))
  stopifnot(is.logical(usar_cache))
  stopifnot(is.null(archivo) | is.character(archivo))

  data <- mindicador_cache(
    usar_cache = usar_cache,
    archivo = archivo,
    series = series,
    anios = anios,
    tipo = tipo,
    max_intentos = max_intentos
  )

  if (tipo == "xts") {
    data <- dcast(as.data.table(data), fecha ~ serie, value.var = "valor")
    data <- xts(data[ , -"fecha"], order.by = data$fecha)
  }

  return(data)
}
