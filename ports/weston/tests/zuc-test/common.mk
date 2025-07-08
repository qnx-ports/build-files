EXTRA_SRCVPATH += $(DIST_ROOT)/tests
EXTRA_SRCVPATH += $(DIST_ROOT)/tools/zunitc/src
EXTRA_SRCVPATH += $(DIST_ROOT)/tools/zunitc/test

SRCS += fixtures_test.c zunitc_test.c

include ../../../../dep_zucmain.mk
