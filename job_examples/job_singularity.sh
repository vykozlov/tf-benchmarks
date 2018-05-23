#!/bin/bash
##### INFO ######
# This script supposes to:
# 1. run benchmarks inside the pre-created Singularity container (Tensorflow)
#    by means of singularity (tested with version 2.2.1 on RHEL7)
#
# VKozlov @23-Mar-2018
#
# singularity: http://singularity.lbl.gov
#
################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)

### SCRIPT MAIN SETUP ###
HOSTDIR=$PROJECT
IMGPATH="$HOSTDIR/workspace/singularity-tests"
SINGULARITYIMG="$IMGPATH/tensorflow-1.5.0-gpu-nv384.81.img"
SYSINFO=$HOSTDIR/workspace/tf-benchmarks/tools/sysinfo.sh
LOGFILE=$DATENOW-$HOSTNAME-singularity
DIRINIMG="/home"                               # mount point inside container
SCRIPTDIR="$DIRINIMG/workspace/tf-benchmarks"
TFBenchScript="all"                            # TF benchmark script to run
TFBenchOpts="--csv_file=$LOGFILE.csv"                # parameteres for TF scripts, e.g. --num_batches=1000 or --data_format=NHWC (for CPU)
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts"
#########################


LOGFILE="$LOGFILE.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$SYSINFO >> $LOGFILE
echo "=> Singularity image: $SINGULARITYIMG" >>$LOGFILE
singularity exec --home $HOSTDIR:$DIRINIMG $SINGULARITYIMG $SCRIPT >> $LOGFILE
