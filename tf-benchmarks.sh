#!/bin/bash
###### SCRIPT MAIN CONFIG ######################
#  normally you do not need to change anything #
################################################
USAGEMESSAGE="Usage: $0 {alexnet | googlenet | overfeat | vgg | mnist | all} datasetsdir"
INFOMESSAGE="=> Should now process scripts"
SCRIPTDIR="$(dirname $0)"
TFBenchmarks=$SCRIPTDIR

## Check correctness of the script call #
if [ $# -eq 0 ]; then
    arg="alexnet"
elif [ $1 == "-h" ] || [ $1 == "--help" ]; then
    echo $USAGEMESSAGE
    exit 1
elif [ $# -eq 1 ]; then
    arg=$1
elif [ $# -eq 2 ]; then
    arg=$1
    DATASETS=$2
else
    echo "Error! You cannot provide more than two argument to the script!"
    echo $USAGEMESSAGE
    exit 2
fi
##

if [ -n "$DATASETS" ]; then
    MNISTDATA="--data_dir=$DATASETS/mnist/input_data"
fi
echo "Script: "$SCRIPTDIR
echo "MNIST: "$MNISTDATA

################################################

### Configure what to run ###
# for CPU:
#TFTest="/home/user/workspace/tf-benchmarks/benchmark_alexnet.py --data_format=NHWC"
# for GPU:
unset TFTest
idx=0
if [ "$arg" == "alexnet" ]  || [ "$arg" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_alexnet.py"
     let idx+=1
fi

if [ "$arg" == "googlenet" ] || [ "$arg" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_googlenet.py"
     let idx+=1
fi

if [ "$arg" == "overfeat" ] || [ "$arg" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_overfeat.py" 
     let idx+=1
fi

if [ "$arg" == "vgg" ] || [ "$arg" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/benchmark_vgg.py"
     let idx+=1
fi

if [ "$arg" == "mnist" ] || [ "$arg" == "all" ]; then
     TFTest[$idx]="$TFBenchmarks/mnist_deep.py $MNISTDATA"
     let idx+=1
fi

if [ ${#TFTest[0]} -le 5 ]; then 
    echo "Sorry! Did not recognize what you want to do!"
    echo $USAGEMESSAGE
    exit 3
fi

TFTestLen=${#TFTest[@]}

echo $INFOMESSAGE
pip install --user future
PyVers=$(python --version 2>&1)
TFVers=$(python $TFBenchmarks/tf_vers.py)
echo "=> Python version: $PyVers"
echo "=> Tensorflow version: $TFVers"

for (( i=0; i<${TFTestLen}; i++ ));
do
    echo "=> Execute: ${TFTest[$i]}"
    python ${TFTest[$i]}
done
