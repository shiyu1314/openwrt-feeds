#!/bin/bash -e
shopt -s extglob

# 1. 环境初始化
mkdir -p /tmp/extd/ && mv */ /tmp/extd/ 2>/dev/null || true

# 工具函数：克隆并清理
gclone() { 
    git clone --depth 1 $1 $2
    [ -d "$2" ] && rm -rf "$2"/{.git,.github,*.md,LICENSE,doc,docs}
}

# 2. 下载第三方高优先级仓库 (原脚本清单)
repos=(
    "sirpdboy/luci-app-ddns-go op-ddns"
    "sbwml/openwrt_pkgs op-pkgs"
    "sbwml/luci-app-airconnect air-c"
    "sbwml/luci-app-mosdns -b v5-lua mos"
    "sbwml/luci-app-qbittorrent qbt"
    "sbwml/feeds_packages_libs_liburing liburing"
    "sbwml/feeds_packages_net_samba4 samba4"
    "UnblockNeteaseMusic/luci-app-unblockneteasemusic"
    "asvow/luci-app-tailscale"
    "shiyu1314/openwrt-packages op-xd"
    "sirpdboy/luci-app-lucky lucky"
    "sbwml/luci-app-openlist2 alist"
    "sbwml/package_new_istore istore"
    "timsaya/openwrt-bandix bandix"
    "eamonxg/luci-theme-aurora"
)

echo "正在下载第三方插件..."
for repo in "${repos[@]}"; do gclone "https://github.com/$repo"; done

# 展开嵌套目录
mv {op-ddns,op-pkgs,air-c,mos,qbt,op-xd,lucky,alist,istore,bandix}/*/ ./ 2>/dev/null || true

# 3. 从 ImmortalWrt 资源池自动补位 (Luci + Packages)
echo "正在从 ImmortalWrt 仓库提取补位依赖..."
git clone --depth 1 https://github.com/immortalwrt/luci -b master imm_luci
git clone --depth 1 https://github.com/immortalwrt/packages -b master imm_pkgs

# 自动补位逻辑：只要当前目录没有，就从这些分类中提取
# 涵盖了常用的 net, utils, admin, lang, libs 分类
for d in imm_luci/applications/*/ imm_pkgs/net/*/ imm_pkgs/utils/*/ imm_pkgs/admin/*/ imm_pkgs/lang/*/ imm_pkgs/libs/*/; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    if [ ! -d "$name" ]; then
        mv "$d" ./
    fi
done

# 4. 自动化补丁修正
# 统一修正 Makefile 路径
find . -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 清理非中文多语言
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete

# 5. 生成 packages.txt 并清理多余文件
rm -rf imm_luci imm_pkgs op-ddns op-pkgs air-c mos qbt op-xd lucky alist istore bandix

> packages.txt
for dir in */; do
    pkg=${dir%/}
    # 过滤掉系统保留目录和临时备份目录
    [[ "$pkg" == "extd" || "$pkg" == "logs" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "---------------------------------------------------"
echo "完成！生成包总数: $(wc -l < packages.txt)"
echo "已优先保留第三方插件，并从 ImmortalWrt 补齐了依赖插件名。"
