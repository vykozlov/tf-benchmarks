FROM ubuntu:16.04

LABEL maintainer="Valentin Kozlov <valentin.kozlov@kit.edu>"
# Dockerfile based on the one for Tensorflow from Tensorflow
# https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/docker
# modified by Valentin Kozlov on 7-Feb-2018

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        Pillow \
        h5py \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        pandas \
        scipy \
        sklearn \
	future \
        && \
    python -m ipykernel.kernelspec

# --- DO NOT EDIT OR DELETE BETWEEN THE LINES --- #
# These lines will be edited automatically by parameterized_docker_build.sh. #
# COPY _PIP_FILE_ /
# RUN pip --no-cache-dir install /_PIP_FILE_
# RUN rm -f /_PIP_FILE_

# Install TensorFlow CPU version from central repo
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.5.0-cp27-none-linux_x86_64.whl
# --- ~ DO NOT EDIT OR DELETE BETWEEN THE LINES --- #

# Set the working directory to /benchmarks
WORKDIR /benchmarks

# Copy the current directory contents into the container at /benchmarks
ADD . /benchmarks

# Run app.py when the container launches
CMD ["python", "benchmark_alexnet_cpu.py"]
