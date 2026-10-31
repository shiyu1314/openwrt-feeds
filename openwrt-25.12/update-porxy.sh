#!/bin/bash -e

# backup feeds
shopt -s extglob
mkdir -p /tmp/lite/
mv */ /tmp/lite/

# download feeds
git clone https://github.com/nikkinikki-org/OpenWrt-nikki openwrt-nikki --depth 1
mv openwrt-nikki/*/ ./
rm -rf openwrt-nikki

git clone https://github.com/nikkinikki-org/OpenWrt-momo OpenWrt-momo --depth 1
mv OpenWrt-momo/*/ ./
rm -rf OpenWrt-momo


ls -d */ | xargs -n 1 basename | grep "^luci-app" | while read pkg; do
    echo "CONFIG_PACKAGE_${pkg}=y"
done > packages.txt
