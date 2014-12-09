#! /usr/bin/env rscript --vanilla
library(methods)
library(rutils)
library(ggplot2)

args <- commandArgs(trailingOnly = T)
infile <- args[1]
outfile <- args[2]
minm <- as.numeric(args[3])
maxm <- as.numeric(args[4])

p <- rutils::plot_magnitude(rutils::import_change(infile, skip = 1, sep = ","),
                            low = "blue", high = "red", limits = c(minm, maxm))
ggplot2::ggsave(outfile, p)
