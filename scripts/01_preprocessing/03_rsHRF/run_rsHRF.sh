#!/bin/bash

# call MATLAB scripts that will perform rsHRF

batchfile=${1}
img=${2}
mask=${3}
outdir=${4}
nuisance=${5}
logroot=${6}

. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module load R
module load matlab/9.1
module load fsl
export MATLABPATH=/u/project/CCN/apps/spm12

# identify TR
tr=$(fslinfo ${img} | grep pixdim4 | awk '{print $2}')

# gunzip img and mask
gunzip -c ${img} > ${logroot}_img.nii
gunzip -c ${mask} > ${logroot}_mask.nii

# create regressor file - regressing out CSF and performing GSR
./gen_nuisance.R ${nuisance} ${logroot}_nuisance.txt 'csf,global_signal'
nuisance=${logroot}_nuisance.txt

# make batch file
echo "Generating batch file..."
batchoutpath=${logroot}_batch.mat
matlab -nosplash -nodisplay -nodesktop -r "make_batch_file('${batchfile}', '${batchoutpath}', '${logroot}_img.nii,1', ${tr}, '${logroot}_mask.nii,1', '${outdir}', '${nuisance}'),quit()"

# perform rsHRF
echo "Performing rsHRF..."
matlab -nosplash -nodisplay -nodesktop -r "run_rsHRF('${batchoutpath}'), quit()"

# gzip all output niftis
echo "gzipping all outputs..."
for file in ${outdir}/*.nii; do
	gzip ${file}
done

# move log file and delete scratch
echo "Moving log file and deleting scratch"
mv ${logroot}*.o ${outdir}
rm -f ${logroot}*
