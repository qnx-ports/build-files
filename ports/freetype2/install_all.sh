DEP_NAME=(zlib brotli bzip2 libpng)
DEP_NAME_SRC=(zlib brotli bzip2 libpng)
DEP_CLONE_CMD=("git clone -b v1.3.1 https://github.com/madler/zlib.git"
               "git clone -b v1.1.0 https://github.com/google/brotli.git"
               "git clone -b bzip2-1.0.8 https://github.com/libarchive/bzip2.git"
               "git clone -b v1.6.46 https://github.com/pnggroup/libpng.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install
    fi
done