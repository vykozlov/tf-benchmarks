#!/bin/bash
##### INFO #####################
# a script to be submitted to a batch system as a job
# bare-metal case
################################
HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
HOSTDIR=$PROJECT
LOGFILE=$DATENOW-$HOSTNAME-anaconda2+tf
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
TFBenchScript="all"                    # TF Script to run
TFBenchOpt="--csv_file=$LOGFILE.csv"   # parameters for TF scripts, e.g. --num_batches=1000 or --data_format=NHWC (for CPU)
LOGFILE="$LOGFILE.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
TFBenchmarks/tools/sysinfo.sh >> $LOGFILE
$TFBenchmarks/tf-benchmarks.sh $TFBenchScript $TFBenchOpt >> $LOGFILE
