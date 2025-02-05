defprotocolvpath:=

defprotocolvpath+=$(if $(USE_INSTALL_ROOT),$(INSTALL_ROOT_$(OS)),$(USE_ROOT_$(OS)))/usr/share/wayland-protocols
defprotocolvpath+=$(QNX_TARGET)/usr/share/wayland-protocols

ifndef PROTOCOL_ROOT
PROTOCOL_ROOT := $(PROJECT_ROOT)/$(OS)/protocol
endif

ifndef PROTOCOL_CODE_TYPE
PROTOCOL_CODE_TYPE = private-code
endif

ifndef PROTOCOL_HEADER_LIST
PROTOCOL_HEADER_LIST = client
endif

ifndef PROTOCOLVPATH
PROTOCOLVPATH:=$(defprotocolvpath)
endif

PROTOCOLVPATH+=$(EXTRA_PROTOCOLVPATH)

protocol_header_list = $(if $($(1)_HEADER_LIST), $($(1)_HEADER_LIST), $(PROTOCOL_HEADER_LIST))
protocol_header_name = $(if $(filter $2,$(call protocol_header_list,$(1))),$(PROTOCOL_ROOT)/$(1)-$2-protocol.h)

PROTOCOL_SERVER_HDRS = $(foreach protocol,$(PROTOCOLS),$(call protocol_header_name,$(protocol),server))
PROTOCOL_CLIENT_HDRS = $(foreach protocol,$(PROTOCOLS),$(call protocol_header_name,$(protocol),client))
PROTOCOL_SRCS = $(foreach protocol,$(PROTOCOLS),$(PROTOCOL_ROOT)/$(protocol)-protocol.c)
