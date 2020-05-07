#' @importFrom jsonlite fromJSON
#' @importFrom crul HttpClient
#' @keywords internal
mindicador_importar_datos_interna <- function(serie = "uf", anio = 2020, tipo = "data.frame", max_intentos = 5) {
  stopifnot(max_intentos > 0)

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
    stop("foo bar")
  } else {
    # otherwise, sleep a second and try again
    Sys.sleep(1)
    mindicador_importar_datos(serie, anio, tipo, max_intentos = max_intentos - 1)
  }
}

#' @importFrom data.table rbindlist
#' @keywords internal
mindicador_importar_datos_unmemoised <- function(series = "uf", anios = 2020, tipo = "data.frame", max_intentos = 5) {
  condensed_parameters <- expand.grid(
    serie = series,
    anio = anios,
    stringsAsFactors = FALSE
  )

  data <- lapply(
    seq_len(nrow(condensed_parameters)),
    function(x) {
      mindicador_importar_datos_interna(
        serie = condensed_parameters$serie[x],
        anio = condensed_parameters$anio[x],
        tipo = tipo,
        max_intentos = max_intentos
      )
    }
  )

  data <- rbindlist(data, fill = TRUE)

  return(data)
}

#' @importFrom memoise memoise
#' @keywords internal
mindicador_importar_datos_memoised <- memoise::memoise(mindicador_importar_datos_unmemoised)

#' Obtiene datos de mindicador.cl
#' @description Se conecta a la API y realiza algunas transformaciones al input en formato JSON
#' para facilitar el uso de estos datos con distintas funciones de R
#' @param series Cualquiera de los codigos de \code{mindicador::indicadores}
#' @param anios foo bar
#' @param tipo Por ahora solo "data.frame"
#' @param max_intentos Por defecto son cinco
#' @param usar_cache Valor logico para leer y escribir en cache. Si es \code{TRUE}, los resultados quedan cacheados en
#' memoria si \code{archivo} es \code{NULL} o en disco si `archivo` es una cadena de texto.
#' @param archivo Ruta del archivo para leer y escribir la cache.
#' @examples
#' \dontrun{
#' # foo bar
#' }
#' @keywords functions
#' @export
mindicador_importar_datos <- function(series = "uf", anios = 2020, tipo = "data.frame", max_intentos = 5, usar_cache = F, archivo = NULL) {
  stopifnot(all(is.character(series)))
  stopifnot(all(series %in% mindicador::indicadores$codigo))
  stopifnot(all(is.numeric(anios)))
  stopifnot(is.logical(usar_cache))
  stopifnot(is.null(archivo) | is.character(archivo))

  mindicador_cache(
    usar_cache = usar_cache,
    archivo = archivo,
    series = series,
    anios = anios,
    tipo = tipo,
    max_intentos = max_intentos
  )
}
