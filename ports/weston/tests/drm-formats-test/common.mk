EXTRA_INCVPATH += $(addsuffix /libdrm,$(USE_ROOT_INCLUDE))

TEST_NAME = drm-formats
SRCS += drm-formats-test.c

include ../../../../dep_test_client.mk
