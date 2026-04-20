#!/usr/bin/bash

set -e

DEP_NAME=(muslflt googletest benchmark abseil-cpp re2 protobuf date json gsl flatbuffers eigen3)
DEP_CLONE_CMD=("git clone https://github.com/qnx-ports/muslflt.git"
               "git clone -b qnx_v1.14.0 https://github.com/qnx-ports/googletest.git"
               "git clone -b qnx_v1.8.3 https://github.com/qnx-ports/benchmark.git"
               "git clone -b qnx_20250814.1 https://github.com/qnx-ports/abseil-cpp.git"
               "git clone -b qnx_main https://github.com/qnx-ports/re2.git"
               "git clone -b qnx-v21.12 https://github.com/qnx-ports/protobuf.git"
               "git clone -b v3.0.4 https://github.com/HowardHinnant/date.git"
               "git clone -b v3.12.0 https://github.com/nlohmann/json.git"
               "git clone -b v4.2.1 https://github.com/microsoft/GSL.git"
               "git clone -b qnx-v23.5.26 https://github.com/qnx-ports/flatbuffers.git"
               "git clone -b qnx_v3.4.1 https://github.com/qnx-ports/eigen3.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
  if ! test -d "$(pwd)/${DEP_NAME[$NN]}"; then
    if ! ${DEP_CLONE_CMD[$NN]}; then
      echo "${DEP_CLONE_CMD[$NN]} dependency could not be cloned, aborting..."
      exit 1
    fi
  fi

  if ! QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}" install; then
    echo "onnxruntime build failed due to ${DEP_NAME[$NN]} dependency build failure."
    exit 1
  fi
done
