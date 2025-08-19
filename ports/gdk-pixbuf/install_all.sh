#! /usr/bin/bash

DEP_NAME=(zlib libpng libjpeg-turbo glib)
DEP_NAME_SRC=(zlib libpng libjpeg-turbo glib)
DEP_CLONE_CMD=("git clone -b v1.3.1 https://github.com/madler/zlib.git"
               "git clone -b v1.6.46 https://github.com/pnggroup/libpng.git"
               "git clone -b 3.1.0 https://github.com/libjpeg-turbo/libjpeg-turbo.git"
               "git clone -b 2.83.4 https://gitlab.gnome.org/GNOME/glib.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

for NN in $(seq 0 ${DEP_COUNT}); do
    if ! ${DEP_CLONE_CMD[$NN]}; then
        echo "A git command just fail, but this maybe expected."
        echo "If the build process does not stop, you can ignore this error."
    fi

    if test -d "$(pwd)/${DEP_NAME_SRC[$NN]}"; then
        if chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh; then
            if ! ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh; then
                echo "install_all.sh: A recursive install_all.sh does exist for ${DEP_NAME[$NN]}, but it fails"
                exit 1; 
            fi
        fi


        if ! QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install; then
            echo "install_all.sh: Building ${DEP_NAME_SRC[$NN]} fails."
            exit 1; 
        fi
    else
        echo "install_all.sh: The source codes of "${DEP_NAME[$NN]}" are not cloned, abort."
        exit 1;
    fi
done