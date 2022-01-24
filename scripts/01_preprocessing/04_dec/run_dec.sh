#!/bin/bash

# run DEC

img=${1}
outfile=${2}
roifile=${3}
roidir=${4}
logroot=${5}

. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module load fsl
module load R
module load matlab # /9.1

# sample ROIs
roinames=
for roirow in $(tail -n +2 ${roifile}); do
	echo ${roirow}
	# parse ROI
	x=$(echo ${roirow} | awk -F ',' '{print $1}')
	y=$(echo ${roirow} | awk -F ',' '{print $2}')
	z=$(echo ${roirow} | awk -F ',' '{print $3}')
	rad=$(echo ${roirow} | awk -F ',' '{print $4}')
	roiname=$(echo ${roirow} | awk -F ',' '{print $5}')

	# if there are NAs for x, y, z or rad, then simply get roipath from the name
	if [ -z ${x} ] || [ -z ${y} ] || [ -z ${z} ] || [ -z ${rad} ]; then
		roipath=${roidir}/${roiname}
	else
		roipath=${roidir}/${roiname}_x${x}_y${y}_z${z}_rad-${rad}
	fi

	fslmeants -i ${img} -o ${logroot}_${roiname}_meants.txt -m ${roipath}

	# keep track of roinames to generate a header
	echo ${roiname}
	roinames="${roinames},${roiname}"

	# paste to end of new file
	if [ ! -f ${logroot}_meants.txt ]; then
		cp ${logroot}_${roiname}_meants.txt ${logroot}_meants.txt
	else
		paste ${logroot}_meants.txt ${logroot}_${roiname}_meants.txt > ${logroot}_tmp.txt
		mv ${logroot}_tmp.txt ${logroot}_meants.txt
	fi
done

# remove first ,
roinames=$(echo ${roinames} | sed 's/^,//')
echo ${roinames}

# concantenate all ts into data file
paste ${logroot}*_meants.txt > ${logroot}_meants.txt

# submit to DEC
matlab -nosplash -nodisplay -nodesktop -r "run_dec('${logroot}_meants.txt', '${outfile}')"

# generate header
./add_header.R ${outfile} ${roinames}

# cleanup
echo "Deleting all temp files"
rm ${logroot}*_meants.txt
#mv ${logroot}*.o ${outdir}
#rm ${logroot}*
