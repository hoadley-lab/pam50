#' Plot pairwise centroid correlations across samples
#'
#' `plot_cor_box` returns a `ggplot2` object
#'
#' Input is the data.frame output of [pam50::pam50()]. \pkg{ggplot2} required.
#'
#' @param input_df [data.frame]. See [pam50::pam50()]
#' @param output_png [character]. Optional ouput path to save plot
#' @returns A `ggplot2` boxplot object
#' @export
plot_cor_box <- function(input_df, output_png = NULL) {
  library(rlang)
  ggplot2::theme_set(ggplot2::theme_minimal())

  p <-
    input_df |>
    tidyr::pivot_longer(
      cols = colnames(pam50::pam50_centroids),
      names_to = "centroid", values_to = "cor"
    ) |>
    ggplot2::ggplot(ggplot2::aes(.data$centroid, .data$cor)) +
    ggplot2::geom_boxplot(ggplot2::aes(group = interaction(.data$centroid, .data$assignment)),
      outlier.shape = NA
    ) +
    ggplot2::geom_point(ggplot2::aes(color = .data$assignment),
      position = ggplot2::position_jitterdodge(jitter.width = 0.2),
      alpha = 0.9
    ) +
    ggplot2::scale_color_manual(values = pam50::pam50_palette) +
    ggplot2::theme(legend.position = "top")

  if (!is.null(output_png)) {
    logger::log_debug("saving PAM50 centroid cor boxplot to: {output_png}")
    ggplot2::ggsave(output_png, width = 16, height = 9, scale = 0.85)
  }
  p
}

#' Plot a heatmap of PAM50 gene expression across samples
#'
#' `plot_pam50_heatmap` creates a heatmap of centered PAM50 gene expression with subtype and ROR group assignment annotations.
#'
#' Input is the data.frame output of [pam50::pam50()] and processed gene expression from [pam50::preprocess_input()]. \pkg{ComplexHeatmap} required.
#' @param input_df [data.frame]. See [pam50::pam50()]
#' @param input_matx numeric [matrix]. See [pam50::preprocess_input()] output.
#' @param output_png [character]. Optional ouput path to save plot.
#' @returns A \pkg{ComplexHeatmap} object
#' @export
plot_pam50_heatmap <- function(input_df, input_matx, output_png = NULL) {
  scalefn <-
    circlize::colorRamp2(
      breaks = c(-3, 0, 3),
      colors = c("blue", "#EEEEEE", "red"),
      space = "RGB"
    )
  risk_palette <-
    factor(c("low" = "mediumseagreen", "medium" = "gold", "high" = "red"))
  ror_columns <-
    c(
      "ror_group_subtype", "ror_group_prolif",
      "ror_group_clinical", "ror_group_prolif_clinical"
    )

  risk_palettes <-
    sapply(ror_columns, function(i) risk_palette, simplify = FALSE)

  palettes <- c("assignment" = list(pam50::pam50_palette), risk_palettes)
  annot_df <- input_df[, c("assignment", ror_columns)]

  col_annot <-
    ComplexHeatmap::columnAnnotation(
      df = annot_df,
      col = palettes,
      na_col = "#FFFFFF"
    )

  ht <- ComplexHeatmap::Heatmap(input_matx,
    clustering_distance_rows = "pearson",
    clustering_method_rows = "average",
    show_row_dend = TRUE,
    clustering_distance_columns = "pearson",
    clustering_method_columns = "average",
    show_row_names = TRUE,
    column_names_gp = grid::gpar(fontsize = 6),
    column_names_rot = 45,
    col = scalefn,
    top_annotation = col_annot,
    row_title_side = "left",
    heatmap_legend_param = list(title = "")
  )

  if (!is.null(output_png)) {
    logger::log_debug("saving heatmap to: {output_png}")
    grDevices::png(output_png, height = 9, width = 16, units = "in", res = 300)
    ComplexHeatmap::draw(ht, merge_legends = TRUE)
    grDevices::dev.off()
  }
  ht
}

#' PCA plot of PAM50 gene expression across samples.
#'
#' `plot_pam50_pca` creates a PCA plot annotated with assignmed PAM50 subtypes. \pkg{ggplot2} required.
#'
#' @param input_df [data.frame]. See [pam50::pam50()]
#' @param input_matx [matrix]. See [pam50::preprocess_input()] output.
#' @param output_png [character]. Optional ouput path to save plot
#' @returns A \pkg{ggplot2} object
#' @export
plot_pam50_pca <- function(input_df, input_matx, output_png = NULL) {
  library(rlang)
  ggplot2::theme_set(ggplot2::theme_minimal())

  if (any(is.na(input_matx))) {
    logger::log_debug("Imputing missing values for PCA")
    input_matx <- impute::impute.knn(input_matx)$data
  }
  pca <- stats::prcomp(t(input_matx))
  perc_var <- base::signif((pca$sdev^2 / base::sum(pca$sdev^2)) * 100, 3)

  pca_df <-
    pca$x |>
    as.data.frame()

  pca_df$samplename <- rownames(pca_df)
  pca_df <- pca_df[, c("samplename", "PC1", "PC2")]

  pca_df <- merge(pca_df, input_df[, c("samplename", "assignment")])

  p <-
    pca_df |>
    ggplot2::ggplot(ggplot2::aes(.data$PC1, .data$PC2, color = .data$assignment)) +
    ggplot2::geom_point() +
    ggplot2::scale_color_manual(values = pam50::pam50_palette) +
    ggplot2::labs(
      x = base::paste0("PC1 ( ", perc_var[1], "% variance)"),
      y = base::paste0("PC2 ( ", perc_var[2], "% variance)")
    ) +
    ggplot2::theme(legend.position = "top")
  if (!is.null(output_png)) {
    logger::log_debug("saving PCA plot to: {output_png}")
    ggplot2::ggsave(output_png, width = 16, height = 9, scale = 0.85)
  }
  p
}
