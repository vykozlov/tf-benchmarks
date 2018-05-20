#!/bin/bash
HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
HOSTDIR=$PROJECT
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
DATASETS=$HOSTDIR/datasets
###PBS -o $DATENOW_$HOSTNAME_$(JOBNAME).o$(JOBID)
LOGFILE=$DATENOW-$HOSTNAME-anaconda2+tf.out
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
TFBenchmarks/tools/sysinfo.sh >> $LOGFILE
$TFBenchmarks/tf-benchmarks.sh all $DATASETS >> $LOGFILE
