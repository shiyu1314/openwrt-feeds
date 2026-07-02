# Luci Theme Design

<div align="center">

<p align="center">
  <img src="https://img.shields.io/badge/OpenWrt-25.12-blue?style=for-the-badge&logo=openwrt&logoColor=white" alt="OpenWrt">
  <img src="https://img.shields.io/badge/LuCI-Design-323738?style=for-the-badge&logo=linux&logoColor=white" alt="LuCI">
  <img src="https://img.shields.io/badge/Version-7.1-orange?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-Apache--2.0-green?style=for-the-badge" alt="License">
</p>

**A modern, flat-design theme for OpenWrt LuCI interface**  
*Clean, responsive, and professional looking for your router.*

</div>

---

## 📖 Introduction

**Luci-theme-design** is a customized theme for the OpenWrt LuCI web interface. It aims to provide a modern, user-friendly visual experience with a flat design language, smooth transitions, and improved mobile responsiveness.

## ✨ Features

| Feature | Description |
| :--- | :--- |
| **Modern UI/UX** | Flat design style with carefully crafted color palette and typography. |
| **Responsive Design** | Fully adapted for mobile devices, tablets, and desktops. |
| **Smooth Animations** | Refined transitions and hover effects for a polished experience. |
| **Dark/Light Support** | Built-in support for different display preferences. |
| **High Compatibility** | Compatible with OpenWrt 25.12 and latest LuCI versions. |
| **Font Optimization** | Includes high-quality fonts (GenJyuu Gothic, Cocon) for better readability. |

## 📦 Installation

### Method 1: Build from Source (Recommended)

This method integrates the theme into your firmware image.

```bash
# 1. Clone the repository to your package download folder
cd <your_openwrt_source>/package/feeds/luci
git clone https://github.com/MomoFlora/luci-theme-design.git
```

```bash
# 2. Configure OpenWrt
make menuconfig
# Navigate to: LuCI -> Themes -> Select luci-theme-design as <*> or <M>
```

```bash
# 3. Compile
make package/feeds/luci/luci-theme-design/compile V=s
```

### Method 2: Compile Standalone Package

If you just want the `.ipk` file for your specific architecture using the SDK:

1.  Download the OpenWrt SDK for your target.
2.  Extract and enter the SDK directory.
3.  Clone the theme into `package/luci-theme-design`.
4.  Run `make defconfig` and `make package/luci-theme-design/compile V=s`.
5.  Find the `.ipk` in `bin/packages/.../base/`.

## 🚀 Usage

After installing the `.ipk` or flashing the firmware:

1.  Log in to your LuCI interface.
2.  Go to **System** > **Software** (if installed manually) to verify the package.
3.  Go to **System** > **System** > **Language and Style**.
4.  Change **Design** to `luci-theme-design`.
5.  Click **Save & Apply**.

## 🎨 Screenshots

### Desktop View
> *(To be provided: Screenshot of the login page and dashboard)*

### Mobile View
> *(To be provided: Screenshot of the responsive layout on a mobile device)*

## 🛠 Troubleshooting

-   **Missing CSS/Images**: Ensure `luci-theme-design` is selected as the default theme in **System** > **System** > **Language and Style**.
-   **Build Errors**: Ensure your OpenWrt SDK matches the version required by this branch (`openwrt-25.12`).
-   **Browser Compatibility**: Modern browsers (Chrome, Firefox, Edge, Safari) are fully supported.

## 📄 License

This project is licensed under the **Apache-2.0 License**. See the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/MomoFlora/luci-theme-design/issues).

## 🙏 Credits

-   Based on the original `luci-theme-design` for OpenWrt.
-   Inspired by modern web design standards.

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/MomoFlora">MomoFlora</a></sub>
</div>
