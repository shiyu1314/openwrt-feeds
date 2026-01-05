#!/bin/bash -e
shopt -s extglob

# 准备环境
mkdir -p /tmp/extd/
mv */ /tmp/extd/ 2>/dev/null || true

# --- 1. 下载仓库 ---
# 基础资源池
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

# --- 2. 递归修复：多级目录上提 ---
# 逻辑：查找所有包含 Makefile 的子目录，如果它不是根目录，则提取到根部
fix_nested_dirs() {
    echo "正在修复二/三级嵌套目录..."
    # 查找所有深度在 2 到 4 层之间的 Makefile
    find . -mindepth 2 -maxdepth 4 -name "Makefile" | while read -r mk_path; do
        dir_path=$(dirname "$mk_path")
        pkg_name=$(basename "$dir_path")
        # 如果根目录不存在同名插件，则上提
        if [ ! -d "$pkg_name" ]; then
            mv "$dir_path" ./ 2>/dev/null || true
        fi
    done
}

# --- 3. 提取逻辑：基础 -> 覆盖 -> 匹配 ---

# A. 基础提取
echo "正在搬运 ImmortalWrt 基础应用..."
cp -r immortalwrt/luci/applications/* ./ 2>/dev/null || true

# B. 第三方覆盖与嵌套修复
echo "正在整合第三方插件..."
fix_nested_dirs

# 针对已知结构的特殊移动
mv ts_src ./luci-app-tailscale 2>/dev/null || true
mv samba4_src ./samba4 2>/dev/null || true

# C. 精准依赖匹配
echo "正在根据插件名精准匹配依赖包..."
for app in luci-app-*; do
    [ -d "$app" ] || continue
    dep_name=${app#luci-app-}
    
    if [ ! -d "$dep_name" ]; then
        # 在资源池中深度搜索匹配的依赖目录
        found_path=$(find immortalwrt/packages -type d -name "$dep_name" -exec test -e "{}/Makefile" \; -print -quit 2>/dev/null)
        if [ -n "$found_path" ]; then
            echo "匹配并补位依赖: $app -> $dep_name"
            cp -r "$found_path" ./
        fi
    fi
done

# --- 4. 细节修正与路径补丁 ---

# 统一修复 Makefile 中的路径引用 (核心修复)
# 将所有相对路径指向系统 feeds 路径，确保编译通过
find . -maxdepth 3 -name "Makefile" -exec sed -i \
    -e 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' \
    -e 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} +

# 清理非中文语言包
find . -path "*/po/*" ! -path "*/zh_Hans*" ! -path "*/templates*" -delete 2>/dev/null || true

# --- 5. 生成 packages.txt (含 Makefile 检查) ---
echo "正在清理并生成最终配置文件..."
rm -rf immortalwrt op-sbwml op-xd op-lucky op-ddns-go op-mosdns samba4_src ts_src

> packages.txt
for dir in */; do
    pkg=${dir%/}
    # 过滤备份目录
    [[ "$pkg" == "extd" ]] && continue
    # 核心检查：只有目录下存在 Makefile 的才写入配置
    if [ -f "${pkg}/Makefile" ]; then
        echo "CONFIG_PACKAGE_${pkg}=y" >> packages.txt
    else
        echo "跳过无效插件 (无Makefile): $pkg"
        rm -rf "$pkg" # 可选：删除不含 Makefile 的无效文件夹
    fi
done

echo "---------------------------------------------------"
echo "完成！"
echo "二级/三级嵌套已修复，所有插件均含 Makefile。"
echo "共生成 $(wc -l < packages.txt) 条有效配置。"
