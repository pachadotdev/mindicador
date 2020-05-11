# mindicador

<!-- badges: start -->
[![R build status](https://github.com/pachamaltese/mindicador/workflows/R-CMD-check/badge.svg)](https://github.com/pachamaltese/mindicador/actions)
[![Codecov test coverage](https://codecov.io/gh/pachamaltese/mindicador/branch/master/graph/badge.svg)](https://codecov.io/gh/pachamaltese/mindicador?branch=master)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

El objetivo de `mindicador::` es facilitar el uso de los datos de mindicador.cl el cual es un proyecto de independiente de este software y que fue desarrollado por [Christopher Riquelme](https://twitter.com/lee_om).

## Instalación

Desde GitHub:

```r
devtools::install_github("pachamaltese/mindicador")
```

## Uso

Todas las series se importan de igual modo:
```r
# series disponibles
mindicador_indicadores

# valores de la UF anio 2020
mindicador_importar_datos("uf", 2020)

# valores de la UF anios 2010 a 2020
mindicador_importar_datos("uf", 2010:2020)
```

Puedes consultar pacha.dev/mindicador para ver un ejemplo más extenso.

## Código de Conducta
  
Este proyecto contempla un [Código de Conducta](https://github.com/pachamaltese/mindicador/blob/master/CODE_OF_CONDUCT.md).
