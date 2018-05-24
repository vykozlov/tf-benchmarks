#!/bin/bash
############# MAIN CONFIG ######################
#  normally you do not need to change anything #
#  ..except specifying parameteres:
#
#  Following parameters are used:
#  for benchmark_xxx.py scripts:
#  --batch_size   Batch size
#  --num_bathces  Number of batches to run
#  --data_format  The data format for Convnet operations. Can be either NHWC (CPU) or NCHW (default)
#  --csv_file     File to output script results and information
#
#  for mnist_deep.py:
#  --data_dir       Directory with MNIST input data
#  --mnist_batch    Batch size
#  --mnist_steps    Number of steps to train
#  --csv_file       Same as for benchmark_xxx.py
################################################
USAGEMESSAGE="Usage: $0 {alexnet | googlenet | overfeat | vgg | mnist | all} options \n
              where options are: \n
                for benchmark_xxx.py scripts: \n
                --batch_size    Batch size \n
                --num_bathces   Number of batches to run \n
                --data_format   The data format for ConvNet operations. Can be either NHWC (CPU) or NCHW (default) \n
                --csv_file      File (.csv) to output script results and information \n\n

                for mnist_deep.py: \n
                --data_dir      Directory with MNIST input data \n
                --mnist_batch   Batch size \n
                --mnist_steps   Number of steps to train \n
                --csv_file      Same as for benchmark_xxx.py)"
INFOMESSAGE="=> Should now process scripts"
SCRIPTDIR="$(dirname $0)"
TFBenchmarks=$SCRIPTDIR
DATASETS=$TFBenchmarks/datasets
MNISTData="--data_dir=$DATASETS/mnist/input_data"

## Check correctness of the script call #
arr=("$@")
TFBenchOpts=""
MNISTOpts=""
if [ $# -eq 0 ]; then
    net="alexnet"
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    shopt -s xpg_echo
    echo $USAGEMESSAGE
    exit 1
elif [ $# -eq 1 ]; then
    net=$1
elif [ $# -ge 2 ] && [ $# -le 8 ]; then
    net=$1
    # read benchmark options as parameters
    for i in "${arr[@]}"; do
        [[ $i = *"--batch_size"* ]]  && TFBatchSizeOpt=$i  && TFBatchSize=${i#*=}  && TFBenchOpts=$TFBenchOpts" $i"
        [[ $i = *"--num_batches"* ]] && TFNumBatchesOpt=$i && TFNumBatches=${i#*=} && TFBenchOpts=$TFBenchOpts" $i"
        [[ $i = *"--data_format"* ]] && TFDataFormatOpt=$i && TFDataFormat=${i#*=} && TFBenchOpts=$TFBenchOpts" $i"       
        [[ $i = *"--csv_file"* ]]    && CsvFileOpt=$i && CsvFile=${i#*=} && TFBenchOpts=$TFBenchOpts" $i" && MNISTOpts=$MNISTOpts" $i"
        [[ $i = *"--data_dir"* ]]      && MNISTDataDirOpt=$i   && MNISTData=${i#*=}
        [[ $i = *"--mnist_batch"* ]]   && MNISTBatchSizeOpt=$i && MNISTBatchSize=${i#*=} && MNISTOpts=$MNISTOpts" $i"
        [[ $i = *"--mnist_steps"* ]]  && MNISTStepsOpt=$i    && MNISTSteps=${i#*=}    && MNISTOpts=$MNISTOpts" $i"
    done
else
    echo "ERROR! Too many arguments provided!"
    shopt -s xpg_echo    
    echo $USAGEMESSAGE
    exit 2
fi

# MNISTData either default or re-defined, added at the end
MNISTOpts=$MNISTOpts" $MNISTData"
##
################################################

### Configure what to run ###
unset TFTest
idx=0
if [ "$net" == "alexnet" ]  || [ "$net" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_alexnet.py $TFBenchOpts"
     let idx+=1
fi

if [ "$net" == "googlenet" ] || [ "$net" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_googlenet.py $TFBenchOpts"
     let idx+=1
fi

if [ "$net" == "overfeat" ] || [ "$net" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_overfeat.py $TFBenchOpts" 
     let idx+=1
fi

if [ "$net" == "vgg" ] || [ "$net" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_vgg.py $TFBenchOpts"
     let idx+=1
fi

if [ "$net" == "mnist" ] || [ "$net" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/mnist_deep.py $MNISTOpts"
     let idx+=1
fi

if [ ${#TFTest[0]} -le 5 ]; then 
    echo "Sorry! Did not recognize what you want to do!"
    shopt -s xpg_echo 
    echo $USAGEMESSAGE
    exit 3
fi

TFTestLen=${#TFTest[@]}

echo $INFOMESSAGE
pip install --user future
PyVers=$(python --version 2>&1)
TFVers=$(python $TFBenchmarks/tools/tf_vers.py)
echo "=================================="
echo "=> Python version: $PyVers"
echo "=> Tensorflow version: $TFVers"
echo "=================================="
if [ -n $CsvFile ]; then
   echo "Python, $PyVers" >> $CsvFile
   echo "TensorFlow, $TFVers" >> $CsvFile
fi

for (( i=0; i<${TFTestLen}; i++ ));
do
    echo "=> Execute: ${TFTest[$i]}"
    python ${TFTest[$i]}
done
