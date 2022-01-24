#!/bin/env Rscript

# add a header to the output file

args <- commandArgs(trailingOnly=TRUE)

outfile <- args[1]
roi.str <- args[2]

# parse and sort rois
rois <- sort(strsplit(roi.str, split=',')[[1]])
# rois <- strsplit(roi.str, split=',')[[1]]
header <- c()

for (i in rois) {
	for (j in rois) {
		header <- c(header, paste0(j, '-', i))
	}
}

# read outfile, add a header
data <- read.csv(outfile, stringsAsFactors=FALSE, header=FALSE)
colnames(data) <- header
write.csv(data, outfile, row.names=FALSE)
