Tensorflow benchmarks packed in a docker container(s)
====

# Tensorflow
Version: 1.5.0

# Dockerfile
## Source
https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker

## Container Branches
**build-cpu**: CPU version based on TF Dockerfile for CPU (starts with ubuntu:16.04)

**build-gpu**: GPU version based on TF Dockerfile for GPU (starts with nvidia/cuda:9.0-cudnn7-runtime-ubuntu16.04)

# Benchmark files
convnet-benchmarks: https://github.com/soumith/convnet-benchmarks/tree/master/tensorflow

MNIST: <br>
https://www.tensorflow.org/versions/r1.2/get_started/mnist/pros<br>
https://github.com/tensorflow/tensorflow/blob/r1.2/tensorflow/examples/tutorials/mnist/mnist_deep.py

# Usage
To build a corresponding docker image, one needs docker-ce (e.g. https://docs.docker.com/install/linux/docker-ce/ubuntu/):
```
$> cd build-cpu # or build-gpu
$> docker build -t tf-benchmarks .
```

To run GPU version, one needs nvidia-docker (https://github.com/NVIDIA/nvidia-docker)

# Compiled docker images
https://hub.docker.com/r/vykozlov/tf-benchmarks/tags/

To run CPU version, execute for example:
```
docker run -it vykozlov/tf-benchmarks:latest
```
It is also possibe to use udocker (https://github.com/indigo-dc/udocker):
```
udocker run vykozlov/tf-benchmarks:latest
```

To run GPU version, execute for example:
```
nvidia-docker run -it vykozlov/tf-benchmarks:latest-gpu
```
