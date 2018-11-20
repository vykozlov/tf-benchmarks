from builtins import range
from collections import namedtuple
from datetime import datetime
import os
import math
import time

import tensorflow.python.platform
import tensorflow as tf
import tools.storeincsv as incsv

FLAGS = tf.app.flags.FLAGS

tf.app.flags.DEFINE_integer('batch_size', 128,
                            """Batch size.""")
tf.app.flags.DEFINE_integer('num_batches', 100,
                            """Number of batches to run.""")
tf.app.flags.DEFINE_float('gpu_fraction', 0.9,
                            """GPU Memory fraction to use 0..1. Default is 0.9.""")
tf.app.flags.DEFINE_boolean('forward_only', False,
                            """Only run the forward pass.""")
tf.app.flags.DEFINE_boolean('forward_backward_only', False,
                            """Only run the forward-forward pass.""")
tf.app.flags.DEFINE_string('data_format', 'NCHW',
                           """The data format for Convnet operations.
                           Can be either NHWC or NCHW.
                           """)
tf.app.flags.DEFINE_string('csv_file', '',
                           """File to output timing information to in csv
                           format. If not file is passed in, csv file will
                           not be cteated.
                           """)

parameters = []

conv_counter = 1
pool_counter = 1
affine_counter = 1

ParamHeader = ['Timestamp', 'Script', 'Info', 'Batch_size', 'Num_batches', 'Data_format', 'TotalTime', 'MeanPerBatch', 'StDev']
ParamEntry = namedtuple('ParamEntry', ParamHeader)

def _conv(inpOp, nIn, nOut, kH, kW, dH, dW, padType):
    global conv_counter
    global parameters
    name = 'conv' + str(conv_counter)
    conv_counter += 1
    with tf.name_scope(name) as scope:
        kernel = tf.Variable(tf.truncated_normal([kH, kW, nIn, nOut],
                                                 dtype=tf.float32,
                                                 stddev=1e-1), name='weights')
        if FLAGS.data_format == 'NCHW':
          strides = [1, 1, dH, dW]
        else:
          strides = [1, dH, dW, 1]
        conv = tf.nn.conv2d(inpOp, kernel, strides, padding=padType,
                            data_format=FLAGS.data_format)
        biases = tf.Variable(tf.constant(0.0, shape=[nOut], dtype=tf.float32),
                             trainable=True, name='biases')
        bias = tf.reshape(tf.nn.bias_add(conv, biases,
                                         data_format=FLAGS.data_format),
                          conv.get_shape())
        conv1 = tf.nn.relu(bias, name=scope)
        parameters += [kernel, biases]
        return conv1

def _affine(inpOp, nIn, nOut):
    global affine_counter
    global parameters
    name = 'affine' + str(affine_counter)
    affine_counter += 1
    with tf.name_scope(name) as scope:
        kernel = tf.Variable(tf.truncated_normal([nIn, nOut],
                                                 dtype=tf.float32,
                                                 stddev=1e-1), name='weights')
        biases = tf.Variable(tf.constant(0.0, shape=[nOut], dtype=tf.float32),
                             trainable=True, name='biases')
        affine1 = tf.nn.relu_layer(inpOp, kernel, biases, name=name)
        parameters += [kernel, biases]
        return affine1

def _mpool(inpOp, kH, kW, dH, dW):
    global pool_counter
    global parameters
    name = 'pool' + str(pool_counter)
    pool_counter += 1
    if FLAGS.data_format == 'NCHW':
      ksize = [1, 1, kH, kW]
      strides = [1, 1, dH, dW]
    else:
      ksize = [1, kH, kW, 1]
      strides = [1, dH, dW, 1]
    return tf.nn.max_pool(inpOp,
                          ksize=ksize,
                          strides=strides,
                          padding='VALID',
                          data_format=FLAGS.data_format,
                          name=name)

def loss(logits, labels):
    batch_size = tf.size(labels)
    labels = tf.expand_dims(labels, 1)
    indices = tf.expand_dims(tf.range(0, batch_size, 1), 1)
    concated = tf.concat([indices, labels], 1)
    onehot_labels = tf.sparse_to_dense(
        concated, tf.stack([batch_size, 1000]), 1.0, 0.0)
    cross_entropy = tf.nn.softmax_cross_entropy_with_logits(
        logits=logits, labels=onehot_labels, name='xentropy')
    loss = tf.reduce_mean(cross_entropy, name='xentropy_mean')
    return loss

