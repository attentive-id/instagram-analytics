# Functions to parse the dataset

lsData <- function(path = "data/raw", ...) {
  #' List Data
  #'
  #' List all data file within `path` directory
  #'
  #' @param path A path of raw data directory, set to "data/raw" by default
  #' @return A list of complete relative path of each dataset

  filepath <- list.files(path, full.name = TRUE, recursive = TRUE, ...) %>%
    set_names(gsub(x = ., ".*_|\\w+/|\\.\\w*", ""))

  return(filepath)
}

readData <- function(fpath, ...) {
  #' Read Data Frame
  #'
  #' Read external tabular data as a tidy data frame
  #'
  #' @param fpath Path name of the file to parse
  #' @inheritDotParams readr::read_csv
  #' @return A tidy data frame

  tbl <- tryCatch(
    readr::read_csv(fpath, ...),
    error = function(e) { # Follows, visits, and reach use different encoding
      readr::read_csv(
        fpath,
        locale = readr::locale(encoding = "UCS-2LE"),
        skip = 2,
        ...
      )
    }
  )

  return(tbl)
}

mergeMetrics <- function(sub_tbls, ...) {
  #' Merge Meta Business Metrics
  #'
  #' Merge follows, reach, and visits into one data frame
  #'
  #' @param sub_tbls A list of data frame containing follows, reach, and visits
  #' @inheritDotParams merge
  #' @return A tidy data frame

  varname <- names(sub_tbls)
  tbl <- Reduce(\(x, y) merge(x, y, by = "Date", ...), sub_tbls) |>
    set_colnames(c("Date", varname)) |>
    tibble::tibble()

  return(tbl)
}

