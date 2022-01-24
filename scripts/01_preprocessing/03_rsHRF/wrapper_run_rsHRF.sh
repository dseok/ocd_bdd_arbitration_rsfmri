#!/bin/bash

# run rsHRF deconvolution

data_root=../../..
prepdir=${data_root}/preprocessed/fmriprep
outdir=${data_root}/preprocessed/rsHRF
qc_log=../fmriprep/qc/qc_log.csv

batchfile=deconv_voxelwise_multipleregressors_lineardetrend_bandpass_despike.mat

# loop over subjects
for subrow in $(grep "task-rest" ${qc_log}); do 
	sub=$(echo ${subrow} | awk -F ',' '{print $1}')
	ses=$(echo ${subrow} | awk -F ',' '{print $2}')
	scan=$(echo ${subrow} | awk -F ',' '{print $3}')

	# check that subject has passed QC
	if [ $(echo ${subrow} | awk -F ',' '{print $4}') -ne 1 ]; then
		echo "${sub} - ${ses} has not passed QC"
		continue
	fi

	# check that image, mask and nuisance exists
	img=${prepdir}/${sub}/${ses}/func/${sub}_${ses}_${scan}_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz
	mask=${prepdir}/${sub}/${ses}/func/${sub}_${ses}_${scan}_space-MNI152NLin6Asym_desc-brain_mask.nii.gz
	nuisance=${prepdir}/${sub}/${ses}/func/${sub}_${ses}_${scan}_desc-confounds_regressors.tsv
	if [ ! -f ${img} ] || [ ! -f ${mask} ] || [ ! -f ${nuisance} ]; then
		echo "ERROR: ${img}, mask or nuisance does not exist"
		continue
	fi

	# check that subject hasn't already completed
	if [ -d ${outdir}/${sub}/${ses} ]; then
		echo "${sub} - ${ses} has already completed."
		continue
	fi

	# check that subject isn't already running
	if [ -f logs/rsHRF_${sub}_${ses}_RUNNING ]; then
		echo "ERROR: ${sub} - ${ses} is already queued or has failed."
		continue
	fi

	# run
	echo "Submitting ${sub}_${ses}..."
	touch logs/rsHRF_${sub}_${ses}_RUNNING
	qsub -cwd -o logs/rsHRF_${sub}_${ses}_\$JOB_ID.o -j y -l h_rt=4:00:00,h_data=60G \
		run_rsHRF.sh ${batchfile} ${img} ${mask} ${outdir}/${sub}/${ses} ${nuisance} logs/rsHRF_${sub}_${ses}
done

