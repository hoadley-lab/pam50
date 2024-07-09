#' Preprocess input data matrix
#'
#' `preprocess_input` prepares the input dataset for comparison to centroids.
#'
#' @param input_matx `matrix`; output of [pam50::read_input()].
#' @param centers "self" | [matrix] | [NULL]; If "self" (default), median center the input directly. If NULL, don't center. Otherwise use custom medians (50 gene x 1 numeric matrix with rownames) for input centering.
#' @param impute `logical`; impute missing values. [impute::impute.knn()] required.
#' @returns 50 genes x n_samples numeric matrix
#' @export
#' @examplesIf interactive()
#' input <-
#'   read_input(file.path("tests", "testthat", "data", "pam50_testdata.tsv"))
#' out_matx <- preprocess_input(input)
preprocess_input <- function(input_matx, centers = "self", impute = FALSE) {
  input_matx <- pam50::filter_sort(input_matx)
  if (impute) {
    logger::log_info("Imputing missing values via KNN averages")
    input_matx <- impute::impute.knn(input_matx)$data
  }


  if (identical(centers, "self")) {
    logger::log_info("Median centering by self")
    centers <- matrixStats::rowMedians(input_matx, na.rm = TRUE)
  } else if (is.null(centers)) {
    logger::log_info("Not centering input data")
    centers <- rep(0.0, 50)
  } else if (is.matrix(centers)) {
    logger::log_info("Centering using provided values")
    row_sort <- match(rownames(pam50::pam50_centroids), rownames(centers))
    centers <- centers[row_sort, 1]
  } else {
    logger::log_error("Unexpected input to 'centers' param. Terminating.")
    stop()
  }
  centered <- input_matx - centers

  return(scale(centered))
}

#' Assign research-based PAM50 molecular subtypes
#'
#' `assign_subtypes` finds the nearest PAM50 subtype centriod per sample
#'
#' @param input_matx [matrix]; output of [pam50::read_input()].
#' @param include_normal [logical]; whether to include the normal centroid when calculating max correlation. Default: TRUE
#' @returns n_samples x 7 column [data.frame] with per-substype Spearman Rank correlation and assignments
#' @export
#' @examplesIf interactive()
#' input <- pam50::preprocess_input(pam50::pam50_testdata)
#' predicted_subtypes <- assign_subtypes(input)
assign_subtypes <- function(input_matx, include_normal = TRUE) {
  idx2type <- colnames(pam50::pam50_centroids)
  logger::log_info(
    "Calculating pairwise Spearman's Rank correlation to centroids."
  )
  scaled_centroids <- scale(pam50::pam50_centroids)
  pw_cor <-
    stats::cor(scaled_centroids,
      input_matx,
      method = "spearman",
      use = "pairwise.complete.obs"
    ) |>
    t()

  logger::log_info("Assigning subtypes by maximum correlation")
  assignments <-
    pw_cor[, 1:(4 + include_normal)] |>
    apply(1, which.max) |>
    sapply(function(idx) idx2type[idx])

  levels <- c("basal", "her2", "luminal_a", "luminal_b", "normal")
  logger::log_debug("Building output `data.frame`")
  out_df <- pw_cor |> as.data.frame()
  out_df$assignment <- factor(assignments, levels)

  return(out_df)
}

#' Run entire PAM50 analysis
#'
#' `pam50` is a helper function to paramaterize and run the full analysis, including: io, centering/scaling, subtype calling, ROR calculations, and (optional) QC plots.
#'
#' @param input [character] |  [matrix]; See [pam50::read_input()].
#' @param output_dir [character] | [NULL]; directory path for all output. Must already exist.
#' @param centers for PAM50 genes. One of:  "self", [NULL], [matrix], or [character] path; See [pam50::preprocess_input()]
#' @param impute `logical`; impute missing values in input. Default false. See [pam50::preprocess_input()].
#' @param tumor_sizes [logical] | [character]. Indicator vector of tumor size >2cm for ROR analsis. If a path, will try to read input as TSV with first column of sample names, and another column called tumor_size'. If [NA] (default), will ignore.
#' @param include_normal [logical]; See [pam50::assign_subtypes()]
#' @param create_qc_figures [logical]. See [pam50::plot_cor_box()], [pam50::plot_pam50_heatmap()], and [pam50::plot_pam50_pca()]. Will save to `output_dir`.
#' @returns A n_sample x 15 features [data.frame]. Optionally writes results to `output`. Logs to stdout.
#' @export
pam50 <- function(input, output_dir = NULL, centers = "self", impute = FALSE,
                  tumor_sizes = NA, include_normal = TRUE,
                  create_qc_figures = FALSE) {
  if (is.null(output_dir) && create_qc_figures == TRUE) {
    logger::log_error("Creating qc figures requires `output_dir` to be set.")
    stop()
  }
  if (is.character(input)) {
    input <- pam50::read_input(input)
  } else if (is.matrix(input)) {
    logger::log_info("Using pre-loaded gene expression matrix")
  } else {
    logger::log_error("Unexpected input. Terminating.")
    stop()
  }

  if (any(is.na(input))) {
    warn_msg <- paste0(
      "There are missing values in the input matrix. ",
      "Consider setting `impute == TRUE`."
    )
    logger::log_warn(warn_msg)
  }

  processed_input <- preprocess_input(input, centers, impute)

  if (is.logical(tumor_sizes)) {
    logger::log_info("Using pre-loaded tumor size vector")
  } else if (is.character(tumor_sizes)) {
    tumor_sizes <- pam50::read_tumor_sizes(tumor_sizes)
  } else if (is.na(tumor_sizes)) {
    tumor_sizes <- rep(NA, ncol(input))
    names(tumor_sizes) <- colnames(input)
  } else {
    logger::log_error("Unexpected tumor sizes. Terminating")
    stop()
  }

  assignments <- pam50::assign_subtypes(processed_input, include_normal)

  logger::log_info("Calculating proliferation scores")
  prolif_scores <- pam50::calc_proliferation_scores(processed_input)

  logger::log_info("Calculating ROR scores")
  ror_analysis <- sapply(row.names(assignments), function(sample_name) {
    calc_ror_scores(
      assignments[sample_name, ],
      prolif_scores[[sample_name]],
      tumor_sizes[sample_name]
    )
  }, USE.NAMES = FALSE) |>
    t() |>
    rbind()

  out_df <- cbind(assignments, prolif_scores, ror_analysis)
  unlist_cols <- which(grepl("ror_", colnames(out_df)))
  for (i in unlist_cols) {
    out_df[, i] <- unlist(out_df[, i])
  }
  out_df$samplename <- rownames(out_df)
  rownames(out_df) <- NULL
  out_df <- out_df[, c(ncol(out_df), 1:(ncol(out_df) - 1))]

  if (create_qc_figures) {
    p_cor_box <-
      pam50::plot_cor_box(
        out_df,
        file.path(output_dir, "pam50_centroid_cors.png")
      )
    p_pam50_heatmap <-
      pam50::plot_pam50_heatmap(
        out_df, processed_input,
        file.path(output_dir, "pam50_heatmap.png")
      )
    p_centroid_heatmap <-
      pam50::plot_centroid_heatmap(
        out_df,
        file.path(output_dir, "centroid_heatmap.png")
      )
    p_pam50_pca <-
      pam50::plot_pam50_pca(
        out_df, processed_input,
        file.path(output_dir, "pam50_pca.png")
      )
  }
  if (!is.null(output_dir)) {
    utils::write.table(out_df, file.path(output_dir, "pam50_assignments.tsv"),
      quote = FALSE, sep = "\t", row.names = FALSE
    )
  }
  out_df
}
