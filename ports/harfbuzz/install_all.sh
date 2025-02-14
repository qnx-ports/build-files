DEP_NAME=(graphite libiconv gettext-runtime icu glib freetype2 cairo)
DEP_NAME_SRC=(graphite libiconv-1.18 gettext-0.23.1 icu glib freetype cairo)
DEP_CLONE_CMD=("git clone -b 1.3.14 https://github.com/silnrsi/graphite.git"
               "echo"
               "echo"
               "git clone -b release-76-1 https://github.com/unicode-org/icu.git"
               "git clone https://gitlab.gnome.org/GNOME/glib.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git"
               "git clone -b 1.18.2 https://gitlab.freedesktop.org/cairo/cairo.git")

wget https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.18.tar.gz && tar -xf libiconv-1.18.tar.gz
wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.23.1.tar.gz && tar -xf gettext-0.23.1.tar.gz

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