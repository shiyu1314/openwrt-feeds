#!/bin/bash -e
shopt -s extglob

# 备份并整理环境
mkdir -p /tmp/extd/ && mv */ /tmp/extd/ 2>/dev/null || true

# --- 1. 工具函数 ---
gclone() { 
    git clone --depth 1 $1 $2
    [ -d "$2" ] && rm -rf "$2"/{.git,.github,*.md,LICENSE,doc,docs}
}

# --- 2. 下载第三方高优先级仓库 ---
repos=(
    "sirpdboy/luci-app-ddns-go op-ddns"
    "sbwml/openwrt_pkgs op-pkgs"
    "sbwml/luci-app-airconnect air-c"
    "sbwml/luci-app-mentohust mento"
    "sbwml/luci-app-mosdns -b v5-lua mos"
    "sbwml/luci-app-qbittorrent qbt"
    "sbwml/feeds_packages_libs_liburing liburing"
    "sbwml/feeds_packages_net_samba4 samba4"
    "sbwml/feeds_packages_utils_unzip unzip"
    "UnblockNeteaseMusic/luci-app-unblockneteasemusic"
    "asvow/luci-app-tailscale"
    "muink/openwrt-einat-ebpf einat-eb"
    "muink/luci-app-einat"
    "shiyu1314/luci-theme-material3"
    "pmkol/openwrt-eqosplus eqos"
    "pmkol/packages_net_miniupnpd upnpd"
    "pmkol/luci-app-upnp"
    "pmkol/packages_net_qosmate qm"
    "pmkol/luci-app-qosmate"
    "shiyu1314/openwrt-packages op-xd"
    "sirpdboy/luci-app-lucky lucky"
    "sbwml/ariang-nginx ariang"
    "sbwml/feeds_packages_net_aria2 -b 22.03 aria2"
    "sbwml/luci-app-openlist2 alist"
    "sbwml/package_new_istore istore"
    "hxlls/luci-app-quickfile qf"
    "destan19/OpenAppFilter oaf"
    "timsaya/openwrt-bandix bandix"
    "timsaya/luci-app-bandix op-bandix"
    "eamonxg/luci-theme-aurora"
)

for repo in "${repos[@]}"; do gclone "https://github.com/$repo"; done

# 展开嵌套插件目录
mv {op-ddns,op-pkgs,air-c,mento,mos,qbt,einat-eb,eqos,upnpd,qm,op-xd,lucky,ariang,alist,istore,qf,oaf,bandix,op-bandix}/*/ ./ 2>/dev/null || true

# --- 3. 从 ImmortalWrt 自动提取所有补位插件 ---
git clone --depth 1 https://github.com/immortalwrt/luci -b master imm_luci
git clone --depth 1 https://github.com/immortalwrt/packages -b master imm_pkgs

# 自动补位函数：本地没有就从资源池搬运
for d in imm_luci/applications/*/ imm_pkgs/net/*/ imm_pkgs/utils/*/ imm_pkgs/admin/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    [ ! -d "$name" ] && mv "$d" ./
done

# --- 4. 批量执行补丁与清理 ---
# 统一 Makefile 路径修正
find . -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 批量清理非中文多语言
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete

# 关键细节修正
[ -d "samba4" ] && sed -i '/workgroup/a \\tserver multi channel support = yes' samba4/files/smb.conf.template
[ -d "luci-app-tailscale" ] && sed -i 's/"order": 90/"order": 80/g; s/vpn/services/g' luci-app-tailscale/root/usr/share/luci/menu.d/*.json

# --- 5. 生成 packages.txt 配置文件 ---
rm -rf imm_luci imm_pkgs op-ddns op-pkgs air-c mento mos qbt einat-eb eqos upnpd qm op-xd lucky ariang alist istore qf oaf bandix op-bandix

> packages.txt
for dir in */; do
    pkg=${dir%/}
    # 排除备份目录和系统目录
    [[ "$pkg" == "extd" || "$pkg" == "logs" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "完成！配置已写入 packages.txt，共 $(wc -l < packages.txt) 个包。"
