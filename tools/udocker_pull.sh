#!/bin/bash
##### INFO ######
# This script supposes to:
# 1. download a Docker image (Tensorflow)
# 2. create corresponding udocker container
#
# VKozlov @18-May-2018
#
# udocker: https://github.com/indigo-dc/udocker
#
################

### MAIN CONFIG ###
DOCKERTAG="1.6.0-gpu"
DOCKERIMG="tensorflow/tensorflow:$DOCKERTAG"
#export DOCKERTAG="1.4.1-gpu-nv384.81"
#export DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"
UDOCKER_DIR="$PROJECT/.udocker"  # udocker main directory.
##########################

UCONTAINER="tf$DOCKERTAG"
UCONTAINER="${UCONTAINER//./}"
echo "=> Trying to pull the Docker Image: $DOCKERIMG"
udocker pull $DOCKERIMG

if !(udocker ps |grep -q "'$UCONTAINER'"); then
    #echo "=> Trying to remove container if it is there" >> $LOGFILE
    #udocker rm ${UCONTAINER}
    echo "=> Creating Container"
    udocker create --name=${UCONTAINER} ${DOCKERIMG}
    echo "########################################"
    echo "  contrainer $UCONTAINER created       "
    echo "  note the name and use it for jobs    "
    echo "########################################"    
else
    echo "###########################################"
    echo "  contrainer $UCONTAINER already exists!  "
    echo "  note the name and use it for jobs       "
    echo "###########################################"
fi
