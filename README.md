Tensorflow benchmark collection
====

# Tensorflow
Tested with 1.2.0, 1.3.0, 1.4.1, 1.5.0, 1.6.0, 1.7.0 TF versions.

# Benchmark files
## CNN 
#### convnet-benchmarks: 
(based on https://github.com/soumith/convnet-benchmarks/tree/master/tensorflow)
- benchmark_alexnet.py
- benchmark_googlenet.py
- benchmark_overfeat.py
- benchmark_vgg.py

Parameters:
```
--batch_size   Batch size 
--num_bathces  Number of batches to run
--data_format  The data format for Convnet operations. Can be either NHWC (CPU) or NCHW (default)
--csv_file     File to output script results and information
```

#### MNIST example: <br>
(based on: https://www.tensorflow.org/versions/r1.2/get_started/mnist/pros<br>
https://github.com/tensorflow/tensorflow/blob/r1.2/tensorflow/examples/tutorials/mnist/mnist_deep.py)
- mnist_deep.py

Parameters:
```
--data_dir       Directory with MNIST input data
--mnist_batch    Batch size
--mnist_steps    Number of steps to train
--csv_file       Same as for benchmark_xxx.py (see above)
```
MNIST database of handwritten digits: http://yann.lecun.com/exdb/mnist/

## tf-benchmarks.sh
Bash script to run either one or all benchmarks listed above, one after another. Same parameters as for individual benchmark files are accepted. For example:
```
$> ./tf-benchmarks.sh all --csv_file=benchmark_results.csv --batch_size=256 --mnist_batch=128
```
**N.B.** if `--csv_file` is specified, output of _all_ benchmarks is added to the same `.csv` file.

## Datasets
By default datasets are expected as subdirectories in `datasets` directory. 

For MNIST data this can however be re-defined with `--data_dir` setting (see above).

# Usage
## If you have TensorFlow installed, you can:
- execute each individual file
- use `tf-benchmarks.sh` shell script
- for an advanced logging you may have a look into `job_examples/job_bmetal.sh` 

## If you have no TensorFlow installed: use Docker containers!
To run a container you can use:
- docker (CPU only! root rights are required)
- nvidia-docker (root rights are required)
- singularity (installation requires root rights)
- udocker (no root privileges for installation or running)

#### Official TF Docker images
Official TensorFlow Docker images from https://hub.docker.com/r/tensorflow/tensorflow/tags/

Example how to use official TensorFlow images with `udocker`:
1. install udocker in your preferred directory:
```
$> curl https://raw.githubusercontent.com/mariojmdavid/udocker/devel/udocker.py > udocker
$> chmod u+rx ./udocker
$> ./udocker install 
```
2. look into `tools/udocker_pull_n_setup.sh` script and specify which TensorFlow you want to pull. The script will also create container and setup its execution mode. If --nvidia option is given, you need CUDA installed. Note the name of the created container. List of available containers is given by `udocker ps`

3. have a look into `job_examples/job_udocker.sh` to adjust e.g. where `tf-benchmarks` are installed (`$PROJECT/workspace/tf-benchmarks` by default). Run the script with the proper udocker container name (check with `udocker ps`).


# Dockerfiles
To build your own docker images, one needs `docker-ce` (e.g. https://docs.docker.com/install/linux/docker-ce/ubuntu/)

Dockerfiles here are based on https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker

## Dockerfile Versions
**Dockerfile.cpu**: CPU version based on Tensorflow for CPU (starts with FROM tensorflow/tensorflow:1.8.0)
**Dockerfile.gpu**: GPU version based on Tensorflow for GPU (starts with FROM tensorflow/tensorflow:1.8.0-gpu)

**Dockerfile-tf{141|150}-nv384.81.gpu**: GPU versions based on TF Dockerfile for GPU (CUDA{8|9} and CuDNN{6|7}). 
nvidia driver 384.81 is installed in the produced container(s). If a host machine has the same nvidia driver version (384.81), it allows to run containers on GPUs of such a host machine by means of e.g. singularity 2.2.1.

# Compiled docker images
e.g. https://hub.docker.com/r/vykozlov/tensorflow/tags/

