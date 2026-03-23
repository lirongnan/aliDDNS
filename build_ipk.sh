#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
PKG_NAME=aliDDNS
PKG_RELEASE=$(sed -n "s/^PKG_RELEASE:=//p" "$ROOT_DIR/Makefile" | head -n 1)
PKG_RELEASE=${PKG_RELEASE:-1}
PKG_VERSION=1.0-$PKG_RELEASE
PKG_ARCH=${PKG_ARCH:-all}
OUTPUT_DIR=${OUTPUT_DIR:-$ROOT_DIR/dist}
STAGE_DIR=${STAGE_DIR:-$ROOT_DIR/.ipk-stage}
CONTROL_DIR=$STAGE_DIR/control
DATA_DIR=$STAGE_DIR/data

require_tool() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "Missing required tool: $1" >&2
		exit 1
	}
}

require_tool ar
require_tool tar
require_tool gzip

rm -rf "$OUTPUT_DIR" "$STAGE_DIR"
mkdir -p "$OUTPUT_DIR" "$CONTROL_DIR" "$DATA_DIR"

mkdir -p \
	"$DATA_DIR/etc/config" \
	"$DATA_DIR/etc/init.d" \
	"$DATA_DIR/etc/hotplug.d/iface" \
	"$DATA_DIR/usr/bin" \
	"$DATA_DIR/usr/lib/lua/luci/controller" \
	"$DATA_DIR/usr/lib/lua/luci/view" \
	"$DATA_DIR/usr/share/rpcd/acl.d" \
	"$DATA_DIR/www/cgi-bin" \
	"$DATA_DIR/www/aliddns"

install -m 0644 "$ROOT_DIR/src/etc/config/aliddns" "$DATA_DIR/etc/config/aliddns"
install -m 0755 "$ROOT_DIR/src/etc/init.d/aliddns" "$DATA_DIR/etc/init.d/aliddns"
install -m 0755 "$ROOT_DIR/src/etc/hotplug.d/iface/95-aliddns" "$DATA_DIR/etc/hotplug.d/iface/95-aliddns"
install -m 0755 "$ROOT_DIR/src/usr/bin/aliddns.sh" "$DATA_DIR/usr/bin/aliddns.sh"
install -m 0755 "$ROOT_DIR/src/www/cgi-bin/aliddns" "$DATA_DIR/www/cgi-bin/aliddns"
install -m 0644 "$ROOT_DIR/ui/index.html" "$DATA_DIR/www/aliddns/index.html"
install -m 0644 "$ROOT_DIR/src/usr/lib/lua/luci/controller/aliddns.lua" "$DATA_DIR/usr/lib/lua/luci/controller/aliddns.lua"
install -m 0644 "$ROOT_DIR/src/usr/lib/lua/luci/view/aliddns.htm" "$DATA_DIR/usr/lib/lua/luci/view/aliddns.htm"
install -m 0644 "$ROOT_DIR/src/usr/share/rpcd/acl.d/luci-app-aliddns.json" "$DATA_DIR/usr/share/rpcd/acl.d/luci-app-aliddns.json"

cat > "$CONTROL_DIR/control" <<EOF
Package: $PKG_NAME
Version: $PKG_VERSION
Release: $PKG_RELEASE
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

printf '2.0\n' > "$STAGE_DIR/debian-binary"

(
	cd "$CONTROL_DIR"
	tar -czf "$STAGE_DIR/control.tar.gz" ./control ./conffiles
)

(
	cd "$DATA_DIR"
	tar -czf "$STAGE_DIR/data.tar.gz" .
)

IPK_PATH="$OUTPUT_DIR/${PKG_NAME}_${PKG_VERSION}_${PKG_ARCH}.ipk"
(
	cd "$STAGE_DIR"
	ar r "$IPK_PATH" ./debian-binary ./control.tar.gz ./data.tar.gz >/dev/null
)

echo "$IPK_PATH"