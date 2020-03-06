include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dockerman
PKG_VERSION:=v0.4.1
PKG_RELEASE:=beta
PKG_MAINTAINER:=lisaac <https://github.com/lisaac/luci-app-dockerman>
PKG_LICENSE:=AGPL-3.0
PO2LMO:=./po2lmo

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/config
menu "Configuration"
config PACKAGE_$(PKG_NAME)_INCLUDE_docker_ce
	bool "Include Docker-CE"
	default y
config PACKAGE_$(PKG_NAME)_INCLUDE_ttyd
	bool "Include ttyd"
	default y
endmenu
endef

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Docker Manager interface for LuCI
	PKGARCH:=all
	DEPENDS:=+luci-lib-docker +PACKAGE_$(PKG_NAME)_INCLUDE_docker_ce:docker-ce +PACKAGE_$(PKG_NAME)_INCLUDE_ttyd:ttyd +e2fsprogs +fdisk
endef


define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/dockerman
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
uci set uhttpd.main.script_timeout="600"
uci commit uhttpd
rm -fr /tmp/luci-indexcache /tmp/luci-modulecache
/etc/init.d/uhttpd restart
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/dockerman $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_BIN) ./root/etc/docker-init $(1)/etc
#	$(INSTALL_DIR) $(1)/etc/init.d
#	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	chmod 755 $(PO2LMO)
	$(PO2LMO) ./po/zh-cn/dockerman.po $(1)/usr/lib/lua/luci/i18n/dockerman.zh-cn.lmo
endef


$(eval $(call BuildPackage,$(PKG_NAME)))