def inference(images):
    conv1 = _conv (images, 3, 96, 11, 11, 4, 4, 'VALID')
    pool1 = _mpool(conv1,  2, 2, 2, 2)
    conv2 = _conv(pool1, 96, 256, 5, 5, 1, 1, 'VALID')
    pool2 = _mpool(conv2,  2, 2, 2, 2)
    conv3 = _conv (pool2,  256, 512, 3, 3, 1, 1, 'SAME')
    conv4 = _conv (conv3,  512, 1024, 3, 3, 1, 1, 'SAME')
    conv5 = _conv (conv4,  1024, 1024, 3, 3, 1, 1, 'SAME')
    pool5 = _mpool(conv5,  2, 2, 2, 2)
    resh1 = tf.reshape(pool5, [-1, 1024 * 6 * 6])
    affn1 = _affine(resh1, 1024 * 6 * 6, 3072)
    affn2 = _affine(affn1, 3072, 4096)
    affn3 = _affine(affn2, 4096, 1000)

    return affn3


def time_tensorflow_run(session, target, info_string):
  num_steps_burn_in = 10
  total_duration = 0.0
  total_duration_squared = 0.0
  
  for i in range(FLAGS.num_batches + num_steps_burn_in):
    start_time = time.time()
    _ = session.run(target)  #target_op = tf.group(*target)
    duration = time.time() - start_time
    if i > num_steps_burn_in:
      if not i % 10:
        print ('%s: step %d, duration = %.3f' %
               (datetime.now(), i - num_steps_burn_in, duration))
      total_duration += duration
      total_duration_squared += duration * duration
  mn = total_duration / FLAGS.num_batches
  vr = total_duration_squared / FLAGS.num_batches - mn * mn
  sd = math.sqrt(vr)
  print ('%s: %s (batch size: %d) across %d steps, %.3f +/- %.3f sec / batch' %
         (datetime.now(), info_string, FLAGS.batch_size, FLAGS.num_batches, mn, sd))
  return ParamEntry(datetime.now(), os.path.basename(__file__), info_string, 
                    FLAGS.batch_size, FLAGS.num_batches, FLAGS.data_format, 
                    total_duration, mn, sd)

def run_benchmark():
  global parameters
  param_entries = []
  param_entries.append(ParamHeader)
  
  with tf.Graph().as_default():
    # Generate some dummy images.
    image_size = 231
    # Note that our padding definition is slightly different the cuda-convnet.
    # In order to force the model to start with the same activations sizes,
    # we add 3 to the image_size and employ VALID padding above.
    if FLAGS.data_format == 'NCHW':
      image_shape = [FLAGS.batch_size, 3, image_size, image_size]
    else:
      image_shape = [FLAGS.batch_size, image_size, image_size, 3]
    images = tf.Variable(tf.random_normal(image_shape,
                                          dtype=tf.float32,
                                          stddev=1e-1))

    labels = tf.Variable(tf.ones([FLAGS.batch_size],
                                 dtype=tf.int32))

    # Build a Graph that computes the logits predictions from the
    # inference model.
    last_layer = inference(images)

    # Build an initialization operation.
    init = tf.global_variables_initializer()

    # Start running operations on the Graph.
    config = tf.ConfigProto()
    config.gpu_options.per_process_gpu_memory_fraction = FLAGS.gpu_fraction

    sess = tf.Session(config=config)
    sess.run(init)

    run_forward = True
    run_forward_backward = True
    if FLAGS.forward_only and FLAGS.forward_backward_only:
      raise ValueError("Cannot specify --forward_only and "
                       "--forward_backward_only at the same time.")
    if FLAGS.forward_only:
      run_forward_backward = False
    elif FLAGS.forward_backward_only:
      run_forward = False

    if run_forward:
      # Run the forward benchmark.
      param_entries.append(time_tensorflow_run(sess, last_layer, "Forward"))

    if run_forward_backward:
      # Add a simple objective so we can calculate the backward pass.
      objective = loss(last_layer, labels)
      # Compute the gradient with respect to all the parameters.
      grad = tf.gradients(objective, parameters)
      # Run the backward benchmark.
      param_entries.append(time_tensorflow_run(sess, grad, "Forward-backward"))

  if FLAGS.csv_file:
    incsv.store_data_in_csv(FLAGS.csv_file, param_entries)

def main(_):
  run_benchmark()

if __name__ == '__main__':
  tf.app.run()
