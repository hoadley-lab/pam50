###
# input variables for the subtype prediction script
###
library(ctc)
library(heatmap.plus)

paramDir <- "C:/Users/JParker/Desktop/bioclassifier_R" # the location of unchanging files such as the function library and main program
inputDir <- "C:/Users/JParker/Desktop/bioclassifier_example" # the location of the data matrix, and where output will be located

inputFile <- "sampleInputFile_200subjects.txt" # the input data matrix as a tab delimited text file
short <- "sampleInputFile_200subjects" # short name that will be used for output files

calibrationParameters <- NA # the column of the "mediansPerDataset.txt" file to use for calibration;
# NA will force centering within the test set & -1 will not do any
# adjustment (when adjustment performed by used)

hasClinical <- FALSE # may include tumor size as second row, with 'T' as the gene name,
# and encoded as binary (0 for size <= 2cm or 1 for size > 2cm)
# set this variable to FALSE if tumor size is not available

collapseMethod <- "mean" # can be mean or iqr (probe with max iqr is selected)
# typically, mean is preferred for long oligo and
# iqr is preferred for short oligo platforms


####
# run the assignment algorithm
####

source(paste(paramDir, "subtypePrediction_functions.R", sep = "/"))
source(paste(paramDir, "subtypePrediction_distributed.R", sep = "/"))
