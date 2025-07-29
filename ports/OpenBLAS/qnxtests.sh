#!/bin/sh

./openblas_utest
./openblas_utest_ext
sh openblas_ctests.sh
./dgemm_thread_safety
./dgemv_thread_safety
