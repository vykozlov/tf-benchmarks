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
#DOCKERTAG="1.5.0-gpu"
#DOCKERIMG="tensorflow/tensorflow:$DOCKERTAG"
DOCKERTAG="1.4.1-gpu-nv384.81"
DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"
HOSTDIR=$PROJECT
DIRINIMG=/home
SCRIPT="$DIRINIMG/workspace/tf-benchmarks/tf-benchmarks.sh all"
##########################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
echo "=> Running on $HOSTNAME on $DATENOW"
LOGFILE=$DATENOW-$HOSTNAME-udocker.out
#echo "=> Trying to pull the Docker Image, $DOCKERIMG"
#udocker pull $DOCKERIMG

UCONTAINER="tf$DOCKERTAG"
UCONTAINER="${UCONTAINER//./}"
echo "=> Trying to remove container if it is there"
#udocker rm ${UCONTAINER}
echo "=> Creating Container"
#udocker create --name=${UCONTAINER} ${DOCKERIMG}

echo $PATH
echo $UDOCKER_DIR
echo "---------------------"

echo "=> Doing the setup"
udocker setup --execmode=F3 --nvidia ${UCONTAINER}

echo "=> Docker image: $DOCKERIMG" >$LOGFILE
echo "Running"

udocker run -v $HOSTDIR:$DIRINIMG -w $DIRINIMG ${UCONTAINER} $SCRIPT >>$LOGFILE
