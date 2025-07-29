ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

BUILDDIR = $(CURDIR)
SRC_ROOT = $(PROJECT_ROOT)/../../..

IS_DEBUG:=$(filter g, $(VARIANT_LIST))

ifeq ($(CPU),aarch64)
GN_GEN_ARGS += target_cpu="arm64"
else ifeq ($(CPU),x86_64)
GN_GEN_ARGS += target_cpu="x64"
endif
GN_GEN_ARGS += target_os="qnx" treat_warnings_as_errors=false
GN_GEN_ARGS += $(if $(IS_DEBUG),is_debug=true,is_debug=false)
GN_GEN_ARGS += use_remoteexec=false
GN_GEN_ARGS += pdf_use_skia=false
GN_GEN_ARGS += pdf_enable_fontations=false
GN_GEN_ARGS += pdf_enable_xfa=true
GN_GEN_ARGS += pdf_enable_v8=true
GN_GEN_ARGS += pdf_is_standalone=true

PDFIUM_INSTALL_DIR=usr/lib

all: $(BUILDDIR)/args.gn
	cd $(SRC_ROOT);autoninja -C $(BUILDDIR) pdfium_all

$(BUILDDIR)/args.gn: $(BUILDDIR)
	cd $(SRC_ROOT);gn gen $(BUILDDIR) --args='$(GN_GEN_ARGS)'

clean:
	$(RM_HOST) -fr $(filter-out Makefile,$(wildcard *))

install: all

uninstall:
