#!/bin/bash
HOSTNAME=$(hostname)
DATENOW=$(date +%y%m%d_%H%M%S)
HOSTDIR=$HOME
TFBenchmarks=$HOSTDIR/workspace/tf-benchmarks
###PBS -o $DATENOW_$HOSTNAME_$(JOBNAME).o$(JOBID)
LOGFILE=$DATENOW-$HOSTNAME-anaconda2+tf.out
echo "=> Running on $HOSTNAME on $DATENOW" >$LOGFILE
echo "=> Info on the system:" >> $LOGFILE
top -bn3 | head -n 5 >> $LOGFILE
echo "" >> $LOGFILE
$TFBenchmarks/tf-benchmarks.sh all >> $LOGFILE
