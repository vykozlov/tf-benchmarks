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

##### MAIN SETUP #####
HOSTDIR=$PROJECT
IMGPATH="$HOSTDIR/workspace/singularity-tests"
SINGULARITYIMG="$IMGPATH/tensorflow-1.5.0-gpu-nv384.81.img"
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
SYSINFO=$TFBenchmarks/tools/sysinfo.sh
LOGNAME=$DATENOW-$HOSTNAME-singularity
CSVFILE="$LOGNAME.csv"
DIRINIMG="/home"                               # mount point inside container
SCRIPTDIR="$DIRINIMG/workspace/tf-benchmarks"
TFBenchScript="all"                            # TF benchmark script to run
TFBenchOpts="--csv_file=$CSVFILE"              # parameteres for TF scripts, e.g. --num_batches=1000 or --data_format=NHWC (for CPU)
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts"
#########################

if [ -n $CSVFILE ]; then
    $($TFBenchmarks/tools/gitinfo.sh >> $CSVFILE)
fi

LOGFILE="$LOGNAME.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$SYSINFO >> $LOGFILE
echo "=> Singularity image: $SINGULARITYIMG" >>$LOGFILE
singularity exec --home $HOSTDIR:$DIRINIMG $SINGULARITYIMG $SCRIPT >> $LOGFILE
