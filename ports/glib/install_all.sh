DEP_NAME=(zlib pcre2 libffi)
DEP_NAME_SRC=(zlib pcre2 libffi)
DEP_CLONE_CMD=("git clone -b v1.3.1 https://github.com/madler/zlib.git"
               "git clone -b pcre2-10.45 https://github.com/PCRE2Project/pcre2.git"
               "git clone -b v3.2.1 https://github.com/libffi/libffi.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        ./build-files/ports/"${DEP_NAME}"/install_all.sh
        QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC}" make -C "build-files/ports/${DEP_NAME}/" install
    fi
done