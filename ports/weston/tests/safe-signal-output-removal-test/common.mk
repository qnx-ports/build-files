TEST_NAME = safe-signal-output-removal
EXTRA_SRCVPATH += $(DIST_ROOT)/shell-utils

SRCS += safe-signal-output-removal-test.c shell-utils.c

include ../../../../dep_test_client.mk
