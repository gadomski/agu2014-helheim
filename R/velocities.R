#! /usr/bin/env rscript --vanilla
library(methods)
library(rutils)
library(ggplot2)

args <- commandArgs(trailingOnly = T)
gpsfile <- args[1]
changedir <- args[2]
outfile <- args[3]

p <- rutils::plot_cpd_difference(gpsfile, changedir)
ggplot2::ggsave(outfile, p)
