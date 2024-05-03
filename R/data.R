#' PAM50 centroids read from a stone tablet
#'
#' A dataset containing PAM50 centroids from the original Parker et al. (2009) publication. Availble at: \url{https://web.archive.org/web/20130304090315/https://genome.unc.edu/pubsup/breastGEO/pam50_centroids.txt}
#'
#' @format A numeric [matrix] with 50 rows (genes) and 5 columns (molecular subtypes)
"pam50_centroids"


#' PAM50 test data
#'
#' A dataset containing PAM50 gene expression profiles from a microarray panel for 200 subjects. Possibly synthetic data. Available from \url{https://web.archive.org/web/20130302114722/https://genome.unc.edu/pubsup/breastGEO/PAM50.zip}
#'
#' @format A numeric [matrix] with 50 rows (genes) and 200 columns (samples).
"pam50_testdata"

#' PAM50 annotations
#'
#' A dataset of PAM50 gene names with IDs and proliferation status
#'
#' @format A [data.frame] with 50 rows (genes) and 4 columns (annotations).
"pam50_annot"

#' PAM50 palette
#'
#' The 'canonical' PAM50 subtype colors
#'
#' @format A named [list] of PAM50 subtype hex codes.
"pam50_palette"

#' Test data samplesheet
#'
#' Example samplesheet for input samples. Can be used to indicate tumor size value for clinical risk model (ROR-C).
#'
#' @format A [data.frame] with 200 rows (samples) and 2 columns (sample name & binary tumor size indicator)
"pam50_testdata_samplesheet"

#' PAM50 test data assignments
#'
#' A dataset containing PAM50 subtype correlations and assignments for the 200 samples from `pam50_testdata` as originally called by Parker et al. Availble from \url{https://web.archive.org/web/20130302114722/https://genome.unc.edu/pubsup/breastGEO/PAM50.zip}.
#'
#' @format A [data.frame] with 200 rows (samples) and 6 columns (cors + assign).
"pam50_testdata_assignments"

#' Risk of Relapse (ROR) model coefficients
#'
#' A nested [list] of linear model coefficients for each possible ROR model: subtype only \[ROR-S\], subtype + tumor size (clinical) \[ROR-C\], subtype + proliferative score \[ROR-P\],
#' and subtype + tumor size + prolif score \[ROR-PC\]. Taken from legacy
#' code, see [pam50::pam50_testdata].
#'
#' @fotmat a named [list] of named [numeric] lists
"ror_coeffs"

#' Risk of Relapse (ROR) low vs high thresholds
#'
#' A nested [list] of risk score thresholds to call low vs medium vs high risk. See [pam50::ror_coeffs]
#'
#' @fotmat a named [list] of named [numeric] lists
#'
"ror_thresholds"
