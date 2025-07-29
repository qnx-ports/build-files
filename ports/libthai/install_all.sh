#! /usr/bin/bash

DEP_NAME=(libdatrie)
DEP_NAME_SRC=(libdatrie-0.2.13)
DEP_CLONE_CMD=("echo")

wget https://github.com/tlwg/libdatrie/releases/download/v0.2.13/libdatrie-0.2.13.tar.xz && tar -xf libdatrie-0.2.13.tar.xz

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ! ${DEP_CLONE_CMD[$NN]}; then
        echo "A git command just fail, but it maybe expected."
        echo "If the build process does not stop, you can ignore this error."
    fi

    if test -d "$(pwd)/${DEP_NAME_SRC[$NN]}"; then
        if ! chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh; then
            echo "A recursive install_all.sh call fails, this maybe expected."
            echo "If the build process is successful at the end, it can be safely ignored."
        fi

        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        if ! QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install; then
            echo "install_all.sh build fails."
            exit 1; 
        fi
    else
        echo "The source codes of "${DEP_NAME[$NN]}" are not cloned, abort."
        exit 1;
    fi
done