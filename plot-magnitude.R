#! /usr/bin/env rscript --vanilla
library(methods)
library(rutils)
library(ggplot2)

args <- commandArgs(trailingOnly = T)
infile <- args[1]
outfile <- args[2]

p <- rutils::plot_magnitude(rutils::import_change(infile, header = TRUE),
                            low = "#56B1F7", high = "red", limits = c(3.5, 6))
ggplot2::ggsave(outfile, p)
