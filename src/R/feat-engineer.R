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
  left  <- arr[1:k]
  res   <- c(FUN(left, k = 2, align = "left"), FUN(arr, k = k, ...))

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
    tsibble::tsibble(index = Date)

  return(ts)
}
