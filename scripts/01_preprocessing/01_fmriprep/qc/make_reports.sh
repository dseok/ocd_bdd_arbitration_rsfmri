#!/bin/bash

# make reports of fmriprep, prepared for local download through rsync utility

data_root=../../../..
fmridir=${data_root}/preprocessed/fmriprep
reportdir=${fmridir}/reports
scriptdir=$(pwd)

for subdir in $(ls -d ${fmridir}/sub-*/); do
        sub=$(basename ${subdir})
        subreportdir=${reportdir}/${sub}

        # check that this subject has completed fmriprep
        if [ ! -f ${subdir}/figures/${sub}_dseg.svg ]; then
                echo "${sub} has not completed fmriprep"
                continue
        fi

        # check that report hasn't already been prepared
        if [ -d ${subreportdir} ]; then
                echo "${sub} already has a prepared report"
                continue
        else
                mkdir -p ${subreportdir}
        fi

        # make report
        cd ${subreportdir}
        ln -s ../../${sub}.html . # take html file
        mkdir ${sub}
        cd ${sub}
        ln -s ../../../${sub}/figures/ . # take figures in top level directory
        for ses in ../../../${sub}/ses-*; do # loop over sessions, get figures
                sesname=$(basename ${ses})
                mkdir ${sesname}
                cd ${sesname}
                ln -s ../${ses}/figures/ .
                cd -
        done
        # return to scriptdir
        cd ${scriptdir}
done
