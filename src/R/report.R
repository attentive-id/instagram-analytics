# Functions to aid reporting

describe <- function(tbl) {
  #' Describe The Data
  #'
  #' Report the descriptive statistics of a given data frame.
  #'
  #' @param tbl A tidy data frame
  #' @return A tidy report

  res <- tbl |>
    dplyr::select(where(is.numeric)) |>
    gtsummary::tbl_summary(
      type = gtsummary::all_continuous() ~ "continuous2",
      statistic = list(
        gtsummary::all_continuous() ~ c("{mean} ({sd})", "{min}, {max}", "{median} [{IQR}]")
      ),
      missing = "ifany"
    ) |>
    gtsummary::as_hux_table()

  return(res)
}

