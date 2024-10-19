

# Data preparation

All the data used in this analysis are sourced from Meta Business Suite.
You will need to export four data to work with:

1.  `content.csv`, by hovering over the sidebar $\to$ Click Insight
    $\to$ Content $\to$ Select needed variables $\to$ Narrow down the
    time frame $\to$ Export data. This data must contain the following
    fields:
    - Post ID
    - Account ID
    - Account username
    - Account name
    - Description
    - Duration (secs)
    - Publish time
    - Permalink
    - Post type
    - Data comment
    - Date
    - Impression
    - Reach
    - Likes
    - Shares
    - Comments
    - Saves
    - Follows
    - Plays
2.  `Follows.csv`, by hovering over the sidebar $\to$ Click Insight
    $\to$ Results $\to$ Export the “Follows” section.
3.  `Reach.csv`, by hovering over the sidebar $\to$ Click Insight $\to$
    Results $\to$ Export the “Reach” section.
4.  `Visits.csv`, by hovering over the sidebar $\to$ Click Insight $\to$
    Results $\to$ Export the “Visits” section.

# Getting started

Most of the works in this repository, especially the `R` scripts, should
be directly reproducible. You’ll need
[`git`](https://git-scm.com/downloads),
[`R`](https://www.r-project.org/),
[`quarto`](https://quarto.org/docs/download/), and more conveniently
[RStudio IDE](https://posit.co/downloads/) installed and running well in
your system. You simply need to fork/clone this repository using RStudio
by following [this tutorial, start right away from
`Step 2`](https://book.cds101.com/using-rstudio-server-to-clone-a-github-repo-as-a-new-project.html#step---2).
Using terminal in linux/MacOS, you can issue the following command:

``` bash
quarto tools install tinytex
```

This command will install `tinytex` in your path, which is required to
compile quarto documents as latex/pdf. Afterwards, in your RStudio
command line, you can copy paste the following code to setup your
working directory:

``` r
install.packages("renv") # Only need to run this step if `renv` is not installed
```

This step will install `renv` package, which will help you set up the
`R` environment. Please note that `renv` helps tracking, versioning, and
updating packages I used throughout the analysis.

``` r
renv::restore()
```

This step will read `renv.lock` file and install required packages to
your local machine. When all packages loaded properly (make sure there’s
no error at all), you *have to* restart your R session. At this point,
you need to export the data as `data.csv` and place it within the
`data/raw` directory. The directory structure *must* look like this:

``` bash
data
├── ...
├── raw
│   ├── content.csv
│   ├── Follows.csv
│   ├── Reach.csv
│   └── Visits.csv
└── ...
```

Then, you should be able to proceed with:

``` r
targets::tar_make()
```

This step will read `_targets.R` file, where I systematically draft all
of the analysis steps. Once it’s done running, you will find the
rendered document (either in `html` or `pdf`) inside the `draft`
directory.

# What’s this all about?

This is the functional pipeline for conducting statistical analysis. The
complete flow can be viewed in the following `mermaid` diagram:

``` mermaid
graph LR
  style Legend fill:#FFFFFF00,stroke:#000000;
  style Graph fill:#FFFFFF00,stroke:#000000;
  subgraph Legend
    direction LR
    xf1522833a4d242c5([""Up to date""]):::uptodate --- xb6630624a7b3aa0f([""Dispatched""]):::dispatched
    xb6630624a7b3aa0f([""Dispatched""]):::dispatched --- xd03d7c7dd2ddda2b([""Stem""]):::none
    xd03d7c7dd2ddda2b([""Stem""]):::none --- xeb2d7cac8a1ce544>""Function""]:::none
    xeb2d7cac8a1ce544>""Function""]:::none --- xbecb13963f49e50b{{""Object""}}:::none
  end
  subgraph Graph
    direction LR
    x95244cd38d58fbcc>"doAcrossInt"]:::uptodate --> xa3379aa2e7a70b78>"mkTs"]:::uptodate
    x724eeab36ed1f083>"padRollingStat"]:::uptodate --> x31ab83458983f7b0>"mutateRollingStat"]:::uptodate
    x31ab83458983f7b0>"mutateRollingStat"]:::uptodate --> xe93ec73e599e9f3a>"mergeContent"]:::uptodate
    x97f0d81d4ffb5185(["mod_var"]):::uptodate --> x6f7b59d9d21e4832(["mod_irf_var"]):::uptodate
    x4d3ec24f81457d7f{{"seed"}}:::uptodate --> x6f7b59d9d21e4832(["mod_irf_var"]):::uptodate
    xd0b291773e1b802e>"identifySVAR"]:::uptodate --> xaf871c6c095ab6bc(["mod_svar"]):::uptodate
    x97f0d81d4ffb5185(["mod_var"]):::uptodate --> xaf871c6c095ab6bc(["mod_svar"]):::uptodate
    x40c6ebc03e2a4d18(["plt_pair_Visits<br>Visits"]):::uptodate --> xc00958553576e207(["fig_pair_Visits<br>Visits"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> x213e59fc01691420(["plt_pair_Reach<br>Reach"]):::uptodate
    x7e257c6f0f1d998e>"vizPair"]:::uptodate --> x213e59fc01691420(["plt_pair_Reach<br>Reach"]):::uptodate
    x008512a539ff5dfc(["plt_fevd_var<br>mod_var var"]):::uptodate --> x8fbd8454e9d2cdd2(["fig_fevd_var<br>mod_var var"]):::uptodate
    x7463155e3b339356(["plt_pair_Follows<br>Follows"]):::uptodate --> x508f5e45b18d96e5(["fig_pair_Follows<br>Follows"]):::uptodate
    xf6472bd5309d8529>"mergeMetrics"]:::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xd5845efd825040d8(["tbls"]):::uptodate --> x544e14c8fac2c5b0(["metrics"]):::uptodate
    xa3379aa2e7a70b78>"mkTs"]:::uptodate --> x857eb9596b9670e5(["ts_metrics"]):::uptodate
    x0c73c8f7e50fb4f6(["tbl_metrics"]):::uptodate --> x857eb9596b9670e5(["ts_metrics"]):::uptodate
    xc3cf8e64d6bc2338(["plt_fevd_svar<br>mod_svar svar"]):::uptodate --> xc298d12281b5aa84(["fig_fevd_svar<br>mod_svar svar"]):::uptodate
    x1f6d76ea8940cecf{{"raws"}}:::uptodate --> xd5845efd825040d8(["tbls"]):::uptodate
    x18b26034ab3a95e2>"readData"]:::uptodate --> xd5845efd825040d8(["tbls"]):::uptodate
    x95244cd38d58fbcc>"doAcrossInt"]:::uptodate --> x8c4db3d44bfd96ea(["ts_reg"]):::uptodate
    x3c3eb5c9cb51afb7>"regularize"]:::uptodate --> x8c4db3d44bfd96ea(["ts_reg"]):::uptodate
    xb6ac687628bbec9f(["ts_diff"]):::uptodate --> x8c4db3d44bfd96ea(["ts_reg"]):::uptodate
    xd63b4bcad7171bbe(["mod_irf_svar"]):::uptodate --> xb5b41e8e0ef61222(["plt_irf_svar"]):::uptodate
    x7a33e84e73f9652d>"getFEVD"]:::uptodate --> x1068365036019d2b(["mod_fevd_svar<br>mod_svar svar"]):::uptodate
    xaf871c6c095ab6bc(["mod_svar"]):::uptodate --> x1068365036019d2b(["mod_fevd_svar<br>mod_svar svar"]):::uptodate
    x1068365036019d2b(["mod_fevd_svar<br>mod_svar svar"]):::uptodate --> xc3cf8e64d6bc2338(["plt_fevd_svar<br>mod_svar svar"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> x7463155e3b339356(["plt_pair_Follows<br>Follows"]):::uptodate
    x7e257c6f0f1d998e>"vizPair"]:::uptodate --> x7463155e3b339356(["plt_pair_Follows<br>Follows"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> x29df927b24746e7f(["dat_series"]):::uptodate
    xb5b41e8e0ef61222(["plt_irf_svar"]):::uptodate --> x033ab300685987e4(["fig_irf_svar"]):::uptodate
    x4bd3181fc8b3776f>"cleanContent"]:::uptodate --> xdb9aad8c6606dba7(["content"]):::uptodate
    xd5845efd825040d8(["tbls"]):::uptodate --> xdb9aad8c6606dba7(["content"]):::uptodate
    x25e6368b6c321d5d>"fitVAR"]:::uptodate --> x97f0d81d4ffb5185(["mod_var"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> x97f0d81d4ffb5185(["mod_var"]):::uptodate
    x7a33e84e73f9652d>"getFEVD"]:::uptodate --> x70fe34ce349392c4(["mod_fevd_var<br>mod_var var"]):::uptodate
    x97f0d81d4ffb5185(["mod_var"]):::uptodate --> x70fe34ce349392c4(["mod_fevd_var<br>mod_var var"]):::uptodate
    xdb9aad8c6606dba7(["content"]):::uptodate --> x0c73c8f7e50fb4f6(["tbl_metrics"]):::uptodate
    xe93ec73e599e9f3a>"mergeContent"]:::uptodate --> x0c73c8f7e50fb4f6(["tbl_metrics"]):::uptodate
    x544e14c8fac2c5b0(["metrics"]):::uptodate --> x0c73c8f7e50fb4f6(["tbl_metrics"]):::uptodate
    x6f7b59d9d21e4832(["mod_irf_var"]):::uptodate --> xad62adf3b89773bd(["fig_irf_var"]):::uptodate
    xe519ca1abae00296>"saveFig"]:::uptodate --> xad62adf3b89773bd(["fig_irf_var"]):::uptodate
    x63b2eeaa35defdcd>"evalUnitRoot"]:::uptodate --> xd2ec401c4ce33bb6(["res_adf"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> xd2ec401c4ce33bb6(["res_adf"]):::uptodate
    x0c73c8f7e50fb4f6(["tbl_metrics"]):::uptodate --> x556b00330c5941b4(["dat_metrics"]):::uptodate
    xaf871c6c095ab6bc(["mod_svar"]):::uptodate --> xd63b4bcad7171bbe(["mod_irf_svar"]):::uptodate
    xb41da213b729c2ba>"diffSeries"]:::uptodate --> xb6ac687628bbec9f(["ts_diff"]):::uptodate
    x95244cd38d58fbcc>"doAcrossInt"]:::uptodate --> xb6ac687628bbec9f(["ts_diff"]):::uptodate
    x857eb9596b9670e5(["ts_metrics"]):::uptodate --> xb6ac687628bbec9f(["ts_diff"]):::uptodate
    x8c4db3d44bfd96ea(["ts_reg"]):::uptodate --> x40c6ebc03e2a4d18(["plt_pair_Visits<br>Visits"]):::uptodate
    x7e257c6f0f1d998e>"vizPair"]:::uptodate --> x40c6ebc03e2a4d18(["plt_pair_Visits<br>Visits"]):::uptodate
    x70fe34ce349392c4(["mod_fevd_var<br>mod_var var"]):::uptodate --> x008512a539ff5dfc(["plt_fevd_var<br>mod_var var"]):::uptodate
    x213e59fc01691420(["plt_pair_Reach<br>Reach"]):::uptodate --> xeec8dfdc96875de7(["fig_pair_Reach<br>Reach"]):::uptodate
    xc11069275cfeb620(["readme"]):::dispatched --> xc11069275cfeb620(["readme"]):::dispatched
    x07bf962581a33ad1{{"funs"}}:::uptodate --> x07bf962581a33ad1{{"funs"}}:::uptodate
    x2f12837377761a1b{{"pkgs"}}:::uptodate --> x2f12837377761a1b{{"pkgs"}}:::uptodate
    x026e3308cd8be8b9{{"pkgs_load"}}:::uptodate --> x026e3308cd8be8b9{{"pkgs_load"}}:::uptodate
    x3eac3c5af5491b67>"lsData"]:::uptodate --> x3eac3c5af5491b67>"lsData"]:::uptodate
  end
  classDef uptodate stroke:#000000,color:#ffffff,fill:#354823;
  classDef dispatched stroke:#000000,color:#000000,fill:#DC863B;
  classDef none stroke:#000000,color:#000000,fill:#94a4ac;
  linkStyle 0 stroke-width:0px;
  linkStyle 1 stroke-width:0px;
  linkStyle 2 stroke-width:0px;
  linkStyle 3 stroke-width:0px;
  linkStyle 56 stroke-width:0px;
  linkStyle 57 stroke-width:0px;
  linkStyle 58 stroke-width:0px;
  linkStyle 59 stroke-width:0px;
  linkStyle 60 stroke-width:0px;
```

# `R` session information

    R version 4.4.1 (2024-06-14)
    Platform: x86_64-conda-linux-gnu
    Running under: Void Linux

    Matrix products: default
    BLAS/LAPACK: /home/lam/data/personal/programs/miniconda/v3/envs/R/lib/libopenblasp-r0.3.27.so;  LAPACK version 3.12.0

    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

    time zone: Europe/Amsterdam
    tzcode source: system (glibc)

    attached base packages:
    [1] stats     graphics  grDevices datasets  utils     methods   base     

    other attached packages:
    [1] magrittr_2.0.3 targets_1.8.0 

    loaded via a namespace (and not attached):
     [1] vctrs_0.6.5       cli_3.6.3         knitr_1.48        rlang_1.1.4      
     [5] xfun_0.48         processx_3.8.4    renv_1.0.0        jsonlite_1.8.9   
     [9] data.table_1.16.2 glue_1.8.0        backports_1.5.0   htmltools_0.5.8.1
    [13] ps_1.8.0          fansi_1.0.6       rmarkdown_2.28    evaluate_1.0.1   
    [17] tibble_3.2.1      base64url_1.4     fastmap_1.2.0     yaml_2.3.10      
    [21] lifecycle_1.0.4   compiler_4.4.1    codetools_0.2-20  igraph_2.0.3     
    [25] pkgconfig_2.0.3   digest_0.6.37     R6_2.5.1          tidyselect_1.2.1 
    [29] utf8_1.2.4        pillar_1.9.0      callr_3.7.6       withr_3.0.1      
    [33] tools_4.4.1       secretbase_1.0.3 
