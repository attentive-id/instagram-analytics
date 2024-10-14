# Functions to feature engineer the dataset

padRollingStat <- function(arr, FUN, k, ...) {
  #' Pad the Rolling Statistics
  #'
  #' Pad the first $k$ entry as null when calculating the rolling statistics
  #' using `zoo` package.
  #'
  #' @param arr An array of numeric values
  #' @param FUN Function from the `zoo` package, for instance `zoo::rollmean`
  #' @param k The number of additional elements as paddings
  #' @inheritDotParams zoo::rollmean
  #' @return A padded rolling statistics

  n     <- length(arr)
  res   <- c(rep(NA, k-1), FUN(arr, k = k, ...))

  return(res)
}

mutateRollingStat <- function(pattern, ..., .names = "{.col}") {
  #' Mutate with Rolling Statistics
  #'
  #' This is a helper function to use within `dplyr::mutate`. Pass on arguments
  #' to `padRollingStat` and apply it across a set of variables determined by
  #' the `pattern` argument.
  #'
  #' @param pattern Pattern to use within `dplyr::contains`
  #' @param ... Parameters to pass on to `padRollingStat`
  #' @param .names Name glue argument to use within `dplyr::across`
  #' @return A wrapper of `dplyr::across`

  res <- dplyr::across(
    dplyr::contains(pattern),
    ~ padRollingStat(.x, ..., align = "right"),
    .names = .names
  )

  return(res)
}

doAcrossInt <- function(tbl, FUN, ...) {
  #' Do Across Integer
  #'
  #' Wrapper function to apply other functions across all integer variables in
  #' a tidy data frame.
  #'
  #' @param tbl A tidy data frame
  #' @param FUN The function to be applied
  #' @param ... Parameters being passed on to `FUN`

  res <- tbl |>
    dplyr::mutate(
      dplyr::across(is.numeric, ~ FUN(.x, ...))
    )

  return(res)
}

mkTs <- function(tbl) {
  #' Make Time-Series Data
  #'
  #' Create a time-series data from a given merged table
  #'
  #' @param tbl A tidy time series, conventionally assumed as the output of
  #' `mergeContent`
  #' @return A tsibble

  require("tsibble")

  ts <- tbl |>
    dplyr::select(
      Date,
      has_post,
      dplyr::contains("_Follow"),
      dplyr::contains("_Reach"),
      dplyr::contains("_Visits")
    ) |>
    tsibble::tsibble(index = Date) |>
    tsibble::fill_gaps() |>
    doAcrossInt(imputeTS::na_interpolation, option = "spline")

  return(ts)
}

diffSeries <- function(arr, order = 1) {
  #' Difference Time-Series
  #'
  #' Perform an n-order differencing to a time series then interpolate any NA
  #' due to the side effect of differencing.
  #'
  #' @param arr A numeric array
  #' @param order The order for differencing
  #' @return A numeric array

  res <- tsibble::difference(arr, differences = order) |>
    imputeTS::na_interpolation(option = "spline")

  return(res)
}

regularize <- function(arr) {
  #' Regularize an Array
  #'
  #' Transform an array into its Z-Score.
  #'
  #' @param arr A numeric array
  #' @return A regularized numeric array

  xbar <- mean(arr, na.rm = TRUE)
  sdev <- sd(arr, na.rm = TRUE)

  arr_resid <- {arr - xbar}

  if (sdev == 0) {
    return(arr_resid)
  }

  res <- arr_resid / sdev
  
  return(res)
}
