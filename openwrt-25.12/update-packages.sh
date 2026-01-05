#!/bin/bash -e
shopt -s extglob

# 备份原 feed
mkdir -p /tmp/extd/
mv */ /tmp/extd/ 2>/dev/null || true

# --- 1. 下载核心与第三方仓库 ---
# 使用 depth 1 加速下载
git clone https://github.com/openwrt/luci openwrt/luci -b openwrt-24.10 --depth 1
git clone https://github.com/openwrt/packages openwrt/packages -b openwrt-24.10 --depth 1
git clone https://github.com/openwrt/packages openwrt/packages-master -b master --depth 1
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1

# 独立插件下载
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
git clone https://github.com/shiyu1314/luci-theme-material3 --depth 1
git clone https://github.com/pmkol/openwrt-eqosplus --depth 1
git clone https://github.com/pmkol/packages_net_miniupnpd miniupnpd --depth 1
git clone https://github.com/pmkol/luci-app-upnp --depth 1
git clone https://github.com/pmkol/packages_net_qosmate qosmate --depth 1
git clone https://github.com/pmkol/luci-app-qosmate --depth 1
git clone https://github.com/shiyu1314/openwrt-packages op-xd --depth 1
git clone https://github.com/sirpdboy/luci-app-lucky op-lucky -b main --depth 1

# --- 2. 初始清理与目录展开 ---
rm -rf op-xd/{luci-lib-taskd,luci-lib-xterm,luci-app-adguardhome,.git}
rm -rf openwrt_pkgs/{bash-completion,luci-app-ota,fw_download_tool}
rm -rf {liburing,unzip,einat-ebpf,miniupnpd,qosmate,op-lucky}/.git
# 展开第三方包
mv op-lucky/*/ ./ 2>/dev/null || true
mv op-xd/*/ ./ 2>/dev/null || true
mv openwrt_pkgs/*/ ./ 2>/dev/null || true
mv openwrt-ddns-go/*/ ./ 2>/dev/null || true
mv openwrt-airconnect/*/ ./ 2>/dev/null || true
mv openwrt-mentohust/*/ ./ 2>/dev/null || true
mv openwrt-mosdns/*/ ./ 2>/dev/null || true
mv openwrt-qbittorrent/*/ ./ 2>/dev/null || true
mv openwrt-eqosplus/*/ ./ 2>/dev/null || true

# --- 3. 精准匹配 ImmortalWrt 依赖补位 ---
# 逻辑：遍历当前 luci-app-xxx，去 immortalwrt/packages 找同名 xxx
for app_dir in luci-app-*; do
    [ -d "$app_dir" ] || continue
    dep_name=${app_dir#luci-app-}
    # 如果本地没有底层包，则去补位
    if [ ! -d "$dep_name" ]; then
        found=$(find immortalwrt/packages -maxdepth 3 -type d -name "$dep_name" -print -quit)
        if [ -n "$found" ]; then
            cp -r "$found" ./
            echo "匹配并补位依赖: $dep_name"
        fi
    fi
done

# --- 4. 原始代码中的特定逻辑修正 ---

# AdGuardHome
mv openwrt/packages-master/net/adguardhome ./ 2>/dev/null || true
if [ -d "adguardhome" ]; then
    sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' adguardhome/Makefile
    sed -i '73,83d' adguardhome/Makefile
    [ -f "openwrt_pkgs/luci-app-adguardhome/root/usr/share/AdGuardHome/update_core.sh" ] && \
    sed -i 's/Arch="arm"/Arch="armv7"/' openwrt_pkgs/luci-app-adguardhome/root/usr/share/AdGuardHome/update_core.sh
fi

# 其他特定移动 (保留原代码逻辑)
[ -d "immortalwrt/luci/applications/luci-app-cifs-mount" ] && mv immortalwrt/luci/applications/luci-app-cifs-mount ./
[ -d "immortalwrt/luci/applications/luci-app-dufs" ] && mv immortalwrt/luci/applications/luci-app-dufs ./
[ -d "immortalwrt/packages/net/dufs" ] && mv immortalwrt/packages/net/dufs ./

# 处理 Samba4 模板 (原代码细节)
if [ -d "samba4" ]; then
    sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|' samba4/Makefile
    sed -i '/workgroup/a \\n\t## enable multi-channel\n\tserver multi channel support = yes' samba4/files/smb.conf.template
    sed -i 's/invalid users = root/#invalid users = root/g' samba4/files/smb.conf.template
fi

# 统一修正所有 Makefile 和 语言清理
find . -name "Makefile" -exec sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {} +
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete 2>/dev/null || true

# --- 5. 生成 packages.txt (CONFIG_PACKAGE_xxx=y) ---
rm -rf openwrt immortalwrt op-xd openwrt_pkgs openwrt-ddns-go openwrt-airconnect openwrt-mentohust openwrt-mosdns openwrt-qbittorrent openwrt-eqosplus

> packages.txt
for dir in */; do
    pkg=${dir%/}
    # 过滤非插件目录
    [[ "$pkg" == "extd" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "完成！已按需补位并生成 packages.txt。"
