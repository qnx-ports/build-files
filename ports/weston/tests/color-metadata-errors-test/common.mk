EXTRA_INCVPATH += $(DIST_ROOT)/compositor

LIBS += memstream

TEST_NAME = color-metadata-errors
SRCS += color-metadata-errors-test.c

include ../../../../dep_test_client.mk
