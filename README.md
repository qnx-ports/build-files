# Build Files for QNX Ports

This repository provides QNX-specific build files required to build various ports and projects.

**Each QNX port has its own sub-directory under the `ports/` directory.**

**For build instructions, refer to the `README.md` file located in the sub-directory of the specific port.**

Some open-source projects build without requiring modifications, so they don’t have a dedicated fork at https://github.com/qnx-ports/.

## Building the Ports

You have two options for building the ports:

1. **Docker-based Build:**
   For a consistent and reproducible build environment, we highly recommend using the prepared Docker image.
   Detailed instructions can be found in [`docker/README.md`](docker/README.md).

2. **Host Build:**
   You can build ports directly on your host system.

## Port Status

Click on a port below to navigate to its `README.md` for build and test instructions.

| Port | Status |
|----------|--------|
| [ComputeLibrary](https://github.com/qnx-ports/build-files/blob/main/ports/ComputeLibrary/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ComputeLibrary.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ComputeLibrary.yml) |
| [Fast-CDR](https://github.com/qnx-ports/build-files/blob/main/ports/Fast-CDR/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/Fast-CDR.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/Fast-CDR.yml) |
| [Fast-DDS](https://github.com/qnx-ports/build-files/blob/main/ports/Fast-DDS/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/Fast-DDS.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/Fast-DDS.yml) |
| [OpenBLAS](https://github.com/qnx-ports/build-files/blob/main/ports/OpenBLAS/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/OpenBLAS.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/OpenBLAS.yml) |
| [abseil-cpp](https://github.com/qnx-ports/build-files/blob/main/ports/abseil-cpp/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/abseil-cpp.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/abseil-cpp.yml) |
| [asio](https://github.com/qnx-ports/build-files/blob/main/ports/asio/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/asio.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/asio.yml) |
| [azure-iot-sdk-c](https://github.com/qnx-ports/build-files/blob/main/ports/azure-iot-sdk-c/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/azure-iot-sdk-c.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/azure-iot-sdk-c.yml) |
| [bash](https://github.com/qnx-ports/build-files/blob/main/ports/bash/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/bash.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/bash.yml) |
| [benchmark](https://github.com/qnx-ports/build-files/blob/main/ports/benchmark/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/benchmark.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/benchmark.yml) |
| [boost](https://github.com/qnx-ports/build-files/blob/main/ports/boost/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/boost.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/boost.yml) |
| [brotli](https://github.com/qnx-ports/build-files/blob/main/ports/brotli/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/brotli.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/brotli.yml) |
| [bzip2](https://github.com/qnx-ports/build-files/blob/main/ports/bzip2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/bzip2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/bzip2.yml) |
| [CANdb](https://github.com/qnx-ports/build-files/blob/main/ports/CANdb/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/CANdb.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/CANdb.yml) |
| [Catch2](https://github.com/qnx-ports/build-files/blob/main/ports/Catch2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/Catch2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/Catch2.yml) |
| [cJSON](https://github.com/qnx-ports/build-files/blob/main/ports/cJSON/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/cJSON.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/cJSON.yml) |
| [c-ares](https://github.com/qnx-ports/build-files/blob/main/ports/c-ares/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/c-ares.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/c-ares.yml) |
| [cairo](https://github.com/qnx-ports/build-files/blob/main/ports/cairo/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/cairo.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/cairo.yml) |
| [capnproto](https://github.com/qnx-ports/build-files/blob/main/ports/capnproto/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/capnproto.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/capnproto.yml) |
| [clapack](https://github.com/qnx-ports/build-files/blob/main/ports/clapack/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/clapack.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/clapack.yml) |
| [cpuinfo](https://github.com/qnx-ports/build-files/blob/main/ports/cpuinfo/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/cpuinfo.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/cpuinfo.yml) |
| [csmith](https://github.com/qnx-ports/build-files/blob/main/ports/csmith/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/csmith.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/csmith.yml) |
| [dlt-daemon](https://github.com/qnx-ports/build-files/blob/main/ports/dlt-daemon/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/dlt-daemon.yml) |
| [eigen](https://github.com/qnx-ports/build-files/blob/main/ports/eigen/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/eigen.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/eigen.yml) |
| [epoll](https://github.com/qnx-ports/build-files/blob/main/ports/epoll/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/epoll.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/epoll.yml) |
| [farmhash](https://github.com/qnx-ports/build-files/blob/main/ports/farmhash/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/farmhash.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/farmhash.yml) |
| [fontconfig](https://github.com/qnx-ports/build-files/blob/main/ports/fontconfig/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/fontconfig.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/fontconfig.yml) |
| [FreeImage](https://github.com/qnx-ports/build-files/blob/main/ports/FreeImage/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/FreeImage.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/FreeImage.yml) |
| [freetype](https://github.com/qnx-ports/build-files/blob/main/ports/freetype/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/freetype.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/freetype.yml) |
| [fribidi](https://github.com/qnx-ports/build-files/blob/main/ports/fribidi/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/fribidi.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/fribidi.yml) |
| [gdk-pixbuf](https://github.com/qnx-ports/build-files/blob/main/ports/gdk-pixbuf/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gdk-pixbuf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gdk-pixbuf.yml) |
| [gettext-runtime](https://github.com/qnx-ports/build-files/blob/main/ports/gettext-runtime/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gettext-runtime.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gettext-runtime.yml) |
| [gflags](https://github.com/qnx-ports/build-files/blob/main/ports/gflags/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gflags.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gflags.yml) |
| [glib](https://github.com/qnx-ports/build-files/blob/main/ports/glib/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/glib.yml) |
| [glog](https://github.com/qnx-ports/build-files/blob/main/ports/glog/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/glog.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/glog.yml) |
| [googletest](https://github.com/qnx-ports/build-files/blob/main/ports/googletest/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/googletest.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/googletest.yml) |
| [graphene](https://github.com/qnx-ports/build-files/blob/main/ports/graphene/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/graphene.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/graphene.yml) |
| [graphite](https://github.com/qnx-ports/build-files/blob/main/ports/graphite/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/graphite.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/graphite.yml) |
| [grpc](https://github.com/qnx-ports/build-files/blob/main/ports/grpc/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/grpc.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/grpc.yml) |
| [gtk](https://github.com/qnx-ports/build-files/blob/main/ports/gtk/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gtk.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gtk.yml) |
| [gtsam](https://github.com/qnx-ports/build-files/blob/main/ports/gtsam/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/gtsam.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/gtsam.yml) |
| [harfbuzz](https://github.com/qnx-ports/build-files/blob/main/ports/harfbuzz/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/harfbuzz.yml) |
| [icu](https://github.com/qnx-ports/build-files/blob/main/ports/icu/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/icu.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/icu.yml) |
| [jansson](https://github.com/qnx-ports/build-files/blob/main/ports/jansson/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/jansson.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/jansson.yml) |
| [lely-core](https://github.com/qnx-ports/build-files/blob/main/ports/lely-core/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lely-core.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lely-core.yml) |
| [libdatrie](https://github.com/qnx-ports/build-files/blob/main/ports/libdatrie/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libdatrie.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libdatrie.yml) |
| [libev](https://github.com/qnx-ports/build-files/blob/main/ports/libev/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libev.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libev.yml) |
| [libexpat](https://github.com/qnx-ports/build-files/blob/main/ports/libexpat/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libexpat.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libexpat.yml) |
| [libffi](https://github.com/qnx-ports/build-files/blob/main/ports/libffi/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libffi.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libffi.yml) |
| [libiconv](https://github.com/qnx-ports/build-files/blob/main/ports/libiconv/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libiconv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libiconv.yml) |
| [libjpeg-turbo](https://github.com/qnx-ports/build-files/blob/main/ports/libjpeg-turbo/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libjpeg-turbo.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libjpeg-turbo.yml) |
| [libjson](https://github.com/qnx-ports/build-files/blob/main/ports/libjson/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libjson.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libjson.yml) |
| [libpng](https://github.com/qnx-ports/build-files/blob/main/ports/libpng/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libpng.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libpng.yml) |
| [libthai](https://github.com/qnx-ports/build-files/blob/main/ports/libthai/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libthai.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libthai.yml) |
| [libuv](https://github.com/qnx-ports/build-files/blob/main/ports/libuv/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libuv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libuv.yml) |
| [libxml2](https://github.com/qnx-ports/build-files/blob/main/ports/libxml2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libxml2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libxml2.yml) |
| [libyuv](https://github.com/qnx-ports/build-files/blob/main/ports/libyuv/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libyuv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libyuv.yml) |
| [libxkbcommon](https://github.com/qnx-ports/build-files/blob/main/ports/libxkbcommon/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libxkbcommon.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libxkbcommon.yml) |
| [libzmq](https://github.com/qnx-ports/build-files/blob/main/ports/libzmq/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/libzmq.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/libzmq.yml) |
| [lighttpd1.4](https://github.com/qnx-ports/build-files/blob/main/ports/lighttpd1.4/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/lighttpd1.4.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/lighttpd1.4.yml) |
| [memory](https://github.com/qnx-ports/build-files/blob/main/ports/memory/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/memory.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/memory.yml) |
| [METIS](https://github.com/qnx-ports/build-files/blob/main/ports/METIS/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/METIS.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/METIS.yml) |
| [mosquitto](https://github.com/qnx-ports/build-files/blob/main/ports/mosquitto/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/mosquitto.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/mosquitto.yml) |
| [muslflt](https://github.com/qnx-ports/build-files/blob/main/ports/muslflt/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/muslflt.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/muslflt.yml) |
| [nanosvg](https://github.com/qnx-ports/build-files/blob/main/ports/nanosvg/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/nanosvg.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/nanosvg.yml) |
| [nghttp2](https://github.com/qnx-ports/build-files/blob/main/ports/nghttp2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/nghttp2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/nghttp2.yml) |
| [numpy](https://github.com/qnx-ports/build-files/blob/main/ports/numpy/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/numpy.yml) |
| [opencv](https://github.com/qnx-ports/build-files/blob/main/ports/opencv/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/opencv.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/opencv.yml) |
| [pandas](https://github.com/qnx-ports/build-files/blob/main/ports/pandas/README.md) | |
| [pcre2](https://github.com/qnx-ports/build-files/blob/main/ports/pcre2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pcre2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pcre2.yml) |
| [perl5](https://github.com/qnx-ports/build-files/blob/main/ports/perl5/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/perl5.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/perl5.yml) |
| [pixman](https://github.com/qnx-ports/build-files/blob/main/ports/pixman/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pixman.yml) |
| [protobuf](https://github.com/qnx-ports/build-files/blob/main/ports/protobuf/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/protobuf.yml) |
| [pugixml](https://github.com/qnx-ports/build-files/blob/main/ports/pugixml/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pugixml.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pugixml.yml) |
| [pytorch](https://github.com/qnx-ports/build-files/blob/main/ports/pytorch/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/pytorch.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/pytorch.yml) |
| [qt](https://github.com/qnx-ports/build-files/blob/main/ports/qt/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/qt.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/qt.yml) |
| [rapidjson](https://github.com/qnx-ports/build-files/blob/main/ports/rapidjson/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/rapidjson.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/rapidjson.yml) |
| [restbed](https://github.com/qnx-ports/build-files/blob/main/ports/restbed/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/restbed.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/restbed.yml) |
| [re2](https://github.com/qnx-ports/build-files/blob/main/ports/re2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/re2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/re2.yml) |
| [ros2](https://github.com/qnx-ports/build-files/blob/main/ports/ros2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ros2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ros2.yml) |
| [rust](https://github.com/qnx-ports/build-files/blob/main/ports/rust/README.md) | |
| [ruy](https://github.com/qnx-ports/build-files/blob/main/ports/ruy/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/ruy.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/ruy.yml) |
| [sqlite](https://github.com/qnx-ports/build-files/blob/main/ports/sqlite/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/sqlite.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sqlite.yml)|
| [sqlite_orm](https://github.com/qnx-ports/build-files/blob/main/ports/sqlite_orm/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/sqlite_orm.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/sqlite_orm.yml)|
| [tensorflow](https://github.com/qnx-ports/build-files/blob/main/ports/tensorflow/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/tensorflow.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/tensorflow.yml) |
| [tftp-hpa](https://github.com/qnx-ports/build-files/blob/main/ports/tftp-hpa/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/tftp-hpa.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/tftp-hpa.yml) |
| [tinyxml2](https://github.com/qnx-ports/build-files/blob/main/ports/tinyxml2/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/tinyxml2.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/tinyxml2.yml) |
| [vim](https://github.com/qnx-ports/build-files/blob/main/ports/vim/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/vim.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/vim.yml) |
| [vsomeip](https://github.com/qnx-ports/build-files/blob/main/ports/vsomeip/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/vsomeip.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/vsomeip.yml) |
| [zlib](https://github.com/qnx-ports/build-files/blob/main/ports/zlib/README.md) | [![Build](https://github.com/qnx-ports/build-files/actions/workflows/zlib.yml/badge.svg)](https://github.com/qnx-ports/build-files/actions/workflows/zlib.yml) |
---

