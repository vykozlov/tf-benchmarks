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

### MAIN CONFIG ###
UCONTAINER="tf170-gpu"                 # container to run
UDOCKER_DIR="$PROJECT/.udocker"        # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"  # udocker setup settings.
HOSTDIR=$PROJECT                       # directory at your host to mount inside the container.
DIRINIMG="/home"                       # directory inside container
DATASETS=$DIRINIMG/datasets            # directory with datasets, e.g. for MNIST: $DATASETS/mnist/input_data
SCRIPT="$DIRINIMG/workspace/tf-benchmarks/tf-benchmarks.sh mnist $DATASETS" # script to run
##########################

echo "=> Doing the setup"
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "==================================="
echo "=> udocker container: $UCONTAINER"
echo "=> Running on $(hostname) ..."
echo "==================================="

# For udocker debugging specify "udocker -D run " + the rest
udocker run --volume=$HOSTDIR:$DIRINIMG --workdir=$DIRINIMG ${UCONTAINER} $SCRIPT
