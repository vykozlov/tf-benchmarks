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

### MAIN CONFIG ###
UCONTAINER="tf160-gpu"                 # container to use
UDOCKER_DIR="$PROJECT/.udocker"        # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"  # udocker setup settings.
HOSTDIR=$PROJECT                       # directory at your host to mount inside the container.
DIRINIMG="/home"                       # mount point inside container
TFBenchScript="all"                    # TF benchmark script to run
#TFBenchOpt="--num_batches=1000"       # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
SCRIPT="$DIRINIMG/workspace/tf-benchmarks/tf-benchmarks.sh $TFBenchScript $TFBenchOpt" # script to run
##########################

echo "=> Doing the setup"
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "==================================="
echo "=> udocker container: $UCONTAINER"
echo "=> Running on $(hostname) ..."
echo "==================================="

# For udocker debugging specify "udocker -D run " + the rest
udocker run --volume=$HOSTDIR:$DIRINIMG --workdir=$DIRINIMG ${UCONTAINER} $SCRIPT
