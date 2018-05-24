#!/bin/bash
##### INFO ######
# This script supposes to:
# 1. run TensorFlow benchmarks inside the container by means of udocker
#
# VKozlov @23-Mar-2018
#
# udocker: https://github.com/indigo-dc/udocker
#
################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)

####### MAIN CONFIG #######
TFBenchScript="all"                                  # TF benchmark script to run
UCONTAINER="tf160-gpu"                               # container to use
#--------------------------
UDOCKER_DIR="$PROJECT/.udocker"                      # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"                # udocker setup settings.
HOSTDIR=$PROJECT                                     # directory at your host to mount inside the container.
TFBenchmarksHost=$HOSTDIR/workspace/tf-benchmarks    # where tf-benchmarks are  (host)
LOGDIRHost=$HOSTDIR/workspace/udocker-tests          # where to store log files (host)
CSVFILE="$DATENOW-$HOSTNAME-udocker-$UCONTAINER.csv"
DIRINCONTAINER="/home"                               # mount point inside container
LOGDIRContainer=${LOGDIRHost//$HOSTDIR/$DIRINCONTAINER}
TFBenchOpts="--csv_file=$LOGDIRContainer/$CSVFILE"      # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
SCRIPTDIR=${TFBenchmarksHost//$HOSTDIR/$DIRINCONTAINER} # replace host path with one in container
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts" # script to run
###########################
echo $SCRIPT

# get info on the current git revision
if [ -n $CSVFILE ]; then
    $TFBenchmarksHost/tools/gitinfo.sh >> $LOGDIRHost/$CSVFILE
fi

echo "=> Doing the setup"
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "==================================="
echo "=> udocker container: $UCONTAINER"
echo "=> Running on $(hostname) ..."
echo "==================================="

# For udocker debugging specify "udocker -D run " + the rest
udocker run --volume=$HOSTDIR:$DIRINCONTAINER --workdir=$DIRINCONTAINER ${UCONTAINER} $SCRIPT
