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

saveFig <- function(obj, FUN = NULL, file, ...) {
  #' Save Figure
  #'
  #' Write figure from a generic R objectg as a pdf file.
  #'
  #' @param obj A generic R object to plot
  #' @param FUN The function for plotting, will call `base::plot` when set to
  #' null
  #' @param file The file name for saving the figure
  #' @param ... Parameters being passed on to `FUN`

  pdf(file, height = 8, width = 10)
  
  if (is.null(FUN)) {
    base::plot(obj, ...)
  } else {
    FUN(obj, ...)
  }

  dev.off()

}
