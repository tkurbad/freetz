$(call PKG_INIT_BIN, 0.9.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://projects.unbit.it/downloads
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/uwsgi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/uwsgi
$(PKG)_SOURCE_MD5:=a15dc620e3c2821f278c7a334b6b9a3a

HOST_TOOLCHAIN_DIR:=$(FREETZ_BASE_DIR)/$(TOOLCHAIN_DIR)/host

$(PKG)_DEPENDS_ON:=python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	sed -e "s,^UGREEN=True,UGREEN=False," \
		-e "s|^GCC='gcc'|GCC='$(TARGET_CC)'|" \
		-e "s|^PYLIB_PATH.*=.*$$|PYLIB_PATH='$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib'|" \
		-e "s|^cflags.*=.*cflags.*sysconfig\.get_python_inc.*$$|cflags = cflags + ['-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/python2.6']|" \
		-i $(UWSGI_DIR)/uwsgiconfig.py
	$(SUBMAKE) -C $(UWSGI_DIR) all \
		CROSS_COMPILE=$(REAL_GNU_TARGET_NAME) \
		CC=$(TARGET_CC) \
		LDSHARED="$(TARGET_CC) -shared"  \
		PATH="$(HOST_TOOLCHAIN_DIR)/usr/bin:$(TARGET_TOOLCHAIN_STAGING_DIR)/bin:$(TARGET_PATH)" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib $(TARGET_LDFLAGS)" \
		CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include $(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include $(TARGET_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $(UWSGI_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(UWSGI_BINARY)
	$(RM) $(UWSGI_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(UWSGI_TARGET_BINARY)

$(PKG_FINISH)
