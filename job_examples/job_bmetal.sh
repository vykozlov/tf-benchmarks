#!/bin/bash

##### INFO #####################
# a script to be submitted to a batch system as a job
# bare-metal case
################################

HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)

####### MAIN CONFIG #######
TFBenchScript="all"                    # TF Script to run
HOSTDIR=$PROJECT
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
LOGDIR=$HOSTDIR/workspace/anaconda2-tests
LOGNAME=$DATENOW-$HOSTNAME-anaconda2+tf
CSVFILE="$LOGNAME.csv"
TFBenchOpts="--csv_file=$LOGDIR/$CSVFILE"   # parameters for TF scripts, e.g. --num_batches=1000 or --data_format=NHWC (for CPU)

# get info on the current git revision
if [ -n $CSVFILE ]; then
    $($TFBenchmarks/tools/gitinfo.sh >> $LOGDIR/$CSVFILE)
fi

LOGFILE="$LOGDIR/$LOGNAME.out"
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
$TFBenchmarks/tools/sysinfo.sh >> $LOGFILE
$TFBenchmarks/tf-benchmarks.sh $TFBenchScript $TFBenchOpts >> $LOGFILE
