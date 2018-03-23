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

### SCRIPT MAIN SETUP ###
HOSTDIR=$PROJECT
IMGPATH="$HOSTDIR/workspace/singularity-tests"
SINGULARITYIMG="$IMGPATH/tensorflow-1.4.1-gpu-nv384.81.img"
DIRINIMG=/home
SCRIPT="$DIRINIMG/workspace/tf-benchmarks/tf-benchmarks.sh all"
#########################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
LOGFILE=$DATENOW-$HOSTNAME-singularity.out

echo "=> Singularity image: $SINGULARITYIMG" >$LOGFILE
singularity exec --home $HOSTDIR:$DIRINIMG $SINGULARITYIMG $SCRIPT >> $LOGFILE
