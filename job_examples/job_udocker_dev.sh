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

####### MAIN CONFIG #######
TFBenchScript="all"               # TF benchmark script to run
DOCKERTAG="1.6.0-gpu"
DOCKERIMG="tensorflow/tensorflow:$DOCKERTAG"
#export DOCKERTAG="1.4.1-gpu-nv384.81"
#export DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"
#------------------------
HOSTDIR=$PROJECT                       # directory at your host to mount inside the container.
UDOCKER_DIR="$PROJECT/.udocker"        # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"  # udocker setup settings.
UCONTAINER="tf$DOCKERTAG"
UCONTAINER="${UCONTAINER//./}"
TFBenchmarksHost=$HOSTDIR/workspace/tf-benchmarks    # where tf-benchmarks are  (host)
LOGDIRHost=$HOSTDIR/workspace/udocker-tests          # where to store log files (host)
LOGNAME=$DATENOW-$HOSTNAME-udocker-$UCONTAINER
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
