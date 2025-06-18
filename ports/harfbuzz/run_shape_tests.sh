RESULT_PATH=tests.result
> ${RESULT_PATH}

python run-tests.py $1/hb-shape data/aots/tests/* | tee -a ${RESULT_PATH}
python run-tests.py $1/hb-shape data/in-house/tests/* | tee -a ${RESULT_PATH}
python run-tests.py $1/hb-shape data/text-rendering-tests/tests/* | tee -a ${RESULT_PATH}