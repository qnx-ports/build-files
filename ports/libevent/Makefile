# Entry point: builds the libevent version in the VERSION subdirectory
# (build files in <VERSION>/). Usage: make -C build-files/ports/libevent install JLEVEL=4
VERSION ?= 2.1.13

.DEFAULT_GOAL := all
.PHONY: all

all:
	$(MAKE) -C $(VERSION) all

%:
	$(MAKE) -C $(VERSION) $@
