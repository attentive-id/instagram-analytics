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
  tar_target(tbl, mergeContent(metrics, content)),

  # Write cleaned dataset to the storage
  tar_target(dat, readr::write_csv(tbl, "data/processed/data.csv")),

  # Create a time-series from merged dataset
  tar_target(ts, mkTs(tbl)),

  # Generate pair plots
  tar_map(
    values = tibble::tibble("pattern" = c("Follows", "Reach", "Visits")),
    unlist = FALSE,
    tar_target(plt_pair, vizPair(ts, pattern = pattern)),
    tar_target(fig_pair, ggplot2::ggsave(plt_pair, file = sprintf("docs/figs/plt-pair-%s.pdf", pattern), height = 22, width = 22))
  ),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
