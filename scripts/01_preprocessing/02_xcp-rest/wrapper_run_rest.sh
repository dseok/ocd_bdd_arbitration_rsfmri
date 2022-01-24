#!/bin/bash

# wrapper to run resting state analyses using XCP

data_root=../../..
qc_log=../fmriprep/qc/qc_log.csv
fmridir=${data_root}/preprocessed/fmriprep
outdir=${data_root}/preprocessed/xcp-rest

design_name=fc-aroma_GSR_CSF_lineardetrend.dsn

# loop over files in qc_log.csv
for scanrow in $(grep ",task-rest_run-*" ${qc_log}); do
        sub=$(echo ${scanrow} | awk -F ',' '{print $1}')
        ses=$(echo ${scanrow} | awk -F ',' '{print $2}')
        scan=$(echo ${scanrow} | awk -F ',' '{print $3}')

        # check that img exists
        img=${fmridir}/${sub}/${ses}/func/${sub}_${ses}_${scan}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
        if [ ! -f ${img} ]; then
                echo "ERROR: ${img} does not exist"
                continue
        fi

        # check that img has passed QC
        qc_pass=$(echo ${scanrow} | awk -F ',' '{print $4}')
        if [ ${qc_pass} -ne 1 ]; then
                echo "ERROR: ${sub} - ${ses} - ${scan} has failed QC"
                continue
        fi

        # check that subject hasn't already completed
        if [ -d ${outdir}/${sub}/${ses}/${scan} ]; then
                echo "${sub} - ${ses} - ${scan} has already completed"
                continue
        fi

        # check that subject isn't already running
        if [ -f logs/xcp-rest_${sub}_${ses}_${scan}_RUNNING ]; then
                echo "ERROR: ${sub} - ${ses} - ${scan} is already queued or has failed"
                continue
        fi

        # make cohort file
        echo "id0,id1,id2,img" > cohorts/${sub}_${ses}_${scan}_cohort.csv
        echo "${sub},${ses},${scan},${img}" >> cohorts/${sub}_${ses}_${scan}_cohort.csv

        # run
        echo "Submitting ${sub}_${ses}: ${scan} ..."
        touch logs/xcp-rest_${sub}_${ses}_${scan}_RUNNING
        qsub -cwd -l h_vmem=15.0G,s_vmem=15.0G \
                -j y -o logs/xcp-rest_${sub}_${ses}_${scan}_\$JOB_ID.o \
                run_rest.sh \
                        logs/xcp-rest_${sub}_${ses}_${scan} \
                        designs/${design_name} \
                        cohorts/${sub}_${ses}_${scan}_cohort.csv \
                        ${outdir}
done
