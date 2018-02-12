Tensorflow benchmarks packed in a docker container(s)
====

- TOC
{:toc}

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

# Docker images
https://hub.docker.com/r/vykozlov/tf-benchmarks/tags/
