WAYLAND_SCANNER_HOST = $(dir $(firstword $(wildcard \
    ../../../../wayland-scanner/$(HOST_OS)/$(notdir $(QNX_HOST))/o/wayland-scanner \
    $(if $(USE_INSTALL_ROOT),$(if $(INSTALL_ROOT_$(HOST_OS)),$(INSTALL_ROOT_$(HOST_OS))/usr/bin/wayland-scanner)) \
    $(QNX_HOST)/usr/bin/wayland-scanner \
)))wayland-scanner

.DELETE_ON_ERROR :
