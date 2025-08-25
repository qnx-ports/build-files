# Simplified common.mk for Samba - bypassing QNX build system conflicts

# Set default values if not provided by environment
# Handle relative paths - if QNX_PROJECT_ROOT is "dist", make it relative to project root
ifeq ($(QNX_PROJECT_ROOT),dist)
    QNX_PROJECT_ROOT := ../../../dist
else
    QNX_PROJECT_ROOT ?= ../../../dist
endif
QNX_TARGET ?= /home/ubuntu/qnx800/target/qnx
CPU ?= x86_64
CPUVARDIR ?= x86_64
PREFIX ?= /usr/local

# Install destination - where files will be placed
INSTALL_ROOT ?= $(QNX_TARGET)
DESTDIR = $(INSTALL_ROOT)/$(CPUVARDIR)

# Override all targets to use our custom build
ALL_DEPENDENCIES = samba_all
.PHONY: samba_all all install check clean iclean spotless uninstall

# Library search paths for QNX
LIBRARY_PATH_OPTS = -L$(QNX_TARGET)/$(CPUVARDIR)/usr/lib \
                   -L$(QNX_TARGET)/$(CPUVARDIR)/usr/local/lib \
                   -L$(QNX_TARGET)/usr/lib

# Samba-specific LDFLAGS
SMB_LDFLAGS = $(LIBRARY_PATH_OPTS) -lsocket -lcrypto -lnettle -lhogweed -lgmp -lregex -lfsnotify -Wl,--build-id=md5

# Samba-specific CFLAGS  
SMB_CFLAGS = -I$(QNX_TARGET)/usr/include \
             -I$(QNX_TARGET)/$(CPUVARDIR)/usr/include \
             -D__QNXNTO__ \
             -D__USESRCVERSION

# Samba configure options
CROSS_ANSWERS_FILE = $(shell realpath config/x_config_answers.txt)
SAMBA_OPTIONS = --without-ldb-lmdb --without-winbind --without-ads --without-pam \
               --without-quotas --without-dmapi --without-regedit --disable-glusterfs \
               --disable-cephfs --disable-spotlight --without-systemd --without-lttng \
               --without-ad-dc --fatal-errors --without-libarchive --without-ntvfs-fileserver \
               --disable-python --without-json --disable-rpath --without-ldap --with-gpfs=no \
               --cross-compile --enable-fhs \
               --hostcc=gcc \
               --cross-answers=$(CROSS_ANSWERS_FILE) \
               --prefix=$(PREFIX)

# PKG_CONFIG setup for QNX
PKG_CONFIG_PATH = $(QNX_TARGET)/$(CPUVARDIR)/usr/lib/pkgconfig

# Find waf executable
WAF_CMD = $(shell if [ -f $(QNX_PROJECT_ROOT)/waf ]; then echo "./waf"; elif [ -f $(QNX_PROJECT_ROOT)/buildtools/bin/waf ]; then echo "./buildtools/bin/waf"; elif which waf >/dev/null 2>&1; then echo "waf"; else echo "./waf"; fi)

# Default target
all: samba_all

samba_all:
	@echo "=== Configuring Samba for QNX ==="
	@echo "QNX_PROJECT_ROOT: $(QNX_PROJECT_ROOT)"
	@echo "DESTDIR: $(DESTDIR)"
	@echo "PREFIX: $(PREFIX)"
	@echo "WAF_CMD: $(WAF_CMD)"
	@echo "CROSS_ANSWERS_FILE: $(CROSS_ANSWERS_FILE)"
	@if [ ! -f "$(QNX_PROJECT_ROOT)/waf" ] && [ ! -f "$(QNX_PROJECT_ROOT)/buildtools/bin/waf" ]; then \
		echo "ERROR: waf not found in $(QNX_PROJECT_ROOT)"; \
		echo "Available files:"; \
		ls -la $(QNX_PROJECT_ROOT)/; \
		exit 1; \
	fi
	@cd $(QNX_PROJECT_ROOT) && \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	CC=nto$(CPU)-gcc \
	LDFLAGS="$(SMB_LDFLAGS)" \
	CFLAGS="$(SMB_CFLAGS)" \
	$(WAF_CMD) configure $(SAMBA_OPTIONS)
	@echo "=== Building Samba ==="
	@cd $(QNX_PROJECT_ROOT) && \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	CC=nto$(CPU)-gcc \
	LDFLAGS="$(SMB_LDFLAGS)" \
	CFLAGS="$(SMB_CFLAGS)" \
	$(WAF_CMD) build

install check: samba_all
	@echo "=== Installing Samba to $(DESTDIR) ==="
	@cd $(QNX_PROJECT_ROOT) && \
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) \
	CC=nto$(CPU)-gcc \
	LDFLAGS="$(SMB_LDFLAGS)" \
	CFLAGS="$(SMB_CFLAGS)" \
	DESTDIR="$(DESTDIR)" \
	$(WAF_CMD) install
	@echo "=== Samba installation complete ==="

clean iclean spotless:
	@echo "=== Cleaning Samba ==="
	@cd $(QNX_PROJECT_ROOT) && $(WAF_CMD) clean || true
	@cd $(QNX_PROJECT_ROOT) && $(WAF_CMD) distclean || true

uninstall:
	@echo "Uninstall not implemented for Samba"