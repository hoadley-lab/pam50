% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc.R
\name{plot_cor_box}
\alias{plot_cor_box}
\title{Plot pairwise centroid correlations across samples}
\usage{
plot_cor_box(input_df, output_png = NULL)
}
\arguments{
\item{input_df}{\link{data.frame}. See \code{\link[=pam50]{pam50()}}}

\item{output_png}{\link{character}. Optional ouput path to save plot}
}
\value{
A \code{ggplot2} boxplot object
}
\description{
\code{plot_cor_box} returns a \code{ggplot2} object
}
\details{
Input is the data.frame output of \code{\link[=pam50]{pam50()}}. \pkg{ggplot2} required.
}
