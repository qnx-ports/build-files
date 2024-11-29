ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

NAME = qt
QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)/../

# $(INSTALL_ROOT_$(OS)) is pointing to $QNX_TARGET by default,
# unless it was manually re-routed to a staging area by setting
# both INSTALL_ROOT_nto and USE_INSTALL_ROOT.
INSTALL_ROOT ?= $(INSTALL_ROOT_$(OS))

# A prefix path to use **on the target**. This is different
# from INSTALL_ROOT, which refers to an installation destination
# **on the host machine**. Default is /usr/local.
PREFIX ?= /usr/local

# Choose Release or Debug
CMAKE_BUILD_TYPE ?= Release

BUILD_EXAMPLES ?= OFF

BUILD_TESTING ?= OFF

#Search paths for all of CMake's find_* functions --
#headers, libraries, etc.
#
#$(QNX_TARGET): for architecture-agnostic files shipped with SDP (e.g. headers)
#$(QNX_TARGET)/$(CPUVARDIR): for architecture-specific files in SDP
#$(INSTALL_ROOT)/$(CPUVARDIR): any packages that may have been installed in the staging area
CMAKE_FIND_ROOT_PATH := $(QNX_TARGET);$(QNX_TARGET)/$(CPUVARDIR);$(INSTALL_ROOT)/$(CPUVARDIR)

#Path to CMake modules; These are CMake files installed by other packages
#for downstreams to discover them automatically. We support discovering
#CMake-based packages from inside SDP or in the staging area.
#Note that CMake modules can automatically detect the prefix they are
#installed in.
CMAKE_MODULE_PATH := $(QNX_TARGET)/$(CPUVARDIR)/$(PREFIX)/lib/cmake;$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)/lib/cmake


# Define dependencies and phony targets
ALL_DEPENDENCIES = qt_all
.PHONY: qt_all

include $(MKFILES_ROOT)/qtargets.mk

# Compilation flags
FLAGS += -D_QNX_SOURCE -funsafe-math-optimizations -w

# Set CMake configuration arguments
CMAKE_ARGS = -DCMAKE_TOOLCHAIN_FILE=$(PROJECT_ROOT)/qnx.nto.toolchain.cmake \
             -DCMAKE_INSTALL_PREFIX="$(PREFIX)" \
             -DCMAKE_STAGING_PREFIX="$(INSTALL_ROOT)/$(CPUVARDIR)/$(PREFIX)" \
             -DCPUVARDIR=$(CPUVARDIR) \
             -DCMAKE_BUILD_TYPE=$(CMAKE_BUILD_TYPE) \
             -DCMAKE_INSTALL_LIBDIR=$(INSTALL_ROOT)/usr/lib \
             -DCMAKE_INSTALL_INCLUDEDIR=$(INSTALL_ROOT)/usr \
             -DEXTRA_CMAKE_C_FLAGS="$(FLAGS)" \
             -DEXTRA_CMAKE_CXX_FLAGS="$(FLAGS)"  \
             -DQT_FEATURE_eglfs=OFF   \
             -DQT_FEATURE_brotli=OFF \
             -DQT_FEATURE_backtrace=OFF \
             -DQT_FEATURE_qqnx_pps=OFF   \
             -DBUILD_qtactiveqt=OFF   \
             -DBUILD_qtconnectivity=OFF   \
             -DBUILD_qtgrpc=OFF   \
             -DBUILD_qtlocation=OFF   \
             -DBUILD_qtmultimedia=OFF   \
             -DBUILD_qtopcua=OFF   \
             -DBUILD_qtpositioning=OFF   \
             -DBUILD_qtquick3dphysics=OFF   \
             -DBUILD_qtquickeffectmaker=OFF   \
             -DBUILD_qtremoteobjects=OFF   \
             -DBUILD_qtspeech=OFF   \
             -DBUILD_qtsensors=OFF   \
             -DBUILD_qtserialbus=OFF   \
             -DBUILD_qtserialport=OFF   \
             -DBUILD_qtvirtualkeyboard=OFF   \
             -DBUILD_qtwayland=OFF   \
             -DBUILD_qtwebengine=OFF   \
             -DBUILD_qtwebview=OFF   \
             -DQT_BUILD_EXAMPLES=$(BUILD_EXAMPLES) \
             -DQT_BUILD_TESTS=$(BUILD_TESTING) \
             -DBUILD_SHARED_LIBS=ON \
             -GNinja \
             -DQT_HOST_PATH=$(PROJECT_ROOT)/nto-aarch64-le/qthost \
             -DCMAKE_EXE_LINKER_FLAGS="-lsocket -lc++ -lm -lscreen" \
             -DQT_QMAKE_TARGET_MKSPEC=qnx-aarch64le-qcc \
             -Wno-dev   

MAKE_ARGS ?= -j $(firstword $(JLEVEL) 1)

ifneq ($(wildcard $(QNX_TARGET)/usr/include/execinfo.h),)
  FLAGS += -DQLOGGING_HAVE_BACKTRACE
  LDFLAGS += -lexecinfo
endif



ifndef NO_TARGET_OVERRIDE

# Build all modules
qt_all:
	cd qt5 && cmake $(CMAKE_ARGS) .
	cd qt5 && cmake --build . --parallel

install check: qt_all
	cd qt5 && cmake --install .

clean iclean spotless:
	cd qt5 && cmake --build . --target clean


endif


