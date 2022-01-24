#!/bin/bash

# wrapper for fmriprep: loops over the list of participants who have passed import QC

data_root=../../..
niidir=${data_root}/raw
outdir=${data_root}/preprocessed

qclog=${data_root}/scripts/bids/qc/qc_log.csv

for subdir in ${niidir}/sub-*; do
	sub=$(basename ${subdir})

        # check that subject hasn't already completed fmriprep
        # if this is a new session 2, delete and rerun fmriprep (because fmriprep needs
        # to see the T1 image of the first timepoint)
        if [ -d ${outdir}/fmriprep/${sub} ]; then
                echo "${sub} already has an fmriprep directory"
		continue
        fi

        # check that subject is present in import qc log
        for sesdir in ${subdir}/ses-*; do
                ses=$(basename ${sesdir})
                if [ -z $(grep "${sub},${ses}" ${qclog} | awk '{print $1}') ]; then
                        echo "ERROR: ${sub}: ${ses} is not present in the QC log"
                        exit
                fi
        done

        # check that this subject isn't currently running
	if [ -f logs/${sub}_RUNNING ]; then
		echo "ERROR: ${sub} is running, queued or failed"
		continue
	fi

	echo "Submitting ${sub}..."
	touch logs/${sub}_RUNNING
	logroot=logs/${sub}_$(date +%y%m%d_%H%M%S)
	qsub -cwd -j y -o ${logroot}_\$JOB_ID.o -l h_rt=48:00:00,h_data=20G,highp -pe shared 4 \
		run_fmriprep.sh ${niidir} ${outdir} ${sub} ${logroot}
done
