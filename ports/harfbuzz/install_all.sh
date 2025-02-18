DEP_NAME=(graphite icu glib freetype2 cairo)
DEP_NAME_SRC=(graphite icu glib freetype cairo)
DEP_CLONE_CMD=("git clone -b 1.3.14 https://github.com/silnrsi/graphite.git"
               "git clone -b release-76-1 https://github.com/unicode-org/icu.git"
               "git clone https://gitlab.gnome.org/GNOME/glib.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git"
               "git clone -b 1.18.2 https://gitlab.freedesktop.org/cairo/cairo.git")

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