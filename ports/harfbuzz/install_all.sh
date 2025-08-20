#! /usr/bin/bash


set -e

DEP_NAME=(graphite libiconv icu glib freetype cairo gettext-runtime)
DEP_NAME_SRC=(graphite libiconv-1.18 icu glib freetype cairo gettext-0.23.1)
DEP_CLONE_CMD=("git clone -b 1.3.14 https://github.com/silnrsi/graphite.git"
               "echo"
               "git clone -b release-76-1 https://github.com/unicode-org/icu.git"
               "git clone -b 2.84.3 https://gitlab.gnome.org/GNOME/glib.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git"
               "git clone -b 1.18.2 https://gitlab.freedesktop.org/cairo/cairo.git"
               "echo")

if ! test -f $(pwd)/libiconv-1.18.tar.gz; then
    wget https://ftpmirror.gnu.org/gnu/libiconv/libiconv-1.18.tar.gz
fi

if ! test -f $(pwd)/libiconv-1.18.tar.gz; then
    echo "install_all.sh: libiconv-1.18.tar.gz not fetched"
    exit 1;
fi

tar -xf libiconv-1.18.tar.gz

if ! test -f $(pwd)/gettext-0.23.1.tar.gz; then
    wget https://ftpmirror.gnu.org/gnu/gettext/gettext-0.23.1.tar.gz
fi

if ! test -f $(pwd)/gettext-0.23.1.tar.gz; then
    echo "install_all.sh: gettext-0.23.1.tar.gz not fetched"
    exit 1;
fi

tar -xf gettext-0.23.1.tar.gz

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
