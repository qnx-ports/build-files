LIST=OS CPU VARIANT
ifndef QRECURSE
QRECURSE=recurse.mk
ifdef QCONFIG
QRDIR=$(dir $(QCONFIG))
endif
endif

AWS_DIR ?= ../../../aws-crt-cpp

QNX_BUILD_DIR = $(PWD)/build-files/ports/aws-crt-cpp

qnx_patch = cd $(AWS_DIR)/$1 && git apply --whitespace=nowarn $(QNX_BUILD_DIR)/patches/$2

$(shell $(call qnx_patch,/crt/aws-c-common,aws-c-common.patch))
$(shell $(call qnx_patch,/crt/aws-c-io,aws-c-io.patch))
$(shell $(call qnx_patch,/crt/s2n,s2n.patch))

include $(QRDIR)$(QRECURSE)

JLEVEL ?= $(subst -j,,$(filter -j%,$(MAKEFLAGS)))
