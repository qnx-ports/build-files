DEP_NAME=(pixman freetype2 fontconfig glib)
DEP_NAME_SRC=(pixman freetype fontconfig glib)
DEP_CLONE_CMD=("git clone -b pixman-0.44.2 https://gitlab.freedesktop.org/pixman/pixman.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git"
               "git clone -b 2.16.0 https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
               "git clone https://gitlab.gnome.org/GNOME/glib.git")

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