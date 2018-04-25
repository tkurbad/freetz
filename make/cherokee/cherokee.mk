$(call PKG_INIT_BIN, 0.99.48)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.cherokee-project.com/download/0.99/$($(PKG)_VERSION)/
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/cherokee
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg)-$($(PKG)_VERSION)/sbin/cherokee
$(PKG)_SOURCE_MD5:=16f3769e99919648c82383281588ccb0

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CHEROKEE_FFMPEG
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CHEROKEE_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CHEROKEE_STATIC

$(PKG)_PREFIX := /$(pkg)-$($(PKG)_VERSION)/
$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += ac_cv_sizeof_sig_atomic_t=0
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CXX="$(TARGET_CXX)"
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_CROSS)ar"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_CROSS)ranlib"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += CPPFLAGS="-I. -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += LDFLAGS="-L./ -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --build=$(REAL_GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --target=$(REAL_GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --prefix=$(CHEROKEE_PREFIX)
$(PKG)_CONFIGURE_OPTIONS += --enable-beta
$(PKG)_CONFIGURE_OPTIONS += --enable-os-string="Freetz"
$(PKG)_CONFIGURE_OPTIONS += --enable-static-module=all
$(PKG)_CONFIGURE_OPTIONS += --disable-admin
$(PKG)_CONFIGURE_OPTIONS += --disable-readdir_r
$(PKG)_CONFIGURE_OPTIONS += --without-geoip
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-mysql
$(PKG)_CONFIGURE_OPTIONS += --with-wwwuser=wwwrun
$(PKG)_CONFIGURE_OPTIONS += --with-wwwgroup=wwwrun
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CHEROKEE_STATIC),--enable-static --enable-shared=no,--enable-shared --enable-static=no)

$(PKG)_DEPENDS_ON:=

ifeq ($(strip $(FREETZ_PACKAGE_CHEROKEE_FFMPEG)),y)
$(PKG)_DEPENDS_ON += ffmpeg
$(PKG)_CONFIGURE_OPTIONS += --with-ffmpeg
endif
ifeq ($(strip $(FREETZ_PACKAGE_CHEROKEE_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-libssl
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(cd $(CHEROKEE_DIR); \
		sed -i "/HAVE_READDIR/ d" config.h; \
	)
	$(SUBMAKE) -C $(CHEROKEE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(CHEROKEE_DIR) install \
		DESTDIR="$(FREETZ_BASE_DIR)/$(CHEROKEE_TARGET_DIR)"
	$(INSTALL_BINARY_STRIP)
	(cd $(FREETZ_BASE_DIR)/$(CHEROKEE_TARGET_DIR)/$(CHEROKEE_PREFIX); \
		$(TARGET_STRIP) bin/cget bin/cherokee-tweak \
		sbin/cherokee-admin sbin/cherokee-worker \
		lib/*.a; \
	)

$(pkg):

$(pkg)-precompiled: $(CHEROKEE_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CHEROKEE_DIR) clean
	$(RM) $(CHEROKEE_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(CHEROKEE_TARGET_BINARY)

$(PKG_FINISH)
