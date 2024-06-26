% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pam50.R
\name{assign_subtypes}
\alias{assign_subtypes}
\title{Assign research-based PAM50 molecular subtypes}
\usage{
assign_subtypes(input_matx, include_normal = TRUE)
}
\arguments{
\item{input_matx}{\link{matrix}; output of \code{\link[=read_input]{read_input()}}.}

\item{include_normal}{\link{logical}; whether to include the normal centroid when calculating max correlation. Default: TRUE}
}
\value{
n_samples x 7 column \link{data.frame} with per-substype Spearman Rank correlation and assignments
}
\description{
\code{assign_subtypes} finds the nearest PAM50 subtype centriod per sample
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
input <- pam50::preprocess_input(pam50::pam50_testdata)
predicted_subtypes <- assign_subtypes(input)
\dontshow{\}) # examplesIf}
}
