#!/bin/bash

# run resting state using XCPengine

logroot=${1}
design=${2}
cohort=${3}
output=${4}

xcpdir=~/xcp/xcpEngine

# declare environment
. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module load fsl/5.0.9
module load python/3.7.2
module load freesurfer/6.0.0
module load ants/ants-2.3.1
module load afni/19.0.15
module load itksnap/3.6.0-RC1.QT4
export PATH=/u/project/CCN/apps/c3d/c3d-1.0.0-Linux-x86_64/bin/:$PATH
export XCPEDIR=${xcpdir}

# run xcpEngine
echo "Running xcpEngine ..."
echo
${xcpdir}/xcpEngine \
	-d ${design} \
	-c ${cohort} \
	-o ${output} \
	-t 1

echo "XCPEngine task complete."
echo "Moving log file and removing RUNNING tag"
exit
# parse subject, ses and scan
sub=$(basename ${logroot} | sed "s/xcp-rest_//" | awk -F '_' '{print $1}')
ses=$(basename ${logroot} | sed "s/xcp-rest_//" | awk -F '_' '{print $2}')
scan=$(basename ${logroot} | sed "s/xcp-rest_${sub}_${ses}_//")
rm logs/xcp-rest_${sub}_${ses}_${scan}_RUNNING
mv ${logroot}* ${output}/${sub}/${ses}/${scan}/${sub}_${ses}_${scan}_logs/
