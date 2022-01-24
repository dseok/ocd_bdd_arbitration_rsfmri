#!/bin/bash

# run fmriprep

niidir=${1}
outdir=${2}
sub=${3}
workdir=${4}

echo "Work directory: ${TMPDIR}"

# initiate job environment
. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles

# load modules
module load fsl/5.0.9
module load python/3.7.2
module load freesurfer/6.0.0
module load ants/ants-2.3.1
module load afni/19.0.15
module load ica-aroma
module load itksnap/3.6.0-RC1.QT4
module load fmriprep/1.4.0

export PATH=/u/project/CCN/apps/c3d/c3d-1.0.0-Linux-x86_64/bin/:$PATH
export NO_FSL_JOBS=true

license=PATH_TO_FMRIPREP_LICENSE

# run fmriprep
echo "Processing all BOLD runs ..."
fmriprep ${niidir} ${outdir} participant --fs-license-file ${license} \
	--participant_label ${sub} -w ${TMPDIR} \
	--use-syn-sdc --use-aroma # --fs-no-reconall

echo "Complete!"

echo "Moving log file ..."
# remove logfile
logfile=${workdir}*.o
logdir=${outdir}/fmriprep/${sub}/logs
if [ ! -d ${logdir} ]; then
	mkdir -p ${logdir}
fi
mv ${logfile} ${logdir}

# remove running file
rm logs/${sub}_RUNNING
