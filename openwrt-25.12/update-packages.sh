#!/bin/bash -e

# aria2 配置补丁镜像；可用环境变量覆盖，例如：
#   mirror=raw.githubusercontent.com/sbwml/openwrt_pkgs ./build.sh
mirror="${mirror:-raw.githubusercontent.com/sbwml/openwrt_pkgs}"

# backup feeds
shopt -s extglob
rm -rf /tmp/extd
mkdir -p /tmp/extd/
mv -- */ /tmp/extd/

# git clone 不会自动创建多级父目录，先建好
mkdir -p immortalwrt

# download feeds
git clone -b master --depth 1 https://github.com/immortalwrt/luci immortalwrt/luci
git clone -b master --depth 1 https://github.com/immortalwrt/packages immortalwrt/packages
git clone --depth 1 https://github.com/sirpdboy/luci-app-ddns-go openwrt-ddns-go
git clone --depth 1 https://github.com/sbwml/openwrt_pkgs
git clone --depth 1 https://github.com/sbwml/luci-app-airconnect openwrt-airconnect
git clone --depth 1 https://github.com/sbwml/luci-app-mentohust openwrt-mentohust
git clone -b v5-lua --depth 1 https://github.com/sbwml/luci-app-mosdns openwrt-mosdns
git clone --depth 1 https://github.com/sbwml/luci-app-qbittorrent openwrt-qbittorrent
git clone --depth 1 https://github.com/sbwml/feeds_packages_libs_liburing liburing
git clone --depth 1 https://github.com/sbwml/feeds_packages_net_samba4 samba4
git clone --depth 1 https://github.com/sbwml/feeds_packages_utils_unzip unzip
git clone --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic
git clone --depth 1 https://github.com/pmkol/packages_net_miniupnpd miniupnpd
git clone --depth 1 https://github.com/pmkol/luci-app-upnp
git clone --depth 1 https://github.com/pmkol/packages_net_qosmate qosmate
git clone --depth 1 https://github.com/pmkol/luci-app-qosmate
git clone --depth 1 https://github.com/shiyu1314/openwrt-packages op-xd
rm -rf op-xd/{luci-lib-taskd,luci-lib-xterm,luci-app-adguardhome,.git,.github}
rm -rf openwrt_pkgs/{bash-completion,luci-app-ota,fw_download_tool,luci-app-adguardhome,adguardhome}
rm -rf openwrt-ddns-go/luci-app-ddns-go/README.md
rm -rf liburing/.git
rm -rf samba4/{.git,README.md}
rm -rf unzip/.git
rm -rf luci-app-unblockneteasemusic/{.git,.github,LICENSE,README.md}
rm -rf einat-ebpf/{.git,.github,LICENSE,README.md}
rm -rf luci-app-einat/{.git,LICENSE,README.md,po/zh_Hant}
rm -rf miniupnpd/{.git,.github}
rm -rf luci-app-upnp/{.git,.github}
rm -rf qosmate/{.git,LICENSE,README.md}
rm -rf luci-app-qosmate/{.git,LICENSE,README.md}
git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-lucky op-lucky
rm -rf op-lucky/{.github,.git,doc,README.md}
mv op-lucky/*/ ./
rm -rf op-lucky


# pkgs
mv op-xd/*/ ./
mv openwrt_pkgs/*/ ./
rm -rf openwrt_pkgs
rm -rf op-xd

# luci-app-airconnect
mv openwrt-airconnect/*/ ./
rm -rf openwrt-airconnect

# luci-app-cifs-mount
mv immortalwrt/luci/applications/luci-app-cifs-mount ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-cifs-mount/Makefile


