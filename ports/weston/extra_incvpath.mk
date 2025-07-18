EXTRA_INCVPATH += $(QNX_TARGET)/usr/local/include
EXTRA_INCVPATH += $(patsubst %/,%,$(wildcard $(QNX_TARGET)/usr/local/include/*/))