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

####### MAIN SETUP #######
TFBenchScript="all"                                  # TF benchmark script to run
HOSTDIR=$PROJECT                                     # directory at your host to mount inside the container.
IMGPATH="$HOSTDIR/workspace/singularity-tests"
SINGULARITYIMG="$IMGPATH/tensorflow-1.5.0-gpu-nv384.81.img"
#-------------------------
TFBenchmarksHost=$HOSTDIR/workspace/tf-benchmarks    # where tf-benchmarks are  (host)
LOGDIRHost=$HOSTDIR/workspace/singularity-tests      # where to store log files (host)
LOGNAME=$DATENOW-$HOSTNAME-singularity
CSVFILE="$LOGNAME.csv"
SYSINFO=$TFBenchmarksHost/tools/sysinfo.sh           # script to get info about the host
DIRINCONTAINER="/home"                               # mount point inside container
LOGDIRContainer=${LOGDIRHost//$HOSTDIR/$DIRINCONTAINER}
TFBenchOpts="--csv_file=$LOGDIRContainer/$CSVFILE"      # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
SCRIPTDIR=${TFBenchmarksHost//$HOSTDIR/$DIRINCONTAINER} # replace host path with one in container
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts" # script to run
###########################

# get info on the current git revision
if [ -n $CSVFILE ]; then
    $TFBenchmarksHost/tools/gitinfo.sh >> $LOGDIRHost/$CSVFILE
fi

LOGFILE="$LOGDIRHost/$LOGNAME.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$SYSINFO >> $LOGFILE
echo "=> Singularity image: $SINGULARITYIMG" >>$LOGFILE
singularity exec --home $HOSTDIR:$DIRINIMG $SINGULARITYIMG $SCRIPT >> $LOGFILE
