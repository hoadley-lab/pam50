#' Read input data matrix
#'
#' `read_input` returns a 50 x n_samples matrix for comparison to  PAM50 centroids.
#'
#' The input file should be a plaintext tabular file, with genes in rows and samples in columns. The first column should correspond to HGNC gene symbols and will be treated as [data.frame] rownames. Any genes not present in the PAM50 set will be discarded. See [pam50::pam50_annot], which includes Ensembl stable gene IDs and HGNC IDs for each PAM50 HGNC gene symbol. This function will panic if not all PAM50 genes are present.
#'
#' @param path [character]; filesystem path to input file
#' @param delim [character]; column delimeter used in input file
#' @returns 50 genes x n_samples numeric [matrix]
#' @export
#' @examplesIf interactive()
#' read_input(file.path("raw_data", "pam50_testdata.tsv"))
read_input <- function(path, delim = "\t") {
  logger::log_info("Reading input from: {path}")
  input <-
    utils::read.delim(path,
      row.names = 1, header = TRUE,
      sep = delim, check.names = FALSE
    ) |>
    as.matrix()

  if (any(is.na(input))) {
    warn_msg <- paste0(
      "There are missing values in the input matrix. ",
      "Consider setting `impute == TRUE`."
    )
    logger::log_warn(warn_msg)
  }

  logger::log_debug("Checking if input contains all PAM50 genes")
  input <- pam50::filter_sort(input)
  if (nrow(input) < 50) {
    logger::log_error(paste0(
      "Not all PAM50 genes were found in input file. ",
      "Check if input gene IDs match `pam50_centroids`.",
      "Terminating."
    ))
    stop()
  }

  logger::log_debug("Sorting input rows by `pam50::pam50_centroids`")
  row_sort <- match(rownames(pam50::pam50_centroids), rownames(input))
  input <- input[row_sort, , drop = FALSE]
  return(input)
}

#' Read logical tumor size vector from a tabular samplesheet
#'
#' Very basic helper func to get named vector of tumor sizes from a samplesheet file.
#' @param path [character]; filesystem path to input file
#' @param delim [character]; column delimeter used in input file
#' @param samplenames [character]; name of column containing samplenames/id. Needs to be same as those in the input expression matrix columns.
#' @param tumor_size_col [character]; name of column containing tumor size indictor \[0, 1\] or \[FALSE, TRUE\].
#' @returns N sample named [logical] vector of tumor size indicators
#' @export
read_tumor_sizes <-
  function(path, delim = "\t", samplenames = "sample",
           tumor_size_col = "tumor_size") {
    ss <- utils::read.delim(path, row.names = samplenames, sep = delim)
    tumor_sizes <- as.logical(ss[, tumor_size_col])
    names(tumor_sizes) <- rownames(ss)

    tumor_sizes
  }

#' Filter and sort input expression matrix to match PAM50 centroids
#'
#' @param input [matrix]; numeric matrix of gene expression with PAM50 gene symbols as row names.
#' @returns 50 x N_sample numeric matrix with row order matching [pam50::pam50_centroids].
#' @export
filter_sort <- function(input) {
  row_sort <-
    match(rownames(pam50::pam50_centroids), rownames(input)) |>
    stats::na.omit() |>
    as.vector()
  input[row_sort, ]
}
