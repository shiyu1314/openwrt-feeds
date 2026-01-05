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
)

echo "正在下载第三方插件..."
for repo in "${repos[@]}"; do gclone "https://github.com/$repo"; done
mv {op-ddns,op-pkgs,air-c,mos,qbt,op-xd,lucky}/*/ ./ 2>/dev/null || true

# 3. 精准依赖匹配提取 (从 ImmortalWrt)
echo "正在匹配并提取底层依赖包..."
git clone --depth 1 https://github.com/immortalwrt/luci -b master imm_luci
git clone --depth 1 https://github.com/immortalwrt/packages -b master imm_pkgs

# 获取当前目录下所有 luci-app-xxx 的 xxx 部分
for app in luci-app-*; do
    [ -d "$app" ] || continue
    # 提取依赖名：例如从 luci-app-3cat 提取出 3cat
    dep_name=${app#luci-app-}
    
    # 在 ImmortalWrt packages 资源池中寻找匹配的底层依赖目录
    # 搜索范围：net, utils, admin, lang, libs
    found_path=$(find imm_pkgs/{net,utils,admin,lang,libs} -maxdepth 1 -type d -name "$dep_name" -print -quit 2>/dev/null)
    
    if [ -n "$found_path" ]; then
        if [ ! -d "$dep_name" ]; then
            echo "发现匹配依赖: $app -> $dep_name"
            mv "$found_path" ./
        fi
    fi
done

# 4. 自动化补丁与 Makefile 修正
find . -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 清理非中文多语言
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete

# 5. 生成按需配置的 packages.txt
rm -rf imm_luci imm_pkgs op-ddns op-pkgs air-c mos qbt op-xd lucky

> packages.txt
for dir in */; do
    pkg=${dir%/}
    [[ "$pkg" == "extd" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "---------------------------------------------------"
echo "完成！已根据现有 Luci 插件精准匹配并提取了底层依赖包。"
echo "生成配置总数: $(wc -l < packages.txt)"
