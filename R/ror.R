#' Calculate Rick of Relapse (ROR) scores
#'
#' `calc_ror_scores` returns a named list of ROR scores for 1 sample
#'
#' Input is the set of PAM50 centroid correlation
#'
#' @param pam50_assignment named [numeric]; single row from [pam50::assign_subtypes]
#' @param prolif_score [numeric]; scaler value. See [pam50::calc_proliferation_scores]
#' @param tumor_size OPTIONAL [logical]; indicator of tumor size > 2cm. If [NA], values depending on tumor_size will be [NA_real_].
#' @returns 1 row [data.frame] with alternating ROR scores, group, per model type
#' @export
calc_ror_scores <- function(pam50_assignment, prolif_score,
                            tumor_size = NA) {
  x_set <- vector("list", length = 4)
  names(x_set) <- names(pam50::ror_coeffs)

  pam50_cors <- pam50_assignment[1:4]

  if (all(names(pam50_cors) != names(pam50::ror_coeffs[[1]]))) {
    logger::log_error("Unexpected order/set of subtype cors in `pam50_cors`")
    stop()
  }

  x_set[["subtype"]] <- pam50_cors
  x_set[["clinical"]] <- unlist(c(x_set$subtype, "tumor_size" = tumor_size))
  x_set[["prolif"]] <- unlist(c(x_set$subtype, "prolif_score" = prolif_score))
  x_set[["prolif_clinical"]] <-
    unlist(c(x_set$clinical, "prolif_score" = prolif_score))

  ror_scores <- sapply(names(x_set), function(ror_model) {
    sum(pam50::ror_coeffs[[ror_model]] * x_set[[ror_model]])
  })

  ror_groups <- ror_group(ror_scores)
  ror_scores <-
    sapply(ror_scores, function(score) 100 * (score + 0.35)) / 0.85

  names(ror_scores) <- paste0("ror_", names(ror_scores))
  names(ror_groups) <- paste0("ror_group_", names(ror_groups))

  # this is what I get for trying to act like R is python
  # simply making a 1 row data frame from two named lists zipped together
  df <-
    sapply(1:4, function(i) c(ror_scores[i], ror_groups[i]),
      simplify = FALSE, USE.NAMES = FALSE
    ) |>
    unlist() |>
    t() |>
    as.data.frame()

  suppressWarnings(df[, c(1, 3, 5, 7)] <-
    lapply(df[, c(1, 3, 5, 7)], as.numeric))
  df
}

#' Assign Rick of Relapse (ROR) group
#'
#' `ror_group` is an internal helper function to go from raw ROR scores
#' to 'low', 'medium', or 'high' risk groups
#'
#' @param ror_scores named `numeric`; single set of scores
#' @returns Named numeric list of ROR group assignments
ror_group <- function(ror_scores) {
  sapply(names(ror_scores), function(ror_mod) {
    score <- ror_scores[[ror_mod]]
    high <- pam50::ror_thresholds[[ror_mod]]["high"]
    low <- pam50::ror_thresholds[[ror_mod]]["low"]
    if (is.na(score)) {
      NA_character_
    } else if (score >= high) {
      "high"
    } else if (score <= low) {
      "low"
    } else if (score > low & score < high) {
      "medium"
    }
  })
}

#' Calculate proliferation score
#'
#' `calc_proliferation_scores` calculates a single numeric score per sample based on a subset of 11 PAM50 genes.
#'
#' @param centered_input numeric [matrix]; 50 rows (PAM50 genes) x N columns (sample). See [pam50::preprocess_input].
#' @returns named [numeric] vector of per sample prolif. score
#' @export
calc_proliferation_scores <- function(centered_input) {
  prolif_genes <-
    pam50::pam50_annot$gene_name[pam50::pam50_annot$proliferative == 1]

  centered_input[prolif_genes, ] |> colMeans(na.rm = TRUE)
}
