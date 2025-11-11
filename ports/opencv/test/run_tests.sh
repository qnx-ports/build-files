#!/bin/sh

export OPENCV_TEST_DATA_PATH=/system/share/testdata
export OPENCV_SAMPLES_DATA_PATH=/system/share/sampledata

START_DIR=$PWD cucheck $@
