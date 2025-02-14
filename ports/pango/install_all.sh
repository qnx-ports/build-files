DEP_NAME=(fribidi gettext libthai glib freetype2 fontconfig cairo harfbuzz)
DEP_NAME_SRC=(fribidi gettext-0.23.1 libthai-0.1.29 glib freetype fontconfig cairo harfbuzz)
DEP_CLONE_CMD=(
               "git clone https://github.com/qnx-ports/fribidi.git"
               "echo skipped"
               "echo skipped"
               "git clone https://gitlab.gnome.org/GNOME/glib.git"
               "git clone -b VER-2-13-3 https://gitlab.freedesktop.org/freetype/freetype.git"
               "git clone -b 2.16.0 https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
               "git clone -b 1.18.2 https://gitlab.freedesktop.org/cairo/cairo.git"
               "git clone -b 10.2.0 https://github.com/harfbuzz/harfbuzz.git")

DEP_COUNT=${#DEP_NAME[@]}
DEP_COUNT=$(( DEP_COUNT - 1 ))

wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.23.1.tar.gz && tar -xf gettext-0.23.1.tar.gz
wget https://github.com/tlwg/libthai/releases/download/v0.1.29/libthai-0.1.29.tar.xz && tar -xf libthai-0.1.29.tar.xz

for NN in $(seq 0 ${DEP_COUNT}); do
    if ${DEP_CLONE_CMD[$NN]}; then
        chmod +x ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        ./build-files/ports/"${DEP_NAME[$NN]}"/install_all.sh
        QNX_PROJECT_ROOT="$(pwd)/${DEP_NAME_SRC[$NN]}" make -C "build-files/ports/${DEP_NAME[$NN]}/" install
    fi
done