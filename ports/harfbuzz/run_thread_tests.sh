RESULT_PATH=tests.result
> ${RESULT_PATH}

for test in $(ls | grep hb-) ; do
        if [[ -x "./$test" ]]; then
                chmod +x ./$test
                echo "" | tee -a ${RESULT_PATH}
                echo "$test" | tee -a ${RESULT_PATH}
                ./$test | tee -a ${RESULT_PATH}
                echo $? | tee -a ${RESULT_PATH}
                echo "----------------------------" | tee -a ${RESULT_PATH}
        fi
done