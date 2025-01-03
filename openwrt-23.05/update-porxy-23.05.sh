#!/bin/bash -e

# backup feeds
shopt -s extglob
mkdir -p /tmp/lite/
mv */ /tmp/lite/

# download feeds
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1
git clone https://github.com/immortalwrt/homeproxy immortalwrt/luci-app-homeproxy --depth 1
git clone https://github.com/sbwml/openwrt_helloworld --depth 1
git clone https://github.com/morytyann/OpenWrt-mihomo openwrt-mihomo --depth 1
git clone https://github.com/pmkol/v2ray-geodata --depth 1
git clone https://github.com/vernesong/OpenClash --depth 1
rm -rf immortalwrt/luci-app-homeproxy/{.git,.github,LICENSE,README}
rm -rf openwrt_helloworld/{luci-app-homeproxy,luci-app-mihomo,mihomo,v2ray-geodata,luci-app-openclash,luci-app-ssr-plus}
rm -rf v2ray-geodata/.git
mv -f openwrt_helloworld/*.patch ./
mv OpenClash/*/ ./
rm -rf OpenClash

# helloworld
mv openwrt_helloworld/*/ ./
rm -rf openwrt_helloworld

# luci-app-dae
mv immortalwrt/luci/applications/luci-app-dae ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dae/Makefile
mv immortalwrt/packages/net/dae ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dae/Makefile

# luci-app-homeproxy
mv immortalwrt/luci-app-homeproxy ./

# luci-app-mihomo
sed -i 's|https://github.com|https://gh.api.99988866.xyz/https://github.com|g' openwrt-mihomo/luci-app-mihomo/htdocs/luci-static/resources/view/mihomo/mixin.js
sed -i 's|https://github.com|https://gh.api.99988866.xyz/https://github.com|g' openwrt-mihomo/mihomo/files/mihomo.conf
mv openwrt-mihomo/*/ ./
rm -rf openwrt-mihomo

# luci-app-passwall
PASSWALL_VERSION=$(curl -s "https://api.github.com/repos/xiaorouji/openwrt-passwall/tags" | jq -r '.[0].name')
if [ "$(grep ^PKG_VERSION luci-app-passwall/Makefile | cut -d '=' -f 2 | tr -d ' ')" != "$PASSWALL_VERSION" ]; then
    rm -rf luci-app-passwall
    git clone https://github.com/xiaorouji/openwrt-passwall.git -b "$PASSWALL_VERSION" --depth 1
    patch -p1 -f -s -d openwrt-passwall < patch-luci-app-passwall.patch
    if [ $? -eq 0 ]; then
        rm -rf luci-app-passwall
        mv openwrt-passwall/luci-app-passwall ./
        rm -rf openwrt-passwall
    else
        rm -rf openwrt-passwall
    fi
fi


rm -rf immortalwrt *.patch
ls -d */ | xargs -n 1 basename | paste -sd ' ' - > packages.txt
