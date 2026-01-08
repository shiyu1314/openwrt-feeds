#!/bin/bash -e

# backup feeds
shopt -s extglob
mkdir -p /tmp/extd/
mv */ /tmp/extd/

# download feeds
git clone https://github.com/openwrt/luci openwrt/luci -b openwrt-24.10 --depth 1
git clone https://github.com/openwrt/packages openwrt/packages -b openwrt-24.10 --depth 1
git clone https://github.com/openwrt/packages openwrt/packages-master -b master --depth 1
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1
git clone https://github.com/sirpdboy/luci-app-ddns-go openwrt-ddns-go --depth 1
git clone https://github.com/sbwml/openwrt_pkgs --depth 1
git clone https://github.com/sbwml/luci-app-airconnect openwrt-airconnect --depth 1
git clone https://github.com/sbwml/luci-app-mentohust openwrt-mentohust --depth 1
git clone https://github.com/sbwml/luci-app-mosdns openwrt-mosdns -b v5-lua --depth 1
git clone https://github.com/sbwml/luci-app-qbittorrent openwrt-qbittorrent --depth 1
git clone https://github.com/sbwml/feeds_packages_libs_liburing liburing --depth 1
git clone https://github.com/sbwml/feeds_packages_net_samba4 samba4 --depth 1
git clone https://github.com/sbwml/feeds_packages_utils_unzip unzip --depth 1
git clone https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic --depth 1
git clone https://github.com/asvow/luci-app-tailscale --depth 1
git clone https://github.com/muink/openwrt-einat-ebpf einat-ebpf --depth 1
git clone https://github.com/muink/luci-app-einat --depth 1
git clone -b main --depth 1 --single-branch https://github.com/shiyu1314/luci-theme-material3 luci-theme-material3
git clone https://github.com/pmkol/openwrt-eqosplus --depth 1
git clone https://github.com/pmkol/packages_net_miniupnpd miniupnpd --depth 1
git clone https://github.com/pmkol/luci-app-upnp --depth 1
git clone https://github.com/pmkol/packages_net_qosmate qosmate --depth 1
git clone https://github.com/pmkol/luci-app-qosmate --depth 1
git clone https://github.com/shiyu1314/openwrt-packages op-xd --depth 1
rm -rf op-xd/{luci-lib-taskd,luci-lib-xterm,luci-app-adguardhome,.git,.github}
rm -rf openwrt_pkgs/{bash-completion,luci-app-ota,fw_download_tool}
rm -rf openwrt-ddns-go/luci-app-ddns-go/README.md
rm -rf liburing/.git
rm -rf samba4/{.git,README.md}
rm -rf unzip/.git
rm -rf luci-app-unblockneteasemusic/{.git,.github,LICENSE,README.md}
rm -rf luci-app-tailscale/{.git,.gitignore,LICENSE,README.md,po/zh_Hant}
rm -rf einat-ebpf/{.git,.github,LICENSE,README.md}
rm -rf luci-app-einat/{.git,LICENSE,README.md,po/zh_Hant}
rm -rf miniupnpd/{.git,.github}
rm -rf luci-app-upnp/{.git,.github}
rm -rf qosmate/{.git,LICENSE,README.md}
rm -rf luci-app-qosmate/{.git,LICENSE,README.md}
git clone https://github.com/sirpdboy/luci-app-lucky op-lucky -b main --depth 1
rm -rf op-lucky/{.github,.git,doc,README.md}
mv op-lucky/*/ ./

# luci-app-adguardhome
mv openwrt/packages-master/net/adguardhome ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' adguardhome/Makefile
sed -i '73,83d' adguardhome/Makefile

sed -i 's/Arch="arm"/Arch="armv7"/' openwrt_pkgs/luci-app-adguardhome/root/usr/share/AdGuardHome/update_core.sh

# pkgs
mv op-xd/*/ ./
mv openwrt_pkgs/*/ ./
mv openwrt-packages/*/ ./
rm -rf openwrt_pkgs
rm -rf openwrt-packages

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

