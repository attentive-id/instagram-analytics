# Functions to clean the dataset

mergeMetrics <- function(sub_tbls, ...) {
  #' Merge Meta Business Metrics
  #'
  #' Merge follows, reach, and visits into one data frame
  #'
  #' @param sub_tbls A list of data frame containing follows, reach, and visits
  #' @inheritDotParams merge
  #' @return A tidy data frame

  varname <- paste("daily", names(sub_tbls), sep = "_")
  tbl <- Reduce(\(x, y) merge(x, y, by = "Date", ...), sub_tbls) |>
    set_colnames(c("Date", varname)) |>
    dplyr::mutate(Date = as.Date(Date, format = "%m/%d/%Y %H:%M")) |>
    tibble::tibble()

  return(tbl)
}


cleanContent <- function(tbl) {
  #' Clean Data
  #'
  #' Clean the `content.csv` dataset by removing unnecessary fields and renaming
  #' variables.
  #'
  #' @param tbl A data frame containing `content.csv` dataset
  #' @return A tidy data frame

  content <- tbl |>
    dplyr::select(`Publish time`:`Post type`, Impressions:Plays) |>
    dplyr::rename(
      "Date" = "Publish time", "URL" = "Permalink", "type" = "Post type"
    ) |>
    dplyr::mutate(Date = as.Date(Date, format = "%m/%d/%Y %H:%M"))

  return(content)
}

mergeContent <- function(metrics, content, ...) {
  #' Merge Content to Metrics
  #'
  #' Merge the content dataset into previously merged metrics.
  #'
  #' @param metrics A tidy data frame containing merged Meta Business Metrics
  #' @param content A tidy data frame containing the cleaned content dataset
  #' @inheritDotParams dplyr::left_join
  #' @return A tidy data frame

  tbl <- dplyr::left_join(metrics, content, by = "Date", ...) |>
    dplyr::mutate(has_post = !is.na(URL), .after = 4)

  return(tbl)
}

mergeContent(tar_read(metrics), tar_read(content)) |> str()
