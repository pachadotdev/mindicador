#' @importFrom data.table fread fwrite
#' @importFrom digest digest
#' @importFrom memoise forget
#' @keywords internal
mindicador_cache <- function(usar_cache, archivo, ...) {
  # cache in memory
  if (usar_cache == TRUE && is.null(archivo)) {
    return(mindicador_importar_datos_memoised(...))
  }

  # cache in file ----
  if (!is.null(archivo)) {
    hash <- digest(list(body(mindicador_importar_datos_unmemoised), ...))
  }

  if (usar_cache == TRUE && file.exists(archivo)) {
    d <- fread(archivo, yaml = TRUE)

    if (d$.hash[1] == hash) {
      d$.hash <- NULL
      return(d)
    }
  }

  d <- mindicador_importar_datos_unmemoised(...)

  if (!is.null(archivo)) {
    d$.hash <- hash
    fwrite(d, archivo, yaml = TRUE)
    d$.hash <- NULL
  }

  if (usar_cache == FALSE) {
    forget(mindicador_importar_datos_memoised)
  }

  return(d)
}
