# PAM50
**Research-Based Molecular Sub-typing for Breast Cancer**

## Introduction
This is a simple R package for running research-grade PAM50 subtype assignments, as originally described by [Parker et al. 2009](https://pubmed.ncbi.nlm.nih.gov/19204204/), on primary or metastatic breast cancer tumor samples.

Broadly, the steps are:
1. Read and check gene expression input (from a file or existing `matrix`).
2. Impute missing values (optional).
3. Center PAM50 gene expression levels using median counts ('self') or a pre-defined set of values (optional).
4. Assign subtypes based on the most highly correlated subtype centroid from [pre-existing training data](https://web.archive.org/web/20130302114722/https://genome.unc.edu/pubsup/breastGEO/clinicalData.shtml). Assigning to the 'Normal-Like' centroid is optional.
5. Calculate ROR scores (using pre-trained coefficients from the orig. pub).
6. Produce a few simple QC figures (optional).
7. Generate output 'data.frame' (and optionally write it to disk).

It's important to note the original centroids were calculated with a specific subtype population and used microarray data. Careful subtype and platform-aware normalization is needed for new test sets. However, PAM50 subtyping has proven to be rather robust.

## Usage

### Main runner
See [./scripts/run_pam50.R](./scripts/run_pam50.R):
```r
library(pam50)
# set level to "ERROR" to minimize logging
logger::log_threshold("DEBUG", namespace = "pam50")

out_df <-
  pam50(
    input = file.path("tests", "testthat", "data", "pam50_testdata.tsv"),
    output_dir = file.path("tmp", "test"),
    centers = "self",
    impute = FALSE,
    tumor_sizes = file.path("tests", "testthat", "data",
                            "pam50_testdata_samplesheet.tsv"),
    include_normal = TRUE,
    create_qc_figures = TRUE
  )
```
### 'Manually'
Each function and dataset has some level of documentation. `pam50::pam50()` is the main runner/helper function to go though the entire analysis. Otherwise, the main steps described above correspond to `pam50` functions:
  1. `read_input()`
  2. `preprocess_input()`
  3. `assign_subtypes()`
  4. `calc_proliferation_scores()`
  5. `calc_ror_scores()`

### Notes
The input matrix must contain all PAM50 genes as rows (any extras will be silently removed). Its row names much correspond to the respective HGNC gene symbols. This package includes `pam50::pam50_annot`, a dataset that maps each PAM50 gene symbol to HGNC IDs and Ensembl stable gene IDs. It is up to the user to ensure the input contains matching gene symbols. However, row order does not need to match -- the input will be properly sorted to match `pam50::pam50_centroids`.

## Installation
Given that imputation and QC plots are optional features, their respective dependencies are not included by default. To include them when installing `pam50`, set `dependencies = "Suggests"`.

### GitHub
```r
# Install full deps (impute + QC plots availble)
remotes::install_github("https://github.com/hoadley-lab/pam50",
                        dependencies = "Suggests")

# Else, only install core functionality (no bioconductor or ggplot2 deps)
# remotes::install_github("https://github.com/hoadley-lab/pam50")
```

### Pre-built image
Given this package will likely be most used in HPC environments, a pre-built SquashFS image is provided that can be ran directly with Apptainer/Singularity. This is the easiest way to get started if you want it to 'just work' without installation. See the tagged releases to download (currently only provided for x86_64 architectures).

Its entry runscript is simply `Rscript --vanilla "$@"`, allowing it to be used as such:
```bash
# Example of getting image, replace <release-tag>
# wget https://github.com/hoadley-lab/pam50/releases/download/<release-tag>/pam50-full-x86_64-linux.sqfs

apptainer run ./pam50-full-x86_64-linux.sqfs ./scripts/run_pam50.R
```
The image contains an R environment with all package dependencies and a slimmed down coreutils. It can also be used to run an interactive `apptainer shell ...`, or arbitrary commands (`apptainer exec ...`).

## Acknowledgments
This code base is a simplified / adapted version of that used by Parker et al. Old scripts can be found in [`./.legacy`](./.legacy).
