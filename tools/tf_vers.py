#!/usr/bin/python
import tensorflow as tf
print(tf.__version__)
print("=> Numpy info:")
import numpy.distutils.system_info as sysinfo
print(" atlas:")
sysinfo.get_info("atlas")
print(" mkl:")
sysinfo.get_info("mkl")
print(" blas:")
sysinfo.get_info("blas")
print(" openblas:")
sysinfo.get_info("openblas")
