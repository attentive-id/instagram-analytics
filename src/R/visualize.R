# Functions to visualize the dataset

vizPair <- function(ts, pattern = "Follows") {
  #' Visualize a Pair Plot
  #'
  #' Visualize a pair plot of variables within the time-series
  #'
  #' @param A tsibble containing primary metrics and its derivative, usually
  #' the output of `mkTs`
  #' @return A GGPlot2 object
  require("ggplot2")

  tbl <- tibble::tibble(ts) |>
    dplyr::select(
      dplyr::starts_with("daily"),
      dplyr::contains(pattern)
    )

  plt <- GGally::ggpairs(tbl)

  return(plt)
}

