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

### SCRIPT MAIN CONFIG ###
DOCKERTAG="1.5.0-gpu"
DOCKERIMG="tensorflow/tensorflow:$DOCKERTAG"
#export DOCKERTAG="1.4.1-gpu-nv384.81"
#export DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"
HOSTDIR=$PROJECT   # directory at your host to mount inside the container.
UDOCKER_DIR="$PROJECT/.udocker"  # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"  # udocker setup settings.
SYSINFO=$HOSTDIR/workspace/tf-benchmarks/tools/sysinfo.sh
DIRINIMG=/home               # make it $HOSTDIR for bare-metal.
SCRIPTDIR=$DIRINIMG/workspace/tf-benchmarks  # directory with tf-benchmark scripts. if container is used, this is directory INSIDE container!
DATASETS=$DIRINIMG/datasets  # 'top' directory for datasets. e.g. MNIST is at $DATASETS/mnist/input_data.
SCRIPTOPT="alexnet $DATASETS"  # parameter for tf-benchmarks.sh : call either one neural net script or all scripts. Specify DATASETS directory.
SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $SCRIPTOPT"
##########################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
UCONTAINER="tf$DOCKERTAG"
UCONTAINER="${UCONTAINER//./}"
LOGFILE=$DATENOW-$HOSTNAME-udocker-$UCONTAINER.out
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$SYSINFO >> $LOGFILE
echo $PATH >> $LOGFILE
echo $UDOCKER_DIR >> $LOGFILE
echo "---------------------" >> $LOGFILE

### UDOCKER SETUP
echo "=> Trying to pull the Docker Image, $DOCKERIMG" >> $LOGFILE
udocker pull $DOCKERIMG

if !(udocker ps |grep "'$UCONTAINER'"); then
    #echo "=> Trying to remove container if it is there" >> $LOGFILE
    #udocker rm ${UCONTAINER}
    echo "=> Creating Container" >> $LOGFILE
    udocker create --name=${UCONTAINER} ${DOCKERIMG}
fi

echo "=> Doing the setup" >> $LOGFILE
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "=> Docker image: $DOCKERIMG" >>$LOGFILE
echo "=> Running" >> $LOGFILE

# For udocker debugging specify "udocker -D run " + the rest
udocker run --volume=$HOSTDIR:$DIRINIMG --workdir=$DIRINIMG ${UCONTAINER} $SCRIPT >>$LOGFILE
