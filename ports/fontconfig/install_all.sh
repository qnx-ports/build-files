DEP_NAME=(libexpat libiconv freetype)
DEP_NAME_SRC=(libexpat/expat libiconv-1.18 freetype)
DEP_CLONE_CMD=("git clone -b R_2_6_4 https://github.com/libexpat/libexpat.git"
               "echo"
               "git clone https://github.com/qnx-ports/freetype.git")

wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.18.tar.gz && tar -xf libiconv-1.18.tar.gz
DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        if ! QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install; then
            exit 1; 
        fi
    fi
done