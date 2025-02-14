DEP_NAME=(libexpat freetype2)
DEP_NAME_SRC=(libexpat freetype)
DEP_CLONE_CMD=("git clone -b R_2_6_4 https://github.com/libexpat/libexpat.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install
    fi
done