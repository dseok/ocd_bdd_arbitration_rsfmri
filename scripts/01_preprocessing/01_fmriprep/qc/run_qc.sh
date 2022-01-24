#!/bin/bash

# script that will loop over sessions and scans with reports generated
# you can provide a subject (e.g. sub-NDARAB462FH0) to QC only one subject

. /u/local/Modules/default/init/modules.sh
module use /u/project/CCN/apps/modulefiles
module load fsl

data_root=../../../..
fmridir=${data_root}/preprocessed/fmriprep
reportdir=${fmridir}/reports

qc_log=qc_log.csv

if [ ! -f ${qc_log} ]; then
        echo "sub,ses,scan,pass" > ${qc_log}
fi

for subtag in $(ls ${reportdir}); do
        sub=$(echo ${subtag})
        # check if ID was provided
        if [ ! -z ${1} ]; then
                if [ ${sub} != ${1} ]; then
                        continue
                fi
        fi

        echo
        echo "SUBJECT - ${sub}"
        # QC anat first
        if [ $(grep "${sub},NA,anat," ${qc_log} | wc -l) -ne 0 ]; then
                echo "${sub} : anat has completed QC"
        else
                read -p "Does ${sub}: anat pass QC? [y/n] "
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                        echo "${sub},NA,anat,1" >> ${qc_log}
                else
                        echo "${sub},NA,anat,0" >> ${qc_log}
                fi
        fi

        # QC func images next
        for sesdir in $(ls -d ${fmridir}/${sub}/ses-*); do
                ses=$(basename ${sesdir})
                for scanfile in $(ls ${sesdir}/func/*_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz); do
                        scan=$(basename ${scanfile} | sed "s/${sub}_${ses}_//" | sed "s/_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz//")
                        # check that scan hasn't already been QC'd
                        if [ $(grep "${sub},${ses},${scan}," ${qc_log} | wc -l) -ne 0 ]; then
                                echo "${sub}_${ses}: ${scan} has completed QC"
                                continue
                        fi

                        # check if scan has a reduced number of volumes
                        task=$(echo ${scan} | sed 's/task-//' | awk -F '_' '{print $1}')
                        nvols=$(fslnvols ${scanfile})
                        if [[ (${task} == 'rest' && ${nvols} -ne 208) ]]; then
                                echo "WARNING: ${sub}_${ses}: ${scan} has ${nvols} volumes"
                        fi

                        # check for user response
                        read -p "Does ${sub}_${ses}: ${scan} pass QC? [y/n] "
                        if [[ $REPLY =~ ^[Yy]$ ]]; then
                                echo "${sub},${ses},${scan},1" >> ${qc_log}
                        else
                                echo "${sub},${ses},${scan},0" >> ${qc_log}
                        fi
                done
        done
        echo "----------------"
done
