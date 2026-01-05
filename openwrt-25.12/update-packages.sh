#!/bin/bash -e
shopt -s extglob

# 准备环境
mkdir -p /tmp/extd/
mv */ /tmp/extd/ 2>/dev/null || true

# --- 1. 下载仓库 (删除所有 openwrt 官方引用) ---
# 基础池：ImmortalWrt
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1

# 第三方仓库 (高优先级)
git clone https://github.com/sirpdboy/luci-app-ddns-go op-ddns-go --depth 1
git clone https://github.com/sbwml/openwrt_pkgs op-sbwml --depth 1
git clone https://github.com/sbwml/luci-app-mosdns op-mosdns -b v5-lua --depth 1
git clone https://github.com/shiyu1314/openwrt-packages op-xd --depth 1
git clone https://github.com/sirpdboy/luci-app-lucky op-lucky --depth 1
git clone https://github.com/sbwml/feeds_packages_net_samba4 samba4_src --depth 1
git clone https://github.com/asvow/luci-app-tailscale ts_src --depth 1

# --- 2. 提取逻辑：基础 -> 覆盖 -> 匹配 ---

# A. 基础提取：先搬运 ImmortalWrt 所有的应用
echo "正在搬运 ImmortalWrt 基础应用..."
cp -r immortalwrt/luci/applications/* ./ 2>/dev/null || true

# B. 第三方覆盖：用高优先级的第三方版本替换/补充
echo "正在使用第三方插件覆盖..."
mv op-sbwml/*/ ./ 2>/dev/null || true
mv op-xd/*/ ./ 2>/dev/null || true
mv op-lucky/*/ ./ 2>/dev/null || true
mv op-ddns-go/*/ ./ 2>/dev/null || true
mv op-mosdns/*/ ./ 2>/dev/null || true
mv samba4_src ./samba4 2>/dev/null || true
mv ts_src ./luci-app-tailscale 2>/dev/null || true

# C. 精准依赖匹配：根据 luci-app-xxx 匹配对应的 xxx 底层包
echo "正在根据插件名精准匹配依赖包..."
for app in luci-app-*; do
    [ -d "$app" ] || continue
    # 提取依赖名，例如从 luci-app-3cat 提取 3cat
    dep_name=${app#luci-app-}
    
    # 如果当前目录还没有这个底层包，则去 immortalwrt/packages 补位
    if [ ! -d "$dep_name" ]; then
        found_path=$(find immortalwrt/packages -type d -name "$dep_name" -print -quit 2>/dev/null)
        if [ -n "$found_path" ]; then
            echo "匹配到依赖补位: $app -> $dep_name"
            cp -r "$found_path" ./
        fi
    fi
done

# --- 3. 细节修正与清理 (保留原代码 Sed 逻辑) ---

# 统一修正 Makefile 的核心路径引用
find . -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 特殊包修正 (如 Samba4 多通道)
[ -d "samba4" ] && {
    sed -i '/workgroup/a \\tserver multi channel support = yes' samba4/files/smb.conf.template
    sed -i 's/invalid users = root/#invalid users = root/g' samba4/files/smb.conf.template
}

# 清理非中文语言包，减小体积
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete 2>/dev/null || true

# --- 4. 生成配置与收尾 ---
# 清理下载用的临时源码目录
rm -rf immortalwrt op-sbwml op-xd op-lucky op-ddns-go op-mosdns samba4_src ts_src

# 生成 CONFIG_PACKAGE_xxx=y
> packages.txt
for dir in */; do
    pkg=${dir%/}
    # 排除备份目录
    [[ "$pkg" == "extd" ]] && continue
    echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
done

echo "---------------------------------------------------"
echo "完成！源码已从 ImmortalWrt 与第三方仓库整合完毕。"
echo "共生成 $(wc -l < packages.txt) 个插件配置到 packages.txt。"
