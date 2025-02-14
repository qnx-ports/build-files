DEP_NAME=(libdatrie)
DEP_NAME_SRC=(libdatrie-0.2.13)
DEP_CLONE_CMD=("wget https://github.com/tlwg/libdatrie/releases/download/v0.2.13/libdatrie-0.2.13.tar.xz && tar -xf libdatrie-0.2.13.tar.xz")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install
    fi
done