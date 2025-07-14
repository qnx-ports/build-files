ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

BUILDDIR = $(CURDIR)
SRC_ROOT = $(PROJECT_ROOT)/../../..

IS_DEBUG:=$(filter g, $(VARIANT_LIST))
IS_IOPKT:=$(filter iopkt, $(VARIANT_LIST))
IS_IOSOCK:=$(filter iosock, $(VARIANT_LIST))
IS_IOAUDIO:=$(filter ioaudio, $(VARIANT_LIST))
IS_IOSND:=$(filter iosnd, $(VARIANT_LIST))

ifeq ($(CPU),aarch64)
GN_GEN_ARGS += target_cpu="arm64"
else ifeq ($(CPU),x86_64)
GN_GEN_ARGS += target_cpu="x64"
endif
GN_GEN_ARGS += target_os="qnx" treat_warnings_as_errors=false
GN_GEN_ARGS += $(if $(IS_DEBUG),is_debug=true,is_debug=false)


ifeq ($(IS_IOSOCK),iosock)
EXTRA_PATH := ioscok
GN_GEN_ARGS += rtc_qnx_use_io_sock=true
else ifeq ($(IS_IOPKT),iopkt)
EXTRA_PATH := iopkt
GN_GEN_ARGS += rtc_qnx_use_io_sock=false
endif

ifeq ($(IS_IOSND),iosnd)
ifeq ($(EXTRA_PATH),)
EXTRA_PATH := iosnd/
else
EXTRA_PATH := ${EXTRA_PATH}_iosnd/
endif
GN_GEN_ARGS += rtc_qnx_use_io_snd=true
else ifeq ($(IS_IOAUDIO),ioaudio)
ifeq ($(EXTRA_PATH),)
EXTRA_PATH := ioaudio/
else
EXTRA_PATH := ${EXTRA_PATH}_ioaudio/
endif
GN_GEN_ARGS += rtc_qnx_use_io_snd=false
endif


WEBRTC_INSTALL_DIR=usr/lib

all: $(BUILDDIR)/args.gn
	cd $(SRC_ROOT);autoninja -C $(BUILDDIR) content_shell

$(BUILDDIR)/args.gn: $(BUILDDIR)
	cd $(SRC_ROOT);gn gen $(BUILDDIR) --args='$(GN_GEN_ARGS)'

clean:
	$(RM_HOST) -fr $(filter-out Makefile,$(wildcard *))

install: all
# TODO: yhodai
uninstall:
# TODO: yodai

hinstall:
