\name{mindicador_indicadores}
\alias{mindicador_indicadores}
\docType{data}
\title{
Series disponibles en mindicador.cl
}
\description{
Descripcion de las magnitudes economicas y sus siglas en la API
}
\usage{mindicador_indicadores}
\format{
  Un data frame con 12 observaciones en las siguientes 3 variables.
  \describe{
    \item{\code{nombre}}{nombre de la serie (e.g. Unidad de Fomento)}
    \item{\code{codigo}}{codigo de la serie en la API (e.g. uf)}
    \item{\code{unidad}}{unidad de la serie (e.g. pesos o porcentaje)}
    \item{\code{desde}}{anio desde el cual esta disponible la serie (e.g. 1977)}
  }
}
\source{
https://mindicador.cl/api
}\examples{
mindicador_indicadores
}
\keyword{datasets}
