#!/bin/bash

# generate a spherical ROI in 2mm FSL MNI standard space

x=${1}
y=${2}
z=${3}
rad=${4}
outpath=${5}

# set up environment
. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module load fsl

# convert MNI coordinates to voxel coordinates
x=$(echo "($x * -1 + 90)/2" | bc)
y=$(echo "($y * 1 + 126)/2" | bc)
z=$(echo "($z * 1 + 72)/2" | bc)

# generate mask
fslmaths ${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz -roi ${x} 1 ${y} 1 ${z} 1 0 1 ${outpath}_point.nii.gz
fslmaths ${outpath}_point.nii.gz -kernel sphere ${rad} -fmean -bin ${outpath}.nii.gz -odt float
rm ${outpath}_point.nii.gz
