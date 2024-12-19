#!/bin/bash -e

# backup feeds
shopt -s extglob
mkdir -p /tmp/base/
mv */ /tmp/base/

# download feeds
git clone https://github.com/openwrt/openwrt openwrt-master -b master --depth 1
git clone https://github.com/openwrt/openwrt openwrt-23.05 -b openwrt-23.05 --depth 1
git clone https://github.com/openwrt/luci luci-23.05 -b openwrt-23.05 --depth 1

# firewall4 - bump version
mkdir -p firewall4/patches
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/Makefile > firewall4/Makefile

# fix flow offload
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/001-fix-fw4-flow-offload.patch > firewall4/patches/001-fix-fw4-flow-offload.patch

# kernel version
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch > firewall4/patches/002-fix-fw4.uc-adept-kernel-version-type-of-x.x.patch

# add custom nft command support
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/100-fw4-add-custom-nft-command-support.patch > firewall4/patches/100-fw4-add-custom-nft-command-support.patch

# fix ct status dnat
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/200-unconditionally-allow-ct-status-dnat.patch > firewall4/patches/200-unconditionally-allow-ct-status-dnat.patch

# fullcone
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/201-firewall4-add-fullcone-support.patch > firewall4/patches/201-firewall4-add-fullcone-support.patch

# bcm fullcone
curl -s https://$mirror/openwrt-23.05/patch/firewall4/firewall4_patches/202-firewall4-add-bcm-fullconenat-support.patch > firewall4/patches/202-firewall4-add-bcm-fullconenat-support.patch

# libnftnl
mv openwrt-23.05/package/libs/libnftnl ./
mkdir -p libnftnl/patches
curl -s https://$mirror/openwrt-23.05/patch/firewall4/libnftnl/001-libnftnl-add-fullcone-expression-support.patch > libnftnl/patches/001-libnftnl-add-fullcone-expression-support.patch
curl -s https://$mirror/openwrt-23.05/patch/firewall4/libnftnl/002-libnftnl-add-brcm-fullcone-support.patch > libnftnl/patches/002-libnftnl-add-brcm-fullcone-support.patch
sed -i '/PKG_INSTALL:=1/iPKG_FIXUP:=autoreconf' libnftnl/Makefile

# nftables
mv openwrt-23.05/package/network/utils/nftables ./
NFTABLES_VERSION=1.0.9
NFTABLES_HASH=a3c304cd9ba061239ee0474f9afb938a9bb99d89b960246f66f0c3a0a85e14cd
sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$NFTABLES_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$NFTABLES_HASH/" nftables/Makefile
mkdir -p nftables/patches
curl -s https://$mirror/openwrt-23.05/patch/firewall4/nftables/002-nftables-add-fullcone-expression-support.patch > nftables/patches/002-nftables-add-fullcone-expression-support.patch
curl -s https://$mirror/openwrt-23.05/patch/firewall4/nftables/003-nftables-add-brcm-fullconenat-support.patch > nftables/patches/003-nftables-add-brcm-fullconenat-support.patch

# iproute2
git clone https://github.com/pmkol/package_network_utils_iproute2 iproute2 --depth 1
rm -rf iproute2/.git

# libunwind
mkdir -p libunwind/patches
curl -s https://raw.githubusercontent.com/openwrt/openwrt/f9e3fb59c7e1835c4003457636a5ea269f6ec06d/package/libs/libunwind/Makefile > libunwind/Makefile
curl -s https://raw.githubusercontent.com/openwrt/openwrt/f9e3fb59c7e1835c4003457636a5ea269f6ec06d/package/libs/libunwind/patches/002-fix-building-getcontext_S.patch > libunwind/patches/002-fix-building-getcontext_S.patch
curl -s https://raw.githubusercontent.com/openwrt/openwrt/f9e3fb59c7e1835c4003457636a5ea269f6ec06d/package/libs/libunwind/patches/003-fix-missing-ef_reg-defs-with-musl.patch > libunwind/patches/003-fix-missing-ef_reg-defs-with-musl.patch
curl -s https://raw.githubusercontent.com/openwrt/openwrt/f9e3fb59c7e1835c4003457636a5ea269f6ec06d/package/libs/libunwind/patches/004-ppc-musl.patch > libunwind/patches/004-ppc-musl.patch

# patch luci add nft_fullcone/bcm_fullcone & shortcut-fe & ipv6-nat & custom nft command option
mv luci-23.05/applications/luci-app-firewall ./
rm -rf luci-app-firewall/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-firewall/Makefile
curl -s https://$mirror/openwrt-23.05/patch/firewall4/0001-luci-app-firewall-add-nft-fullcone-and-bcm-fullcone.patch | patch -p2
curl -s https://$mirror/openwrt-23.05/patch/firewall4/0002-luci-app-firewall-add-shortcut-fe-option.patch | patch -p2
curl -s https://$mirror/openwrt-23.05/patch/firewall4/0003-luci-app-firewall-add-ipv6-nat-option.patch | patch -p2
curl -s https://$mirror/openwrt-23.05/patch/firewall4/0004-luci-add-firewall-add-custom-nft-rule-support.patch | patch -p2

# patch luci hide hardware_offload
sed -i '/Requires hardware NAT support./{N;N;s/1/2/}' luci-app-firewall/htdocs/luci-static/resources/view/firewall/zones.js

# bash-completion
mkdir -p bash-completion
curl -s https://$mirror/openwrt-23.05/patch/bash-completion/Makefile > bash-completion/Makefile

# nghttp3
git clone https://github.com/sbwml/package_libs_nghttp3 nghttp3 --depth 1
rm -rf nghttp3/.git

# ngtcp2
git clone https://github.com/sbwml/package_libs_ngtcp2 ngtcp2 --depth 1
rm -rf ngtcp2/.git

# curl
git clone https://github.com/sbwml/feeds_packages_net_curl curl --depth 1
rm -rf curl/.git

# netkit-ftp
git clone https://github.com/sbwml/package_new_ftp ftp --depth 1
rm -rf ftp/.git

# nethogs
git clone https://github.com/sbwml/package_new_nethogs nethogs --depth 1
rm -rf nethogs/.git

# ppp - bump version
mv openwrt-master/package/network/services/ppp ./

# zlib - bump version
mv openwrt-master/package/libs/zlib ./

# tcp-brutal
git clone https://github.com/sbwml/package_kernel_tcp-brutal tcp-brutal --depth 1
rm -rf tcp-brutal/{.git,LICENSE,README.md}


rm -rf openwrt-master openwrt-23.05 luci-23.05
ls -d */ | xargs -n 1 basename | paste -sd ' ' - > packages.txt
