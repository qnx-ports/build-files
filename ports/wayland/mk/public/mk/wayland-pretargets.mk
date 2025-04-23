PRE_TARGET += protocols
EXTRA_OBJS += $(addsuffix -protocol.o, $(PROTOCOLS))
EXTRA_CLEAN += $(if $(PROTOCOL_ROOT),$(PROTOCOL_ROOT)/*-protocol.c $(PROTOCOL_ROOT)/*-protocol.h)
