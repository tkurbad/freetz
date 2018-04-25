$(call PKG_INIT_BIN, 3.2.11.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4e729f129d8f9b9abaed5121c3cd0037
$(PKG)_SITE:=http://surfnet.dl.sourceforge.net/sourceforge/motion

$(PKG)_BINARY:=$($(PKG)_DIR)/motion
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/motion

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MOTION_FFMPEG

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_OPTIONS += --host=mipsel-linux-uclibc
$(PKG)_CONFIGURE_OPTIONS += --target=mipsel-linux-uclibc
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --mandir=/usr/share/man
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/motion
$(PKG)_CONFIGURE_OPTIONS += --without-mysql
$(PKG)_CONFIGURE_OPTIONS += --without-pgsql
$(PKG)_CONFIGURE_OPTIONS += --without-optimizecpu

ifeq ($(strip $(FREETZ_PACKAGE_MOTION_FFMPEG)),y)
$(PKG)_DEPENDS_ON := ffmpeg
$(PKG)_CONFIGURE_OPTIONS += --with-ffmpeg=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
else
$(PKG)_CONFIGURE_OPTIONS += --without-ffmpeg
endif

$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"
$(PKG)_CONFIGURE_ENV += CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_CROSS)ar rcu"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_CROSS)ranlib"
$(PKG)_CONFIGURE_ENV += LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MOTION_DIR) \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(MOTION_DEST_DIR)/etc/motion
	install -m 644 $(MOTION_DIR)/motion-dist.conf $(MOTION_DEST_DIR)/etc/motion/motion.conf.example
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MOTION_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MOTION_DEST_DIR)/etc/motion
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
