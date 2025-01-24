#! /bin/bash

mkdir -p ${TEST_INSTALL_DIR}/test/testdata
mkdir -p ${TEST_INSTALL_DIR}/data/out
cp test/cintltst/cintltst ${TEST_INSTALL_DIR}
cp test/intltest/intltest ${TEST_INSTALL_DIR}
cp test/iotest/iotest ${TEST_INSTALL_DIR}
cp -r data/out/build ${TEST_INSTALL_DIR}/data/out
cp -r test/testdata/out ${TEST_INSTALL_DIR}/test/testdata
cp -r ${QNX_PROJECT_ROOT}/icu4c/source/test/testdata ${TEST_INSTALL_DIR}/test
cp -r ${QNX_PROJECT_ROOT}/icu4c/source/data ${TEST_INSTALL_DIR}