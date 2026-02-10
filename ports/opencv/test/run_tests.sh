#!/bin/sh

export OPENCV_TEST_DATA_PATH=$PWD/build/testdata
export OPENCV_SAMPLES_DATA_PATH=$PWD/build/sampledata

START_DIR=$PWD cucheck $@
