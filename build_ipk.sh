#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
PKG_NAME=aliDDNS
PKG_RELEASE=$(sed -n "s/^PKG_RELEASE:=//p" "$ROOT_DIR/Makefile" | head -n 1)
PKG_RELEASE=${PKG_RELEASE:-1}
PKG_VERSION=$PKG_RELEASE
PKG_ARCH=${PKG_ARCH:-all}
OUTPUT_DIR=${OUTPUT_DIR:-$ROOT_DIR/dist}
STAGE_DIR=${STAGE_DIR:-$ROOT_DIR/.ipk-stage}
PKG_ROOT=$STAGE_DIR/pkgroot
CONTROL_DIR=$PKG_ROOT/CONTROL
DOWNLOADED_IPKG_BUILD=

find_ipkg_build() {
	if command -v ipkg-build >/dev/null 2>&1; then
		command -v ipkg-build
		return 0
	fi
	if command -v curl >/dev/null 2>&1; then
		DOWNLOADED_IPKG_BUILD="$STAGE_DIR/ipkg-build"
		curl -fsSL "https://raw.githubusercontent.com/openwrt/openwrt/main/scripts/ipkg-build" -o "$DOWNLOADED_IPKG_BUILD"
		chmod 755 "$DOWNLOADED_IPKG_BUILD"
		printf '%s\n' "$DOWNLOADED_IPKG_BUILD"
		return 0
	fi
	if command -v wget >/dev/null 2>&1; then
		DOWNLOADED_IPKG_BUILD="$STAGE_DIR/ipkg-build"
		wget -qO "$DOWNLOADED_IPKG_BUILD" "https://raw.githubusercontent.com/openwrt/openwrt/main/scripts/ipkg-build"
		chmod 755 "$DOWNLOADED_IPKG_BUILD"
		printf '%s\n' "$DOWNLOADED_IPKG_BUILD"
		return 0
	fi
	echo "Missing ipkg-build and no downloader available (curl or wget)." >&2
	exit 1
}

rm -rf "$OUTPUT_DIR" "$STAGE_DIR"
mkdir -p "$OUTPUT_DIR" "$CONTROL_DIR"

IPKG_BUILD=$(find_ipkg_build)

mkdir -p \
	"$PKG_ROOT/etc/config" \
	"$PKG_ROOT/etc/init.d" \
	"$PKG_ROOT/etc/hotplug.d/iface" \
	"$PKG_ROOT/usr/bin" \
	"$PKG_ROOT/usr/lib/lua/luci/controller" \
	"$PKG_ROOT/usr/lib/lua/luci/view" \
	"$PKG_ROOT/usr/share/rpcd/acl.d" \
	"$PKG_ROOT/www/cgi-bin" \
	"$PKG_ROOT/www/aliddns"

install -m 0644 "$ROOT_DIR/src/etc/config/aliddns" "$PKG_ROOT/etc/config/aliddns"
install -m 0755 "$ROOT_DIR/src/etc/init.d/aliddns" "$PKG_ROOT/etc/init.d/aliddns"
install -m 0755 "$ROOT_DIR/src/etc/hotplug.d/iface/95-aliddns" "$PKG_ROOT/etc/hotplug.d/iface/95-aliddns"
install -m 0755 "$ROOT_DIR/src/usr/bin/aliddns.sh" "$PKG_ROOT/usr/bin/aliddns.sh"
install -m 0755 "$ROOT_DIR/src/www/cgi-bin/aliddns" "$PKG_ROOT/www/cgi-bin/aliddns"
install -m 0644 "$ROOT_DIR/ui/index.html" "$PKG_ROOT/www/aliddns/index.html"
install -m 0644 "$ROOT_DIR/src/usr/lib/lua/luci/controller/aliddns.lua" "$PKG_ROOT/usr/lib/lua/luci/controller/aliddns.lua"
install -m 0644 "$ROOT_DIR/src/usr/lib/lua/luci/view/aliddns.htm" "$PKG_ROOT/usr/lib/lua/luci/view/aliddns.htm"
install -m 0644 "$ROOT_DIR/src/usr/share/rpcd/acl.d/luci-app-aliddns.json" "$PKG_ROOT/usr/share/rpcd/acl.d/luci-app-aliddns.json"

cat > "$CONTROL_DIR/control" <<EOF
Package: $PKG_NAME
Version: $PKG_VERSION
Architecture: $PKG_ARCH
Section: net
Priority: optional
Depends: curl, openssl-util, jsonfilter, ubus, uci, luci-base
Maintainer: kevinly0324@gmail.com
Description: Aliyun DDNS client for OpenWrt
EOF

cat > "$CONTROL_DIR/conffiles" <<EOF
/etc/config/aliddns
EOF

"$IPKG_BUILD" "$PKG_ROOT" "$OUTPUT_DIR" >/dev/null

IPK_PATH="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.ipk"

echo "$IPK_PATH"