# luci-app-eqosplus
mv openwrt-eqosplus/*/ ./
rm -rf openwrt-eqosplus

# luci-app-filebrowser-go
sed -i 's/"luci-app-filebrowser"/"luci-app-filebrowser-go"/g' luci-app-filebrowser-go/root/usr/share/rpcd/acl.d/luci-app-filebrowser-go.json

# luci-app-frpc|frps
mv openwrt/luci/applications/luci-app-frpc ./
mv openwrt/luci/applications/luci-app-frps ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-frpc/Makefile
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-frps/Makefile
sed -i 's,frp 客户端,FRP 客户端,g' luci-app-frpc/po/zh_Hans/frpc.po
sed -i 's,frp 服务器,FRP 服务器,g' luci-app-frps/po/zh_Hans/frps.po
sed -i '3 a\\t\t"order": 80,' luci-app-frpc/root/usr/share/luci/menu.d/luci-app-frpc.json
sed -i '3 a\\t\t"order": 80,' luci-app-frps/root/usr/share/luci/menu.d/luci-app-frps.json
rm -rf luci-app-frpc/po/!(templates|zh_Hans)
rm -rf luci-app-frps/po/!(templates|zh_Hans)
mv openwrt/packages/net/frp ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' frp/Makefile
sed -i 's/procd_set_param stdout $stdout/procd_set_param stdout 0/g' frp/files/frpc.init
sed -i 's/procd_set_param stderr $stderr/procd_set_param stderr 0/g' frp/files/frpc.init
sed -i 's/stdout stderr //g' frp/files/frpc.init
sed -i '/stdout:bool/d;/stderr:bool/d' frp/files/frpc.init
sed -i '/stdout/d;/stderr/d' frp/files/frpc.config
sed -i 's/env conf_inc/env conf_inc enable/g' frp/files/frpc.init
sed -i "s/'conf_inc:list(string)'/& \\\\/" frp/files/frpc.init
sed -i "/conf_inc:list/a\\\t\t\'enable:bool:0\'" frp/files/frpc.init
sed -i '/procd_open_instance/i\\t\[ "$enable" -ne 1 \] \&\& return 1\n' frp/files/frpc.init

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

# luci-app-natmap
mv openwrt/luci/applications/luci-app-natmap ./
rm -rf luci-app-natmap/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-natmap/Makefile

# luci-app-nfs
mv immortalwrt/luci/applications/luci-app-nfs ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-nfs/Makefile
sed -i 's/"admin", "nas", "nfs"/"admin", "services", "nfs"/g' luci-app-nfs/luasrc/controller/nfs.lua

# luci-app-nlbwmon
mv openwrt/packages/net/nlbwmon ./
sed -i 's/stderr 1/stderr 0/g' nlbwmon/files/nlbwmon.init
mv openwrt/luci/applications/luci-app-nlbwmon ./
rm -rf luci-app-nlbwmon/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-nlbwmon/Makefile
sed -i 's/services/network/g' luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
sed -i 's/services/network/g' luci-app-nlbwmon/htdocs/luci-static/resources/view/nlbw/config.js

# luci-app-qbittorrent
mv openwrt-qbittorrent/*/ ./
rm -rf openwrt-qbittorrent

# luci-app-samba4
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
mv openwrt/luci/applications/luci-app-samba4 ./
rm -rf luci-app-samba4/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-samba4/Makefile
sed -i 's/0666/0644/g;s/0744/0755/g;s/0777/0755/g' luci-app-samba4/htdocs/luci-static/resources/view/samba4.js

# luci-app-smartdns
mv immortalwrt/luci/applications/luci-app-smartdns ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-smartdns/Makefile
rm -rf luci-app-smartdns/po/!(templates|zh_Hans)
mv immortalwrt/packages/net/smartdns ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' smartdns/Makefile

