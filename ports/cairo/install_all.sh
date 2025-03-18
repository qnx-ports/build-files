DEP_NAME=(pixman freetype fontconfig glib)
DEP_NAME_SRC=(pixman freetype fontconfig glib)
DEP_CLONE_CMD=("git clone https://github.com/qnx-ports/pixman.git"
               "git clone https://github.com/qnx-ports/freetype.git"
               "git clone https://github.com/qnx-ports/fontconfig.git"
               "git clone -b 2.83.4 https://gitlab.gnome.org/GNOME/glib.git")

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