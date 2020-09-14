
<!-- README.md is generated from README.Rmd. Please edit that file -->

# meandr <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

<!-- badges: end -->

`meandr` allows you to easily generate random data from continuously
differentiable functions. This is particular useful for simulating
time-series data such as weather conditions - or any physical phenomena
that maintain a clear local trajectory.

## Installation

``` r
devtools::install_github("sccmckenzie/meandr")
```

## Example

``` r
library(dplyr)
library(meandr)

meandr(seed = 17) %>% 
  mplot()
```

<img src="man/figures/README-example-1.png" width="100%" />
