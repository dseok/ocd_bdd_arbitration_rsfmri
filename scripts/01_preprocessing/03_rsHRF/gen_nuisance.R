#!/bin/env Rscript

# read in a tab-delim file and return a text file with only your desired columns

args <- commandArgs(trailingOnly=TRUE)

input <- args[1]
output <- args[2]
cols.str <- args[3]

# parse cols.str
cols <- strsplit(cols.str, split=',')[[1]]

# read input, subset and save
data <- read.delim(input, stringsAsFactors=FALSE)
data <- data[,cols]
write.table(data, file=output, sep=' ', row.names=FALSE, col.names=FALSE)
