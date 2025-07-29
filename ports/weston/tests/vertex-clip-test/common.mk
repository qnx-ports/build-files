TEST_NAME = vertex-clip
SRCS += vertex-clip-test.c


include ../../../../dep_test_client.mk

# gl-renderer is built as a dll, but this test is linked to it at compile time, so we need to
# add the colon so that ld will look for "gl-renderer.so" instead of "libgl-renderer.so"
LIBS += :gl-renderer.so
EXTRA_LIBVPATH += $(PROJECT_ROOT)/../../renderers/gl/$(OS)/$(CPU)/$(shell echo $(VARIANT1) | sed 's/^o\(.*\)$$/dll\1/')
