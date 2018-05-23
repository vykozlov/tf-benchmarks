#!/bin/bash
##### INFO ######
# This script supposes to:
# 1. download a Docker image (Tensorflow)
# 2. run benchmarks inside the container by means of udocker
#
# VKozlov @23-Mar-2018
#
# udocker: https://github.com/indigo-dc/udocker
#
################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)

### SCRIPT MAIN CONFIG ###
DOCKERTAG="1.6.0-gpu"
DOCKERIMG="tensorflow/tensorflow:$DOCKERTAG"
#export DOCKERTAG="1.4.1-gpu-nv384.81"
#export DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"
HOSTDIR=$PROJECT                  # directory at your host to mount inside the container.
UDOCKER_DIR="$PROJECT/.udocker"   # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"  # udocker setup settings.
UCONTAINER="tf$DOCKERTAG"
UCONTAINER="${UCONTAINER//./}"
SYSINFO=$HOSTDIR/workspace/tf-benchmarks/tools/sysinfo.sh
LOGFILE=$DATENOW-$HOSTNAME-udocker-$UCONTAINER
DIRINIMG=/home                    # mount point inside container
SCRIPTDIR=$DIRINIMG/workspace/tf-benchmarks  # directory with tf-benchmark scripts INSIDE container!
TFBenchScript="all"               # TF benchmark script to run
TFBenchOpt="--csv_file=$LOGFILE.csv"  # parameters for TF benchmarks.sh, e.g. --num_batches=1000 or --data_format=NHWC
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpt"
##########################

LOGFILE="$LOGFILE.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$SYSINFO >> $LOGFILE
echo $PATH >> $LOGFILE
echo $UDOCKER_DIR >> $LOGFILE
echo "---------------------" >> $LOGFILE

### UDOCKER SETUP
echo "=> Trying to pull the Docker Image, $DOCKERIMG" >> $LOGFILE
$TFBenchmars/tools/udocker_pull.sh $DOCKERTAG >> $LOGFILE

echo "=> Doing the setup" >> $LOGFILE
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "=> Docker image: $DOCKERIMG" >>$LOGFILE
echo "=> Running" >> $LOGFILE

# For udocker debugging specify "udocker -D run " + the rest
udocker run --volume=$HOSTDIR:$DIRINIMG --workdir=$DIRINIMG ${UCONTAINER} $SCRIPT >>$LOGFILE
