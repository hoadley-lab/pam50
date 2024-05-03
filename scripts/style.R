args <- commandArgs(trailingOnly = TRUE)
input <- args[1]
styler::style_file(input)
