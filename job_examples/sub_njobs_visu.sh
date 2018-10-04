#!/bin/bash
#####################################
# Script to submit N jobs 
# via msub command on a GPU cluster
#####################################
#JOB2RUN="./udocker_pull_n_setup.sh"
JOB2RUN="./job_udocker.sh"
NJOB=1
for j in $(seq 1 $NJOB)
do 
    echo "Submitting job $j out of $NJOB.."
    msub -N udocker -l nodes=1:ppn=48:visu,walltime=3:00:00 $JOB2RUN
    sleep 1s
done
