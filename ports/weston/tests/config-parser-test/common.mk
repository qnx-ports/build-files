TEST_NAME = custom-env
SRCS += config-parser-test.c
LIBS += socket wayland-server epoll

include ../../../../dep_zucmain.mk
