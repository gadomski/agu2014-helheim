#! /usr/bin/env rscript --vanilla
library(methods)
library(rutils)
library(ggplot2)

args <- commandArgs(trailingOnly = T)
gpsfile <- args[1]
changedir <- args[2]
outfile <- args[3]

change <- rutils::compare_gps_and_change(gpsfile, changedir)
write.csv(change, outfile)
