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