# luci-app-ddns-go
mv openwrt-ddns-go/*/ ./
rm -rf openwrt-ddns-go

# luci-app-dufs
mv immortalwrt/luci/applications/luci-app-dufs ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dufs/Makefile
mv immortalwrt/packages/net/dufs ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' dufs/Makefile


# luci-app-filebrowser-go
if [ -f luci-app-filebrowser-go/root/usr/share/rpcd/acl.d/luci-app-filebrowser-go.json ]; then
  sed -i 's/"luci-app-filebrowser"/"luci-app-filebrowser-go"/g' \
    luci-app-filebrowser-go/root/usr/share/rpcd/acl.d/luci-app-filebrowser-go.json
fi

# luci-app-gost
mv immortalwrt/luci/applications/luci-app-gost ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-gost/Makefile
mv immortalwrt/packages/net/gost ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' gost/Makefile

# luci-app-hd-idle
mv immortalwrt/luci/applications/luci-app-hd-idle ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-hd-idle/Makefile
sed -i 's|admin/nas|admin/services|g' luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
sed -i 's/"order": 60/"order": 99/g' luci-app-hd-idle/root/usr/share/luci/menu.d/luci-app-hd-idle.json
rm -rf luci-app-hd-idle/po/!(templates|zh_Hans)

# luci-app-ksmbd
mv immortalwrt/luci/applications/luci-app-ksmbd ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-ksmbd/Makefile
sed -i 's/0666/0644/g;s/0777/0755/g' luci-app-ksmbd/htdocs/luci-static/resources/view/ksmbd.js
rm -rf luci-app-ksmbd/po/!(templates|zh_Hans)
mv immortalwrt/packages/net/ksmbd-tools ./
sed -i 's/0666/0644/g;s/0777/0755/g' ksmbd-tools/files/ksmbd.config.example
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' ksmbd-tools/files/ksmbd.conf.template

# luci-app-mentohust
mv openwrt-mentohust/*/ ./
rm -rf openwrt-mentohust

# luci-app-mosdns
mv openwrt-mosdns/*/ ./
rm -rf openwrt-mosdns

# luci-app-msd_lite
mv immortalwrt/luci/applications/luci-app-msd_lite ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-msd_lite/Makefile
mv immortalwrt/packages/net/msd_lite ./

# luci-app-nfs
mv immortalwrt/luci/applications/luci-app-nfs ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-nfs/Makefile
sed -i 's/"admin", "nas", "nfs"/"admin", "services", "nfs"/g' luci-app-nfs/luasrc/controller/nfs.lua

# luci-app-qbittorrent
mv openwrt-qbittorrent/*/ ./
rm -rf openwrt-qbittorrent

# samba4
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' samba4/Makefile
sed -i '/workgroup/a \\n\t## enable multi-channel' samba4/files/smb.conf.template
sed -i '/enable multi-channel/a \\tserver multi channel support = yes' samba4/files/smb.conf.template
sed -i 's/#aio read size = 0/aio read size = 0/g' samba4/files/smb.conf.template
sed -i 's/#aio write size = 0/aio write size = 0/g' samba4/files/smb.conf.template
sed -i 's/invalid users = root/#invalid users = root/g' samba4/files/smb.conf.template
sed -i 's/bind interfaces only = yes/bind interfaces only = no/g' samba4/files/smb.conf.template
sed -i 's/#create mask/create mask/g' samba4/files/smb.conf.template
sed -i 's/#directory mask/directory mask/g' samba4/files/smb.conf.template
sed -i 's/0666/0644/g;s/0777/0755/g' samba4/files/samba.config
sed -i 's/0666/0644/g;s/0777/0755/g' samba4/files/smb.conf.template

# luci-app-smartdns
mv immortalwrt/luci/applications/luci-app-smartdns ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-smartdns/Makefile
rm -rf luci-app-smartdns/po/!(templates|zh_Hans)
mv immortalwrt/packages/net/smartdns ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' smartdns/Makefile
sed -i -E \
  -e 's/[[:space:]]*PACKAGE_smartdns-ui:rust-bindgen\/host//g' \
  -e 's/[[:space:]]*rust-bindgen\/host//g' \
  -e 's/[[:space:]]*PACKAGE_smartdns-ui://g' \
  smartdns/Makefile


# luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# luci-app-upnp
rm -rf luci-app-upnp/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-upnp/Makefile


# luci-app-zerotier
if [ -f luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json ]; then
  sed -i 's/"order": 1050/"order": 80/g' luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
