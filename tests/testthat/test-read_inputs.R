test_that("reading testdata from file matches package data", {
  input <- read_input(file.path("data", "pam50_testdata.tsv"))
  centroids <- read_input(file.path("data", "pam50_centroids.tsv"))
  expect_identical(input, pam50::pam50_testdata)
  expect_identical(centroids, pam50::pam50_centroids)
})
