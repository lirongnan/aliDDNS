include $(TOPDIR)/rules.mk

PKG_NAME:=aliDDNS
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/aliDDNS
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Aliyun DDNS client
  DEPENDS:=+curl +openssl-util +jsonfilter +ubus +uci
endef

define Package/aliDDNS/description
 A lightweight DDNS client for OpenWrt using Aliyun DNS API.
endef

define Build/Compile
endef

define Package/aliDDNS/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./src/etc/config/aliddns $(1)/etc/config/aliddns
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./src/etc/init.d/aliddns $(1)/etc/init.d/aliddns
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./src/usr/bin/aliddns.sh $(1)/usr/bin/aliddns.sh
endef

$(eval $(call BuildPackage,aliDDNS))
