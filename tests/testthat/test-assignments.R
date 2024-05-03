test_that("pam50 assignments equal the original", {
  logger::log_threshold("ERROR", "pam50")
  out_df <-
    pam50::pam50(
      input = file.path("data", "pam50_testdata.tsv"),
      output_dir = NULL,
      centers = "self",
      impute = FALSE,
      tumor_sizes = file.path("data", "pam50_testdata_samplesheet.tsv"),
      include_normal = TRUE,
      create_qc_figures = FALSE
    )
  expect_equal(out_df, pam50::pam50_testdata_assignments)
})
