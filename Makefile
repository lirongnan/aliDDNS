include $(TOPDIR)/rules.mk

PKG_NAME:=aliDDNS
PKG_RELEASE:=7

include $(INCLUDE_DIR)/package.mk

define Package/aliDDNS
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Aliyun DDNS client
  DEPENDS:=+curl +openssl-util +jsonfilter +ubus +uci +luci-base
endef

define Package/aliDDNS/description
 A lightweight DDNS client for OpenWrt using Aliyun DNS API.
endef

define Package/aliDDNS/conffiles
/etc/config/aliddns
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
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_BIN) ./src/www/cgi-bin/aliddns $(1)/www/cgi-bin/aliddns
	$(INSTALL_DIR) $(1)/www/aliddns
	$(INSTALL_DATA) ./ui/index.html $(1)/www/aliddns/index.html
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./src/usr/lib/lua/luci/controller/aliddns.lua $(1)/usr/lib/lua/luci/controller/aliddns.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view
	$(INSTALL_DATA) ./src/usr/lib/lua/luci/view/aliddns.htm $(1)/usr/lib/lua/luci/view/aliddns.htm
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./src/usr/share/rpcd/acl.d/luci-app-aliddns.json $(1)/usr/share/rpcd/acl.d/luci-app-aliddns.json
endef

$(eval $(call BuildPackage,aliDDNS))