# luci-app-tailscale
mv openwrt/packages-master/net/tailscale ./
rm -f tailscale/README.md
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' tailscale/Makefile
TAILSCALE_VERSION=$(curl -s https://api.github.com/repos/tailscale/tailscale/releases/latest | jq -r .tag_name | sed 's/^v//')
[ -n "$TAILSCALE_VERSION" ] && curl -Ls "https://codeload.github.com/tailscale/tailscale/tar.gz/v$TAILSCALE_VERSION" > /tmp/tailscale-$TAILSCALE_VERSION.tar.gz
TAILSCALE_HASH=$(sha256sum /tmp/tailscale-$TAILSCALE_VERSION.tar.gz | awk '{print $1}')
if [ -n "$TAILSCALE_HASH" ] && ! grep -q "^PKG_VERSION:=null" tailscale/Makefile; then
    sed -ri "s/(PKG_VERSION:=)[^\"]*/\1$TAILSCALE_VERSION/;s/(PKG_HASH:=)[^\"]*/\1$TAILSCALE_HASH/" tailscale/Makefile
else
    rm -f tailscale/Makefile
    mv /tmp/extd/tailscale/Makefile tailscale/Makefile
fi
rm -f tailscale/files/{tailscale.conf,tailscale.init}
mv luci-app-tailscale/root/etc/config/tailscale tailscale/files/tailscale.conf
mv luci-app-tailscale/root/etc/init.d/tailscale tailscale/files/tailscale.init
[ -z "$(ls -A luci-app-tailscale/root/etc/config 2>/dev/null)" ] && rm -rf luci-app-tailscale/root/etc/config
[ -z "$(ls -A luci-app-tailscale/root/etc/init.d 2>/dev/null)" ] && rm -rf luci-app-tailscale/root/etc/init.d
sed -i 's/"order": 90/"order": 80/g; s/vpn/services/g' luci-app-tailscale/root/usr/share/luci/menu.d/luci-app-tailscale.json

# luci-app-unblockneteasemusic
sed -i 's/解除网易云音乐播放限制/网易云音乐解锁/g' luci-app-unblockneteasemusic/root/usr/share/luci/menu.d/luci-app-unblockneteasemusic.json

# luci-app-upnp
rm -rf luci-app-upnp/po/!(templates|zh_Hans)
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-upnp/Makefile

# luci-app-vsftpd
mv immortalwrt/luci/applications/luci-app-vsftpd ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-vsftpd/Makefile

# luci-app-zerotier
sed -i 's/"order": 1050/"order": 80/g' luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json

# luci-theme-material3
rm -rf luci-theme-material3/{.git,Readme.md}

# ddns-scripts
mv immortalwrt/packages/net/ddns-scripts ./

# docker-compose
mv openwrt/packages-master/utils/docker-compose ./
sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' docker-compose/Makefile

# lsof
mv openwrt/packages-master/utils/lsof ./

# netdata
mv openwrt/packages-master/admin/netdata ./
sed -i 's/syslog/none/g' netdata/files/netdata.conf

# iperf3
mv openwrt/packages-master/net/iperf3 ./
sed -i "s/D_GNU_SOURCE/D_GNU_SOURCE -funroll-loops/g" iperf3/Makefile

# openssh
mv openwrt/packages-master/net/openssh ./

# screen
mv openwrt/packages-master/utils/screen ./

# vim
mv openwrt/packages/utils/vim ./
curl -s https://$mirror/openwrt-24.10/patch/vim/0001-vim-fix-renamed-defaults-config-file.patch | patch -p2
sed -i -E 's/(PKG_RELEASE:=)([0-9]+)/echo "\1$((\2+1))"/e' vim/Makefile

# zerotier
mv openwrt/packages-master/net/zerotier ./
rm -rf zerotier/files/etc/init.d

# zstd
mv openwrt/packages-master/utils/zstd ./

# aria2 & ariaNG
git clone https://github.com/sbwml/ariang-nginx --depth 1
rm -rf ariang-nginx/{.git,LICENSE,README.md}
mv ariang-nginx/* ./
sed -i '12d' luci-app-aria2/root/etc/uci-defaults/40_luci-aria2
git clone https://github.com/sbwml/feeds_packages_net_aria2 -b 22.03 aria2
rm -rf aria2/{.git,LICENSE,README.md}

curl -s https://$mirror/openwrt-24.10/patch/aria2/aria2.conf > aria2/files/aria2.conf

# alist
git clone https://github.com/sbwml/luci-app-openlist2 -b main op-openlist
rm -rf op-openlist/{.git,.github,README.md,install.sh}
mv op-openlist/* ./

mv immortalwrt/luci/applications/luci-app-dockerman ./
sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|' luci-app-dockerman/Makefile

git clone https://github.com/sbwml/package_new_istore -b main op-istore
rm -rf op-istore/{.git,.github,README.md,install.sh}
mv op-istore/* ./


git clone https://github.com/hxlls/luci-app-quickfile qf --depth 1
rm -rf qf/{.git,.github,README.md,install.sh}
mv qf/* ./

git clone https://github.com/destan19/OpenAppFilter OpenAppFilter --depth 1
rm -rf OpenAppFilter/{.git,.github,README.md,install.sh}
mv OpenAppFilter/* ./

git clone https://github.com/timsaya/openwrt-bandix bandix --depth 1
rm -rf bandix/{.git,.github,README.md,install.sh}

git clone https://github.com/timsaya/luci-app-bandix op-bandix --depth 1
rm -rf op-bandix/{.git,.github,*.md,install.sh,docs}
mv op-bandix/* ./

git clone https://github.com/eamonxg/luci-theme-aurora luci-theme-aurora --depth 1
rm -rf luci-theme-aurora/{.git,.github,README.md,install.sh}

git clone https://github.com/papagaye744/luci-theme-design luci-theme-design --depth 1
rm -rf luci-theme-design/{.git,.github,README.md,install.sh}

rm -rf openwrt immortalwrt openwrt-alist ariang-nginx openwrt-alist doc
ls -d */ | xargs -n 1 basename | paste -sd ' ' - > packages.txt
