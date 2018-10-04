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
NUMGPUS=1                                            # in some systems a node has >1 GPU. e.g. in ForHLR2 one can set NUMGPUS=4 (max)
#--------------------------
UDOCKER_DIR="$PROJECT/.udocker"                      # udocker main directory.
UDOCKERSETUP="--execmode=F3 --nvidia"                # udocker setup settings.
HOSTDIR=$PROJECT                                     # directory at your host to mount inside the container.
TFBenchmarksHost=$HOSTDIR/workspace/tf-benchmarks    # where tf-benchmarks are  (host)
LOGDIRHost=$HOSTDIR/workspace/udocker-tests          # where to store log files (host)
DIRINCONTAINER="/home"                               # mount point inside container
LOGDIRContainer=${LOGDIRHost//$HOSTDIR/$DIRINCONTAINER}
SCRIPTDIR=${TFBenchmarksHost//$HOSTDIR/$DIRINCONTAINER} # replace host path with one in container
MNISTDATA="$SCRIPTDIR/datasets/mnist/input_data"     # where MNIST data are located
###########################
echo $SCRIPT

git_info () {
    # get info on the current git revision
    if [ -n $CSVFILE ]; then
        $TFBenchmarksHost/tools/gitinfo.sh >> $LOGDIRHost/$CSVFILE
    fi
}

echo "=> Doing the setup"
udocker setup $UDOCKERSETUP ${UCONTAINER}

echo "==================================="
echo "=> udocker container: $UCONTAINER"
echo "=> Running on $(hostname) ..."
echo "==================================="

# For udocker debugging specify "udocker -D run " + the rest
if [ $NUMGPUS -ge 2 ]; then
    for (( i=0; i<$NUMGPUS; i++ ));
    do
        CSVFILE="$DATENOW-$HOSTNAME-udocker-$UCONTAINER-gpu$i.csv"                       # let us have one CSV file per GPU
        TFBenchOpts="--csv_file=$LOGDIRContainer/$CSVFILE --data_dir=$MNISTDATA"      # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
        SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts" # script to run
        git_info
        udocker run --volume=$HOSTDIR:$DIRINCONTAINER --env="CUDA_VISIBLE_DEVICES=$i" --workdir=$DIRINCONTAINER ${UCONTAINER} $SCRIPT &
    done
    wait  ### IMPORTANT!
else
    CSVFILE="$DATENOW-$HOSTNAME-udocker-$UCONTAINER.csv"
    TFBenchOpts="--csv_file=$LOGDIRContainer/$CSVFILE  --data_dir=$MNISTDATA"      # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
    SCRIPT="$SCRIPTDIR/tf-benchmarks.sh $TFBenchScript $TFBenchOpts" # script to run
    git_info
    udocker run --volume=$HOSTDIR:$DIRINCONTAINER --workdir=$DIRINCONTAINER ${UCONTAINER} $SCRIPT
fi
