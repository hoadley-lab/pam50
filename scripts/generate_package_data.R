########
#  IO ##
########
#-- PAM50 Centroids -----------------------------------------------------------
pam50_centroids <-
  read.delim(file.path("tests", "testthat", "data", "pam50_centroids.tsv"),
    row.names = 1, header = TRUE
  ) |>
  as.matrix()
usethis::use_data(pam50_centroids)

#-- PAM50 Testdata (for examples) ---------------------------------------------
pam50_testdata <-
  read.delim(file.path("tests", "testthat", "data", "pam50_testdata.tsv"),
    row.names = 1, header = TRUE
  ) |>
  as.matrix()

# double check that testdata genes are in same order as centroids
row_order <- match(rownames(pam50_testdata), rownames(pam50_centroids))
pam50_testdata <- pam50_testdata[row_order, ]
usethis::use_data(pam50_testdata)

#-- PAM50 Expected Predictions / Assignments ----------------------------------
pam50_testdata_assignments <-
  read.delim(
    file.path(
      "tests", "testthat", "data",
      "pam50_testdata_assignments.tsv"
    ),
    row.names = as.character(1:200), header = TRUE
  )
rownames(pam50_testdata_assignments) <- NULL
pam50_levs <- c("basal", "her2", "luminal_a", "luminal_b", "normal")

pam50_testdata_assignments$assignment <-
  factor(pam50_testdata_assignments$assignment, levels = pam50_levs)

pam50_testdata_assignments$ror_subtype <-
  as.numeric(pam50_testdata_assignments$ror_subtype)

pam50_testdata_assignments$ror_clinical <-
  as.numeric(pam50_testdata_assignments$ror_clinical)

pam50_testdata_assignments$ror_prolif <-
  as.numeric(pam50_testdata_assignments$ror_prolif)

pam50_testdata_assignments$ror_prolif_clinical <-
  as.numeric(pam50_testdata_assignments$ror_prolif_clinical)

usethis::use_data(pam50_testdata_assignments, overwrite = TRUE)

#-- Test data samplesheet------------------------------------------------------
pam50_testdata_samplesheet <-
  read.delim(
    file.path(
      "tests", "testthat", "data",
      "pam50_testdata_samplesheet.tsv"
    ),
    header = TRUE
  )
usethis::use_data(pam50_testdata_samplesheet)

###############################
# Prognostic Risk of Relapse ##
###############################
#-- ROR-S coefficients --------------------------------------------------------
subtype <-
  c(
    "basal" = 0.04210193,
    "her2" = 0.12466938,
    "luminal_a" = -0.35235561,
    "luminal_b" = 0.14213283
  )

#-- ROR-C coefficients --------------------------------------------------------
clinical <-
  c(
    "basal" = 0.0442770,
    "her2" = 0.1170297,
    "luminal_a" = -0.2608388,
    "luminal_b" = 0.1055908,
    "tumor_size" = 0.1813751
  )

#-- ROR-P coefficients --------------------------------------------------------
prolif <-
  c(
    "basal" = -0.0009299747,
    "her2" = 0.0692289192,
    "luminal_a" = -0.0951505484,
    "luminal_b" = 0.0493487685,
    "prolif_score" = 0.3385116381
  )

#-- ROR-PC coefficients --------------------------------------------------------
prolif_clinical <-
  c(
    "basal" = -0.009383416,
    "her2" = 0.073725503,
    "luminal_a" = -0.090436516,
    "luminal_b" = 0.053013865,
    "tumor_size" = 0.131605960,
    "prolif_score" = 0.327259375
  )

ror_coeffs <-
  list(
    "subtype" = subtype,
    "clinical" = clinical,
    "prolif" = prolif,
    "prolif_clinical" = prolif_clinical
  )

# jsonlite::write_json(ror_coeffs,
#   file.path("tests", "testthat", "data", "ror_coeffs.json"),
#   pretty = TRUE, auto_unbox = TRUE, digits = NA
# )
usethis::use_data(ror_coeffs, overwrite = TRUE)

#-- Thresholds for calling high-risk, per ROR model ---------------------------
thrsh_subtype <-
  c(
    "low" = -0.15,
    "high" = 0.1
  )

thrsh_clinical <-
  c(
    "low" = -0.1,
    "high" = 0.2
  )

thrsh_prolif <-
  c(
    "low" = -0.25,
    "high" = 0.1
  )
thrsh_prolif_clinical <-
  c(
    "low" = -0.2,
    "high" = 0.2
  )

ror_thresholds <-
  c(
    "subtype" = thrsh_subtype,
    "clinical" = thrsh_clinical,
    "prolif" = thrsh_prolif,
    "prolif_clinical" = thrsh_prolif_clinical
  )

# jsonlite::write_json(ror_thresholds,
#   file.path("tests", "testthat", "data", "ror_thresholds.json"),
#   pretty = TRUE, auto_unbox = TRUE, digits = NA
# )
usethis::use_data(ror_thresholds, overwrite = TRUE)

#------------------------------------------------------------------------------
pam50_annot <-
  read.delim(
    file.path(
      "tests", "testthat",
      "data", "pam50_annot.tsv"
    ),
    sep = "\t"
  )
usethis::use_data(pam50_annot)

#------------------------------------------------------------------------------
pam50_palette <-
  c(
    "basal" = "#eb212d",
    "her2" = "#f7c1d9",
    "luminal_a" = "#2f3492",
    "luminal_b" = "#26afdd",
    "normal" = "#3cb54c"
  )
usethis::use_data(pam50_palette, overwrite = TRUE)
