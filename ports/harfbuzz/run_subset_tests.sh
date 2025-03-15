RESULT_PATH=tests.result
> ${RESULT_PATH}

python run-tests.py $1/hb-subset data/tests/* | tee -a ${RESULT_PATH}