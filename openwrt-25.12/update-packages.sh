#!/bin/bash -e
shopt -s extglob

# 1. 环境初始化
mkdir -p /tmp/extd/ && mv */ /tmp/extd/ 2>/dev/null || true

# 工具函数：克隆并清理
gclone() { 
    git clone --depth 1 $1 $2
    [ -d "$2" ] && rm -rf "$2"/{.git,.github,*.md,LICENSE}
}

# 2. 下载第三方高优先级仓库 (此处为你指定的核心插件)
repos=(
    "sirpdboy/luci-app-ddns-go op-ddns"
    "sbwml/openwrt_pkgs op-pkgs"
    "sbwml/luci-app-airconnect air-c"
    "sbwml/luci-app-mosdns -b v5-lua mos"
    "sbwml/luci-app-qbittorrent qbt"
    "UnblockNeteaseMusic/luci-app-unblockneteasemusic"
    "asvow/luci-app-tailscale"
    "shiyu1314/openwrt-packages op-xd"
    "sirpdboy/luci-app-lucky lucky"
    "sbwml/feeds_packages_libs_liburing liburing"
    "sbwml/feeds_packages_net_samba4 samba4"
)

echo "正在下载第三方插件..."
for repo in "${repos[@]}"; do gclone "https://github.com/$repo"; done

# 展开嵌套目录到根目录
mv {op-ddns,op-pkgs,air-c,mos,qbt,op-xd,lucky}/*/ ./ 2>/dev/null || true

# 3. 精准依赖匹配提取 (从 ImmortalWrt)
echo "正在从 ImmortalWrt 匹配并提取底层依赖包..."
git clone --depth 1 https://github.com/immortalwrt/luci -b master imm_luci
git clone --depth 1 https://github.com/immortalwrt/packages -b master imm_pkgs

# 逻辑：遍历当前所有已存在的目录
for app in */; do
    app=${app%/}
    # 针对 luci-app-xxx，提取其可能的底层依赖名 xxx
    if [[ "$app" == luci-app-* ]]; then
        dep_name=${app#luci-app-}
        
        # 如果本地还没有对应的底层包，则去资源池中寻找
        if [ ! -d "$dep_name" ]; then
            # 强化搜索：在 packages 库的所有子目录中寻找同名文件夹
            found_path=$(find imm_pkgs -type d -name "$dep_name" -print -quit 2>/dev/null)
            
            if [ -n "$found_path" ]; then
                echo "精准匹配依赖: $app -> $dep_name"
                cp -r "$found_path" ./
            fi
        fi
    fi
done

# 4. 关键细节修正 (保留你原始脚本中的特殊 sed 逻辑)
# 修正 Makefile 路径
find . -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 修正具体插件逻辑
[ -d "adguardhome" ] && sed -i 's/Arch="arm"/Arch="armv7"/' adguardhome/root/usr/share/AdGuardHome/update_core.sh 2>/dev/null || true
[ -d "samba4" ] && sed -i '/workgroup/a \\tserver multi channel support = yes' samba4/files/smb.conf.template 2>/dev/null || true

# 清理非中文语言包
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete

# 5. 生成 packages.txt 并清理
rm -rf imm_luci imm_pkgs op-ddns op-pkgs air-c mos qbt op-xd lucky

> packages.txt
for dir in */; do
    pkg=${dir%/}
    [[ "$pkg" == "extd" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "---------------------------------------------------"
echo "检查完成！依赖已匹配，配置已生成至 packages.txt。"
