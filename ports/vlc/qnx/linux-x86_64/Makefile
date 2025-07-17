# VLC's contribs system downloads a bunch of source archives to build.
# To make parallel builds work I need to ensure all those downloads
# happen before building actually starts.
#
# In addition, I a host version of protoc. The one that gets installed
# via packages is too new and will cause build failures later on down
# the line. So instead use the protobuf source from contrib to build
# a protoc with the same version as the protobuf code VLC will be using.

ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

include $(MKFILES_ROOT)/qmacros.mk

ALL_DEPENDENCIES = .fetched protoc
.PHONY: clean spotless
include $(MKFILES_ROOT)/qtargets.mk

QNX_PROJECT_ROOT ?= $(PRODUCT_ROOT)

# VLC's build process must be bootstrapped. This is
# target independent and mostly sets up the autoconf/automake
# build environment.
.bootstrap:
	@cd $(QNX_PROJECT_ROOT) && ./bootstrap
	@touch .bootstrap

# VLC's contrib build process must be bootstrapped. This
# is target dependent. Since we only do this to download
# packages and build a host version of protoc nothing special
# has to be done for the bootstrap.
contrib/Makefile: .bootstrap $(QNX_PROJECT_ROOT)/contrib/bootstrap
	@mkdir -p contrib
	@cd contrib && $(QNX_PROJECT_ROOT)/contrib/bootstrap

# Fetch all contrib packages.
# This will grab more than is required as the final set of packages
# to build gets constructed based on the target. However this is
# better than having each target-specific contrib download its own
# copy of the package or the potential concurrency problems that come
# from two targets trying to use the same package at the same time.
.fetched: contrib/Makefile
	@cd contrib && make fetch-all
	@touch .fetched

# Extract and prep the protobuf source tree.
# This will apply VLC's protobuf patches.
contrib/protobuf/Makefile.am: contrib/Makefile .fetched
	@cd contrib && make protobuf

# One of VLC's protobuf patches disables building protoc.
# We actually _want_ to build protoc, so back out that patch.
.protobuf-patched: contrib/protobuf/Makefile.am
	@cd contrib/protobuf && patch -p1 -R < $(QNX_PROJECT_ROOT)/contrib/src/protobuf/dont-build-protoc.patch
	@touch .protobuf-patched

# Build protoc
protoc: .protobuf-patched
	@cd contrib/protobuf && autoreconf -vif
	@cd contrib/protobuf && ./configure -prefix=`pwd`/install
	@cd contrib/protobuf/src && CFLAGS=$(CFLAGS) make protoc && make install
	@cp contrib/protobuf/install/bin/protoc protoc

# No install target for this as I don't actually want to install any of it
install:
	@echo Ignoring, nothing to install

vlc_host_clean:
	@rm -rf .fetched .bootstrap .protobuf-patched contrib protoc
clean: vlc_host_clean

vlc_host_spotless: vlc_host_clean
	@find $(QNX_PROJECT_ROOT)/contrib/tarballs -maxdepth 1 -type f ! -name '.gitignore' -exec rm -rf {} \;
spotless: vlc_host_spotless


