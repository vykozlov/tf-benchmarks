#!/bin/bash
HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
HOSTDIR=$PROJECT
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
TFBenchScript="all"                 # TF Script to run
#TFBenchOpt="--num_batches=1000"     # parameters for TF scripts, e.g. --num_batches=1000 or --data_format=NHWC (for CPU)
###PBS -o $DATENOW_$HOSTNAME_$(JOBNAME).o$(JOBID)
LOGFILE=$DATENOW-$HOSTNAME-anaconda2+tf.out
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
TFBenchmarks/tools/sysinfo.sh >> $LOGFILE
$TFBenchmarks/tf-benchmarks.sh $TFBenchScript $TFBenchOpt >> $LOGFILE
