.PHONY: protocols

include $(WAYLAND_MKFILES_ROOT)wayland-rules.mk

protocols : $(PROTOCOL_SERVER_HDRS) $(PROTOCOL_CLIENT_HDRS) $(PROTOCOL_SRCS)
