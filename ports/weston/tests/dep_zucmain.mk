ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

DIST_ROOT ?= $(PROJECT_ROOT)
INSTALLDIR = usr/bin/weston_tests

EXTRA_INCVPATH += $(DIST_ROOT)/tests
EXTRA_INCVPATH += $(DIST_ROOT)/tools/zunitc/inc
EXTRA_INCVPATH += $(DIST_ROOT)/include
EXTRA_INCVPATH += $(DIST_ROOT)
EXTRA_INCVPATH += $(PROJECT_ROOT)/../../$(OS)

EXTRA_SRCVPATH += $(DIST_ROOT)/tests

EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/zunitc/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/zunitcmain/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/so\1/')
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../libs/shared/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/a.shared\1/')

LIBS += zunitcmainS zunitcS sharedS 

USEFILE =

include $(MKFILES_ROOT)/qtargets.mk
