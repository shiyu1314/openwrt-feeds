#!/bin/bash -e

# backup feeds
mkdir -p /tmp/extd/
mv */ /tmp/extd/ 2>/dev/null || true

# clone ImmortalWrt feeds
echo "Cloning ImmortalWrt feeds..."
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1

# extract all content
echo "Extracting packages..."
cp -r immortalwrt/luci/applications/* ./
cp -r immortalwrt/packages/*/* ./

# comprehensive Makefile path fixing
echo "Fixing Makefile paths..."
find . -name "Makefile" -type f | while read -r makefile; do
    echo "  Processing: $makefile"
    
    # Create backup
    cp "$makefile" "$makefile.bak"
    
    # Replace all relative paths with absolute feeds paths
    sed -i '
        # Replace ../../luci.mk
        s|\.\./\.\./luci\.mk|$(TOPDIR)/feeds/luci/luci.mk|g
        
        # Replace ../luci.mk  
        s|\.\./luci\.mk|$(TOPDIR)/feeds/luci/luci.mk|g
        
        # Replace ../../lang
        s|\.\./\.\./lang|$(TOPDIR)/feeds/packages/lang|g
        
        # Replace ../lang
        s|\.\./lang|$(TOPDIR)/feeds/packages/lang|g
        
        # Replace include ../../luci.mk
        s|include \.\./\.\./luci\.mk|include $(TOPDIR)/feeds/luci/luci.mk|g
        
        # Replace include ../luci.mk
        s|include \.\./luci\.mk|include $(TOPDIR)/feeds/luci/luci.mk|g
        
        # Replace other common relative paths
        s|\.\./\.\./packages/|$(TOPDIR)/feeds/packages/|g
        s|\.\./packages/|$(TOPDIR)/feeds/packages/|g
        s|\.\./\.\./kernel/|$(TOPDIR)/feeds/kernel/|g
        s|\.\./\.\./base/|$(TOPDIR)/feeds/base/|g
        s|\.\./\.\./net/|$(TOPDIR)/feeds/packages/net/|g
        s|\.\./\.\./utils/|$(TOPDIR)/feeds/packages/utils/|g
        s|\.\./\.\./admin/|$(TOPDIR)/feeds/packages/admin/|g
        
        # Fix multiple levels of ../
        s|\.\./\.\./\.\./|$(TOPDIR)/|g
        s|\.\./\.\./|$(TOPDIR)/feeds/|g
    ' "$makefile"
    
    # Remove backup if successful
    rm -f "$makefile.bak"
done

# Additional fix for specific package types
echo "Applying specific fixes..."

# Fix luci-app-* packages
for app in luci-app-*/Makefile; do
    if [ -f "$app" ]; then
        sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' "$app"
    fi
done

# Fix package Makefiles
for pkg in */Makefile; do
    if [ -f "$pkg" ]; then
        sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' "$pkg"
    fi
done

# clean up
rm -rf immortalwrt

# verify and generate list
echo "Verifying packages..."
for dir in */; do
    if [ -f "$dir/Makefile" ]; then
        echo "✓ $dir"
    else
        echo "✗ $dir (no Makefile)"
    fi
done | sort > packages.txt

echo "=========================================="
echo "Extraction completed!"
echo "Total packages extracted: $(ls -d */ | wc -l)"
echo "Packages list saved to: packages.txt"
echo "=========================================="