fi

# luci-theme-material3
if [ -d luci-theme-material3 ]; then
  rm -rf luci-theme-material3/{.git,Readme.md,README.md}
fi

# ddns-scripts
mv immortalwrt/packages/net/ddns-scripts ./

# aria2 & ariaNG
git clone --depth 1 https://github.com/sbwml/ariang-nginx
rm -rf ariang-nginx/{.git,LICENSE,README.md}
mv ariang-nginx/* ./
rm -rf ariang-nginx
if [ -f luci-app-aria2/root/etc/uci-defaults/40_luci-aria2 ]; then
  sed -i '12d' luci-app-aria2/root/etc/uci-defaults/40_luci-aria2
fi
git clone -b 22.03 --depth 1 https://github.com/sbwml/feeds_packages_net_aria2 aria2
rm -rf aria2/{.git,LICENSE,README.md}

curl -fsSL --retry 3 "https://raw.githubusercontent.com/shiyu1314/openwrt-feeds/refs/heads/main/openwrt-25.12/patch/aria2/aria2.conf" \
  -o aria2/files/aria2.conf

# alist
git clone -b main --depth 1 https://github.com/sbwml/luci-app-openlist2 op-openlist
rm -rf op-openlist/{.git,.github,README.md,install.sh}
mv op-openlist/* ./
rm -rf op-openlist

mv immortalwrt/luci/applications/luci-app-dockerman ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dockerman/Makefile

git clone --depth 1 https://github.com/destan19/OpenAppFilter OpenAppFilter
rm -rf OpenAppFilter/{.git,.github,README.md,install.sh}
mv OpenAppFilter/* ./
rm -rf OpenAppFilter

git clone --depth 1 https://github.com/timsaya/openwrt-bandix bandix
rm -rf bandix/{.git,.github,README.md,install.sh,LICENSE,README.zh.md}
mv bandix/openwrt-bandix/* bandix/
rm -rf bandix

git clone --depth 1 https://github.com/timsaya/luci-app-bandix op-bandix
rm -rf op-bandix/{.git,.github,*.md,install.sh,docs}
mv op-bandix/* ./
rm -rf op-bandix

git clone --depth 1 https://github.com/shiyu1314/luci-theme-m3e luci-theme-m3e
rm -rf luci-theme-m3e/{.git,.github}

git clone --depth 1 https://github.com/sbwml/luci-app-diskman op-diskman
rm -rf op-diskman/{.git,.github,docs,LICENSE,README.md}
mv op-diskman/* ./
rm -rf op-diskman

git clone --depth 1 https://github.com/eamonxg/luci-theme-aurora luci-theme-aurora
rm -rf luci-theme-aurora/{.git,.github,README.md,install.sh}

git clone --depth 1 https://github.com/jerrykuku/luci-theme-argon luci-theme-argon
rm -rf luci-theme-argon/{.git,.github,README.md,install.sh}

git clone --depth 1 https://github.com/whzhni1/luci-app-tailscale op-tailscale
mv op-tailscale/luci-app-tailscale ./
rm -rf luci-app-tailscale/{.git,.gitignore,LICENSE,README.md,po/zh_Hant}
rm -rf op-tailscale

git clone --depth 1 https://github.com/anothaDev/luci-theme-vantage op-vantage
mv op-vantage/luci-app-vantage ./
rm -rf op-vantage


git clone --depth 1 https://github.com/shiyu1314/luci-app-adguardhome luci-app-adguardhome
rm -rf luci-app-adguardhome/{.git,.github,patches,.official_json_version,.upstream_meta,LICENSE,README.md,SECURITY.md}

rm -rf ./{LICENSE,doc}

# 清理 immortalwrt 临时 clone 目录
rm -rf immortalwrt

ls -d */ 2>/dev/null | xargs -n 1 basename 2>/dev/null | grep -E "^(luci-app|luci-theme)" | while read pkg; do
    echo "CONFIG_PACKAGE_${pkg}=y"
done > packages.txt
