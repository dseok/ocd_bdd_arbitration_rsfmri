#!/bin/env Rscript

# concatenate all output files to one file

args <- commandArgs(trailingOnly=TRUE)

roiset <- args[1] # arbitration_rois
print(paste('Summarizing', roiset, '...'))


datadir <- file.path('../../../derivatives/dec', roiset)

# loop over files
files <- grep('sub-', list.files(datadir, full.names=TRUE), value=TRUE)
outfile <- file.path(datadir, paste0('summary_', roiset, '.csv'))
data <- c()
for (file in files) {
	filename <- basename(file)
	sub <- gsub('_.*', '', gsub('sub-', '', filename))
	ses <- gsub('_.*', '', gsub('ses-', '', gsub(paste0('sub-', sub, '_'), '', filename)))
	decdata <- read.csv(file, stringsAsFactors=FALSE)
	ondata <- cbind(sub=sub, ses=ses, tp=1:nrow(decdata), decdata)
	data <- rbind(data, ondata)
}

# save
write.csv(data, outfile, row.names=FALSE, quote=FALSE)
