DEP_NAME=(zlib libpng libjpeg-turbo glib)
DEP_NAME_SRC=(zlib libpng libjpeg-turbo glib)
DEP_CLONE_CMD=("git clone -b v1.3.1 https://github.com/madler/zlib.git"
               "git clone -b v1.6.46 https://github.com/pnggroup/libpng.git"
               "git clone -b 3.1.0 https://github.com/libjpeg-turbo/libjpeg-turbo.git"
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