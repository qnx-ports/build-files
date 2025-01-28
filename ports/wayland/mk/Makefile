ifndef QCONFIG
QCONFIG=qconfig.mk
endif
include $(QCONFIG)

all :

.PHONY : all clean hinstall huninstall install uninstall iclean

clean :

hinstall :
	$(CP_HOST) $(wildcard public/mk/*.mk) $(INSTALL_ROOT_nto)/usr/include/mk/

huninstall :
	$(RM_HOST) $(subst public,$(INSTALL_ROOT_nto)/usr/include,$(wildcard public/mk/*.mk))

install : hinstall

uninstall :

iclean :
