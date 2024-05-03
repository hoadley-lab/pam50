library(pam50)
logger::log_threshold("DEBUG", namespace = "pam50")

out_df <-
  pam50(
    input = file.path("tests", "testthat", "data", "pam50_testdata.tsv"),
    output_dir = file.path("tmp", "test"),
    centers = "self",
    impute = FALSE,
    tumor_sizes = file.path("tests", "testthat", "data",
                            "pam50_testdata_samplesheet.tsv"),
    include_normal = TRUE,
    create_qc_figures = TRUE
  )
