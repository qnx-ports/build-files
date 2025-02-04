The easiest way to create/update config.h is by running configure:

cd $SOME_EMPTY_LOCATION

CC=ntox86_64-gcc \
CXX=ntox86_64-g++ \
RANLIB=ntox86_64-ranlib \
AR=ntox86_64-ar \
meson setup --cross-file=/dev/null $WAYLAND_SOURCE \
    -Dlibraries=false \
    -Ddocumentation=false \
    -Ddtd_validation=false \
    --prefix=/dev/null

cp config.h $WAYLAND_SOURCE/../build/nto

Notes:
1) Requires meson > v56.0. Run 'python3 -m pip install meson --upgrade' if required.
2) The command will ultimately fail, but config.h and wayland-version.h should be generated
2) $WAYLAND_SOURCE is the location of the Wayland source.
3) The resulting config.h file should be architecture agnostic.
