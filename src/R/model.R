# Functions to fit a model

evalUnitRoot <- function(ts) {
  #' Evaluate Unit Root
  #'
  #' Check for the presence of a unit root using Augmented Dickey-Fuller Test.
  #'
  #' @param ts A tidy time-series
  #' @return A tidy statistics results

  res <- ts |>
    dplyr::select(is.numeric) |>
    lapply(function(arr) {
      tseries::adf.test(arr) |> broom::tidy() |> data.frame()
    }) %>%
    {do.call(rbind, .)} %>%
    tibble::add_column("metrics" = rownames(.), .before = 1) |>
    tibble::tibble()

  return(res)
}

fitVAR <- function(ts, ...) {
  #' Fit Vector Auto-Regression
  #'
  #' Fit the time-series data into a vector auto-regression model.
  #'
  #' @param ts A tidy time-series
  #' @inheritDotParams dplyr::select
  #' @return A VAR model using `vars`

  sub_ts  <- ts |> dplyr::select(...) |> as.ts(frequency = 365)
  var_mod <- sub_ts |>
    vars::VAR(lag.max = 7, ic = "AIC")

  return(var_mod)
}

identifySVAR <- function(var_mod, stage3 = FALSE, ...) {
  #' Identify Structural VAR
  #'
  #' Identify the strucutral impact matrix of a VAR model.
  #'
  #' @param var_mod A VAR model using `vars`
  #' @param stage3 If `TRUE`, the VAR parameters are estimated via a
  #' more computationally-demanding approach
  #' @inheritDotParams svars::wild.boot
  #' @return A `svars` object

  svar_mod <- svars::id.ngml(var_mod, ...)

  return(svar_mod)
}

getFEVD <- function(obj, ...) {
  #' Calculate the FEVD
  #'
  #' Calculate the forecast error variance decomposition of fitted `vars` or
  #' `svars` object.
  #'
  #' @param obj A `vars` or `svars` object
  #' @inheritDotParams vars::fevd
  #' @return A FEVD object
  require("svars")

  res <- vars::fevd(obj, ...)

  return(res)
}

