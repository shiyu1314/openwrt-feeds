#!/bin/bash -e

# backup feeds
mkdir -p /tmp/extd/
mv */ /tmp/extd/ 2>/dev/null || true

# clone ImmortalWrt feeds
git clone https://github.com/immortalwrt/luci immortalwrt/luci -b master --depth 1
git clone https://github.com/immortalwrt/packages immortalwrt/packages -b master --depth 1

# extract all luci applications
cp -r immortalwrt/luci/applications/* ./

# function to extract dependencies from Makefile
extract_deps_from_makefile() {
    local makefile=$1
    if [ -f "$makefile" ]; then
        # look for DEPENDS lines and extract package names
        grep -E '^DEPENDS:?=' "$makefile" | sed 's/DEPENDS:?=//g' | \
        tr ' +' '\n' | grep -v '^$' | sed 's/^@[A-Z]* //g' | \
        sed 's/^!//g' | cut -d':' -f1 | sort -u
    fi
}

# main dependency extraction
for luci_app in luci-app-*; do
    if [ -d "$luci_app" ] && [ -f "$luci_app/Makefile" ]; then
        echo "Processing $luci_app..."
        
        # get dependencies from luci app Makefile
        deps=$(extract_deps_from_makefile "$luci_app/Makefile")
        
        # extract each dependency package
        for dep in $deps; do
            # clean dependency name (remove luci-app- prefix if present)
            clean_dep=${dep#luci-app-}
            
            # search for package in immortalwrt/packages
            found=$(find immortalwrt/packages -type d -name "$clean_dep" -o -type d -name "luci-app-$clean_dep")
            if [ -n "$found" ]; then
                echo "  Found dependency: $clean_dep"
                cp -r $found ./
            fi
        done
        
        # also try to find package with same base name
        base_pkg=${luci_app#luci-app-}
        find immortalwrt/packages -type d -name "$base_pkg" -exec cp -r {} . \; 2>/dev/null
    fi
done

# fix Makefile paths
find . -name "Makefile" -type f -exec sed -i 's|../../luci.mk|$(TOPDIR)/feeds/luci/luci.mk|g' {} \;
find . -name "Makefile" -type f -exec sed -i 's|../../lang|$(TOPDIR)/feeds/packages/lang|g' {} \;

rm -rf immortalwrt
ls -d */ > packages.txt
echo "Extraction completed. Packages list saved to packages.txt"
