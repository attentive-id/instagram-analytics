# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "crew")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)

# Source user-defined functions
funs <- list.files("src/R", pattern = "*.R", full.name = TRUE) %>%
  lapply(source)

# Set option for targets
tar_option_set(
  packages   = pkgs,
  error      = "continue",
  memory     = "transient",
  controller = crew_controller_local(worker = 4),
  storage    = "worker",
  retrieval  = "worker",
  garbage_collection = TRUE
)

seed <- 1810

# Set paths for the raw data
raws <- lsData(pattern = "*csv")

# Set the analysis pipeline
list(

  # Read the data frame
  tar_target(tbls, lapply(raws, readData)),
  tar_target(metrics, mergeMetrics(tbls[-1])),

  # Clean and combine the dataset
  tar_target(content, cleanContent(tbls[[1]])),
  tar_target(tbl_metrics, mergeContent(metrics, content)),

  # Create a time-series from merged dataset
  tar_target(ts_metrics, mkTs(tbl_metrics)),
  tar_target(ts_diff, doAcrossInt(ts_metrics, diffSeries, order = 1)),
  tar_target(ts_reg, doAcrossInt(ts_diff, regularize)),

  # Write cleaned dataset to the storage
  tar_target(dat_metrics, readr::write_csv(tbl_metrics, "data/processed/data.csv")),
  tar_target(dat_series,  readr::write_csv(ts_reg, "data/processed/data-ts.csv")),

  # Generate pair plots
  tar_map(
    values = tibble::tibble("pattern" = c("Follows", "Reach", "Visits")),
    unlist = FALSE,
    tar_target(plt_pair, vizPair(ts_reg, pattern = pattern)),
    tar_target(fig_pair, ggplot2::ggsave(plt_pair, file = sprintf("docs/figs/plt-pair-%s.pdf", pattern), height = 22, width = 22))
  ),

  # Perform an ADF test to evaluate the unit root
  tar_target(res_adf, evalUnitRoot(ts_reg)),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
