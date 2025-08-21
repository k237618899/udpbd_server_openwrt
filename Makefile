include $(TOPDIR)/rules.mk

PKG_NAME:=udpbd-server
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/udpbd-server
	SECTION:=net
	CATEGORY:=Network
	TITLE:=UDP Block Device Server
	DEPENDS:=+libstdcpp
endef

define Package/udpbd-server/description
	UDP Block Device (UDPBD) server for providing block device access
	over UDP network protocol. Useful for remote storage access and
	network block device functionality.
endef

define Build/Configure
endef

define Build/Compile
	$(TARGET_CXX) $(TARGET_CXXFLAGS) $(TARGET_CPPFLAGS) \
		-I$(PKG_BUILD_DIR) \
		-o $(PKG_BUILD_DIR)/udpbd-server \
		$(PKG_BUILD_DIR)/main.cpp \
		$(TARGET_LDFLAGS) $(TARGET_LDFLAGS_STATIC)
endef

define Package/udpbd-server/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/udpbd-server $(1)/usr/bin/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udpbd-server.init $(1)/etc/init.d/udpbd-server
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/udpbd-server.config $(1)/etc/config/udpbd-server
endef

define Package/udpbd-server/postinst
#!/bin/sh
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "UDPBD Server installed successfully!"
	echo "Usage: udpbd-server <block-device-file>"
	echo "Example: udpbd-server /dev/sda1"
	echo ""
	echo "To enable as service:"
	echo "  /etc/init.d/udpbd-server enable"
	echo "  /etc/init.d/udpbd-server start"
fi
exit 0
endef

define Package/udpbd-server/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Stopping udpbd-server service..."
	/etc/init.d/udpbd-server stop
	/etc/init.d/udpbd-server disable
fi
exit 0
endef

$(eval $(call BuildPackage,udpbd-server))
