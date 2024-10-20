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
  
  # Describe the dataset
  tar_target(desc_metrics, describe(metrics)),

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

  # Fit a VAR model and identify the structural impact matrix
  tar_target(mod_var, fitVAR(ts_reg, cum_daily_Follows, daily_Reach, daily_Visits)),
  tar_target(mod_svar, identifySVAR(mod_var, stage3 = TRUE)),

  # Calculate and plot the imppulse response function
  tar_target(mod_irf_var, vars::irf(mod_var, runs = 1e3, seed = seed)),
  tar_target(fig_irf_var, saveFig(mod_irf_var, vars:::plot.varirf, file = "docs/figs/plt-var-irf.pdf", plot.type = "multiple")),

  tar_target(mod_irf_svar, svars::wild.boot(mod_svar, n.ahead = 14, nboot = 1e3, nc = 4)),
  tar_target(plt_irf_svar, svars:::plot.sboot(mod_irf_svar, scales = "free_y")),
  tar_target(fig_irf_svar, ggplot2::ggsave(plt_irf_svar, file = "docs/figs/plt-svar-irf.pdf", height = 8, width = 12)),

  # Calculate and plot the forecast error variance decomposition
  tar_map(
    unlist = FALSE,
    values = tibble::tibble(
      mod = rlang::syms(c("mod_var", "mod_svar")),
      fname = c("var", "svar")
    ),
    names = "fname",
    tar_target(mod_fevd, getFEVD(mod, n.ahead = 7)),
    tar_target(plt_fevd, svars:::plot.svarfevd(mod_fevd)),
    tar_target(fig_fevd, ggplot2::ggsave(plt_fevd, file = sprintf("docs/figs/plt-%s-fevd.pdf", fname), height = 8 , width = 12))
  ),

  # Generate documentation
  tar_quarto(res_metrics, "docs/results/data-summary.qmd", priority = 0),
  tar_quarto(res_mod_var, "docs/results/model-summary.qmd", priority = 0),
  tar_quarto(readme, "README.qmd", priority = 0)

)
