test_that("integration test from file input", {
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

test_that("integration test from matrix input", {
  logger::log_threshold("ERROR", "pam50")

  # shuffle input as user-provided rows may not always be in order
  input <- pam50::pam50_testdata[sample(nrow(pam50::pam50_testdata)), ]
  out_df <-
    pam50::pam50(
      input = input,
      output_dir = NULL,
      centers = "self",
      impute = FALSE,
      tumor_sizes = file.path("data", "pam50_testdata_samplesheet.tsv"),
      include_normal = TRUE,
      create_qc_figures = FALSE
    )
  expect_equal(out_df, pam50::pam50_testdata_assignments)
})

test_that("integration test from matrix centers", {
  logger::log_threshold("ERROR", "pam50")

  input <- pam50::pam50_testdata
  centers <- matrixStats::rowMedians(input, na.rm = TRUE) |> as.matrix()
  out_df <-
    pam50::pam50(
      input = input,
      output_dir = NULL,
      centers = centers,
      impute = FALSE,
      tumor_sizes = file.path("data", "pam50_testdata_samplesheet.tsv"),
      include_normal = TRUE,
      create_qc_figures = FALSE
    )
  expect_equal(out_df, pam50::pam50_testdata_assignments)
})
