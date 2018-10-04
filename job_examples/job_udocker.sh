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
UCONTAINER="tfbench-gpu"                             # container to use
NUMGPUS=4                                            # in some systems a node has >1 GPU. e.g. in ForHLR2 one can set NUMGPUS=4 (max)
TFBench="all"                                        # TF benchmark to run (alexnet, googlenet, overfeat, vgg, mnist, all)
TFBenchOpts="--num_batches=1000"                     # options for TFBenchmark scripts, e.g.: --num_batches=1000 or --data_format=NHWC (for CPU)
LOGDIRHost=$PROJECT/workspace/udocker-tests          # where to store log files (host)
#--------------------------
UDOCKER_DIR="$PROJECT/.udocker"                      # udocker main directory.
LOGDIRContainer="/output"                            # where to store log files (container)
###########################

echo "==================================="
echo "=> udocker container: $UCONTAINER"
echo "=> Running on $HOSTNAME"
echo "==================================="

# For udocker debugging specify "udocker -D run " + the rest
if [ $NUMGPUS -ge 2 ]; then
    for (( i=0; i<$NUMGPUS; i++ ));
    do
        CSVFILE="$DATENOW-$HOSTNAME-udocker-$UCONTAINER-gpu$i.csv"            # let us have one CSV file per GPU
        TFBenchOpts="$TFBenchOpts --csv_file=$LOGDIRContainer/$CSVFILE"       # extend TFBenchOpts with --csv_file for csv output
        SCRIPT="./tf-benchmarks.sh $TFBench $TFBenchOpts"                     # script to run
        udocker run --volume=$LOGDIRHost:$LOGDIRContainer --env="CUDA_VISIBLE_DEVICES=$i" ${UCONTAINER} $SCRIPT &
    done
    wait  ### IMPORTANT!
else
    CSVFILE="$DATENOW-$HOSTNAME-udocker-$UCONTAINER.csv"
    TFBenchOpts="$TFBenchOpts --csv_file=$LOGDIRContainer/$CSVFILE"           # extend TFBenchOpts with --csv_file for csv output
    SCRIPT="./tf-benchmarks.sh $TFBench $TFBenchOpts"                         # script to run
    udocker run --volume=$LOGDIRHost:$LOGDIRContainer ${UCONTAINER} $SCRIPT
fi
