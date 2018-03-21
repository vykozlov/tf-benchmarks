Tensorflow benchmarks packed in a docker container(s)
====

# Tensorflow
Version(s): 1.4.1, 1.5.0

# Dockerfile
## Source
https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker

## Container Versions
**Dockerfile.cpu**: CPU version based on TF Dockerfile for CPU (starts with ubuntu:16.04)

**Dockerfile-tf{141|150}-nv384.81.gpu**: GPU versions based on TF Dockerfile for GPU (CUDA{8|9} and CuDNN{6|7}). 
nvidia driver 384.81 is installed in the produced container(s). If a host machine has the same nvidia driver version (384.81), it allows to run containers on GPUs of such a host machine by means of e.g. singularity 2.2.1.

# Benchmark files
convnet-benchmarks: https://github.com/soumith/convnet-benchmarks/tree/master/tensorflow

MNIST: <br>
https://www.tensorflow.org/versions/r1.2/get_started/mnist/pros<br>
https://github.com/tensorflow/tensorflow/blob/r1.2/tensorflow/examples/tutorials/mnist/mnist_deep.py

# Usage
To build a corresponding docker image, one needs docker-ce (e.g. https://docs.docker.com/install/linux/docker-ce/ubuntu/):
```
1. link 'Dockerfile' to the proper file (.cpu or .gpu)
2. $> docker build -t tf-benchmarks .
```


# Compiled docker images
https://hub.docker.com/r/vykozlov/tensorflow/tags/

To run CPU version, execute for example:
```
$> docker run -it vykozlov/tensorflow:tag
```
It is also possibe to use udocker (https://github.com/indigo-dc/udocker) (more advanced GPU support to come soon!):
```
$> udocker run vykozlov/tensorflow:tag
```

To run GPU version, one needs nvidia-docker (https://github.com/NVIDIA/nvidia-docker). Execute for example:
```
$> nvidia-docker run -it vykozlov/tf-benchmarks:latest-gpu
```
