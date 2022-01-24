#!/bin/bash

# run DEC on a set of seeds

roifile=arbitration_rois.csv

data_root=../../..
rsdir=${data_root}/preprocessed/rsHRF
outdir=${data_root}/derivatives/dec/$(echo ${roifile} | sed 's/.csv//')
roidir=${data_root}/rois

# make outdir
if [ ! -d ${outdir} ]; then
	mkdir -p ${outdir}
fi

# specify ROIs and generate those we don't have yet
if [ ! -f ${roifile} ]; then
	echo "ERROR: ${roifile} does not exist"
	exit
else
	# generate ROIs
	for roirow in $(tail -n +2 ${roifile}); do
		# parse ROI
		x=$(echo ${roirow} | awk -F ',' '{print $1}')
		y=$(echo ${roirow} | awk -F ',' '{print $2}')
		z=$(echo ${roirow} | awk -F ',' '{print $3}')
		rad=$(echo ${roirow} | awk -F ',' '{print $4}')
		roiname=$(echo ${roirow} | awk -F ',' '{print $5}')

		# check that this isn't a spherical ROI
		if [ -z ${x} ] || [ -z ${y} ] || [ -z ${z} ] || [ -z ${rad} ]; then		
			roipath=${roidir}/${roiname}
		else
			roipath=${roidir}/${roiname}_x${x}_y${y}_z${z}_rad-${rad}

			# check that this roi doesn't already exist
			if [ ! -f ${roipath}.nii.gz ]; then
				./generate_spherical_roi.sh ${x} ${y} ${z} ${rad} ${roipath}
			fi
		fi
	done
fi

# loop over sessions
for sesdir in ${rsdir}/sub-*/ses-*; do
	sub=$(echo ${sesdir} | awk -F '/' '{print $(NF-1)}')
	ses=$(basename ${sesdir})

	# check that image exists
	img=${sesdir}/Deconv_rsHRF_${sub}_${ses}_img_Olrm.nii.gz
	if [ ! -f ${img} ]; then
		echo "ERROR: ${img} does not exist"
		continue
	fi

	# check that output doesn't already exist
	if [ -f ${outdir}/${sub}_${ses}_dec_output.csv ]; then
		echo "${outdir}/${sub}_${ses}_dec_output.csv has already completed"
		continue
	fi

	# submit
	echo "Submitting ${sub} - ${ses} ..."
	logroot=logs/dec_${sub}_${ses}_$(echo ${roifile} | sed 's/\.csv//')_$(date +%y%m%d_%H%M%S_%N)
	qsub -cwd -o ${logroot}_\$JOB_ID.o -j y -l h_rt=4:00:00,h_data=12G \
		./run_dec.sh ${img} ${outdir}/${sub}_${ses}_dec_output.csv ${roifile} ${roidir} ${logroot}
done
