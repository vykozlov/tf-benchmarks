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
DEFAULTTAG="1.6.0-gpu"
DOCKERIMG="tensorflow/tensorflow"
#DEFAULTTAG="1.4.1-gpu-nv384.81"
#DOCKERIMG="vykozlov/tensorflow:$DOCKERTAG"

if [ $# -eq 0 ]; then
    DOCKERTAG=$DEFAULTTAG
elif [ $# -eq 1 ]; then
    DOCKERTAG=$1
else
    echo "#############################################################"
    echo "#  ERROR! Wrong execution. Either run as"
    echo "#  $> $0 DOCKERTAG (example: $0 1.6.0-gpu)"
    echo "#  or just"
    echo "#  $> $0 (default is set in $0, e.g. DEFAULTTAG=1.6.0-gpu)"
    echo "#############################################################"
    exit 1
fi
DOCKERIMG="$DOCKERIMG:$DOCKERTAG"
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
