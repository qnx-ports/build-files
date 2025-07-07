## Only build if there are the special io-sock folders (SPECIAL_IO_SOCK_FOLDERS)
include ../../sdp-finder.mk
ifeq ("$(SPECIAL_IO_SOCK_FOLDERS)", "no")
# Don't do anything for install
install:

clean:
	@rm -rf build
else
include ../../common.mk
endif

CMAKE_ARGS += -DCMAKE_SYSTEM_PROCESSOR=armv7le
EXT = v7
