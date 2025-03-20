rm -rf ${OUT}/hb-tests

mkdir ${OUT}/hb-tests
mkdir ${OUT}/hb-tests/api
mkdir ${OUT}/hb-tests/fuzzing
mkdir ${OUT}/hb-tests/subset
mkdir ${OUT}/hb-tests/threads
mkdir ${OUT}/hb-tests/threads/perf
mkdir ${OUT}/hb-tests/threads/test
mkdir ${OUT}/hb-tests/threads/test/shape
mkdir ${OUT}/hb-tests/threads/test/subset
mkdir ${OUT}/hb-tests/shape

cp -r ${BDIR}/test/api ${OUT}/hb-tests
cp -r ${BDIR}/test/fuzzing ${OUT}/hb-tests
cp -r ${BDIR}/test/subset ${OUT}/hb-tests
cp -r ${BDIR}/test/threads ${OUT}/hb-tests
cp -r ${SRC}/test/shape ${OUT}/hb-tests
cp -r ${SRC}/test/shape/data ${OUT}/hb-tests/threads/test/shape

rm -rf ${OUT}/hb-tests/api/*.p
rm -rf ${OUT}/hb-tests/fuzzing/*.p
rm -rf ${OUT}/hb-tests/subset/*.p
rm -rf ${OUT}/hb-tests/threads/*.p

cp -r ${SRC}/test/api/fonts ${OUT}/hb-tests/api
cp -r ${SRC}/test/api/results ${OUT}/hb-tests/api

cp -r ${SRC}/test/fuzzing/fonts ${OUT}/hb-tests/fuzzing
cp -r ${SRC}/test/fuzzing/graphs ${OUT}/hb-tests/fuzzing
cp -r ${SRC}/test/fuzzing/sets ${OUT}/hb-tests/fuzzing
cp -r ${SRC}/test/fuzzing/*.py ${OUT}/hb-tests/fuzzing

cp -r ${SRC}/test/subset/data ${OUT}/hb-tests/subset
cp -r ${SRC}/test/subset/data ${OUT}/hb-tests/threads/test/subset
cp -r ${SRC}/test/subset/*.py ${OUT}/hb-tests/subset

cp -r ${SRC}/perf/fonts ${OUT}/hb-tests/threads/perf
cp -r ${SRC}/perf/texts ${OUT}/hb-tests/threads/perf

# skipped iftb-requirement test, hb-subset on QNX does not support that
rm ${OUT}/hb-tests/subset/data/tests/iftb_requirements.tests

# copy testscripts
cp ./run_api_tests.sh ${OUT}/hb-tests/api
cp ./run_fuzzer_tests.sh ${OUT}/hb-tests/fuzzing
cp ./run_shape_tests.sh ${OUT}/hb-tests/shape
cp ./run_subset_tests.sh ${OUT}/hb-tests/subset
cp ./run_thread_tests.sh ${OUT}/hb-tests/threads
