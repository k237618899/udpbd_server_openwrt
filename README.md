# OpenWrt UDPBD Server

[![Build and Release](https://github.com/yumanuralfath/udpbd_server_openwrt/actions/workflows/release.yml/badge.svg)](https://github.com/yourusername/udpbd-server-openwrt/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

UDP Block Device (UDPBD) server for OpenWrt routers, providing high-performance network block device access for PlayStation 2 and other compatible clients.

## ⭐ Credits & Stars

**Please give a star to the original project:**

- 🌟 **Original UDPBD Server:** [ps2max/udpbd-server](https://gitlab.com/ps2max/udpbd-server.git)

**Also consider starring this OpenWrt port:**

- 🌟 **This Repository:** Click the ⭐ button above!

## 🎮 PlayStation 2 Compatibility

This UDPBD server works with **UDPBD-enabled Open PS2 Loader (OPL)** builds:

### Compatible OPL Version

- **OPL-UDPBD-1973**: [Download from MediaFire](https://www.mediafire.com/file/v0pyp49pmh3sr3v/OPNPS2LD-v1.2.0-Beta-1973-88079d7-UDPBD.ZIP/file)

> **Note:** Standard OPL releases do NOT support UDPBD. You must use a UDPBD-enabled build.

## 🚀 Quick Start

### Option 1: Download Pre-built IPK (Recommended)

1. **Download IPK** from [Releases](../../releases)
2. **Install on OpenWrt:**

   ```bash
   # Copy to router
   scp udpbd-server_*.ipk root@your-router:/tmp/

   # Install
   opkg install /tmp/udpbd-server_*.ipk
   ```

3. **Run the server:**

   ```bash
   # Serve USB drive
   udpbd-server /dev/sda1

   # Or serve ISO file
   udpbd-server /mnt/storage/game.iso
   ```

### Option 2: Fork & Build with GitHub Actions

1. **Fork this repository**
2. **Modify SDK targets** in `.github/workflows/build.yml` if needed
3. **Create a release tag:**

   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

4. **Download built IPKs** from the Actions artifacts or Releases

### Option 3: Manual Compilation

#### Prerequisites

- OpenWrt SDK for your target architecture
- Linux build environment

#### Build Steps

```bash
# Download OpenWrt SDK (example for ramips mt76x8)
wget https://downloads.openwrt.org/releases/19.07.9/targets/ramips/mt76x8/openwrt-sdk-19.07.9-ramips-mt76x8_gcc-7.5.0_musl.Linux-x86_64.tar.xz
tar -xf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*

# Clone this repository into package directory
git clone https://github.com/yourusername/udpbd-server-openwrt.git package/udpbd-server

# Update feeds and install dependencies
./scripts/feeds update
./scripts/feeds install libstdcpp

# Configure and build
echo "CONFIG_PACKAGE_libstdcpp=y" >> .config
make defconfig
make package/udpbd-server/compile V=s

# Find your IPK file
find bin/packages -name "udpbd-server_*.ipk"
```

## 🔧 Configuration

### Service Configuration

Edit `/etc/config/udpbd-server`:

```bash
config udpbd 'main'
    option enabled '1'
    option device '/dev/sda1'

# Multiple instances:
config udpbd 'usb'
    option enabled '1'
    option device '/dev/sda1'

config udpbd 'sdcard'
    option enabled '0'
    option device '/dev/mmcblk0p1'
```

### Service Management

```bash
# Enable and start service
/etc/init.d/udpbd-server enable
/etc/init.d/udpbd-server start

# Stop service
/etc/init.d/udpbd-server stop

# Check status
ps | grep udpbd-server
netstat -un | grep 48573
```

## 🎮 PS2 Setup Guide

### 1. Hardware Requirements

- PlayStation 2 with Network Adapter
- OpenWrt router with USB storage
- Network connection between PS2 and router

### 2. Install UDPBD-enabled OPL

- Download: [OPL-UDPBD-1973](https://www.mediafire.com/file/v0pyp49pmh3sr3v/OPNPS2LD-v1.2.0-Beta-1973-88079d7-UDPBD.ZIP/file)
- Install to PS2 memory card or HDD

### 3. Network Configuration

In OPL's Network Settings:

- **Server IP**: `192.168.1.1` (your router IP)
- **Port**: `48573` (0xBDBD)
- **Protocol**: UDPBD/NBD

### 4. Storage Options

#### USB Drive

```bash
udpbd-server /dev/sda1
```

#### Individual ISO

```bash
udpbd-server /mnt/storage/game.iso
```

#### Image File

```bash
# Create test image
dd if=/dev/zero of=/tmp/test.img bs=1M count=100
udpbd-server /tmp/test.img
```

## 🌐 Supported OpenWrt Targets

The GitHub Actions automatically builds for:

- **ramips/mt76x8** (mipsel_24kc) - OpenWrt 19.07.9, 22.03.5, 23.05.3
- **ramips/mt7621** (mipsel_24kc) - OpenWrt 22.03.5

### Add Your Target

Edit `.github/workflows/build.yml` and add your target to the matrix:

```yaml
- {
    version: "22.03.5",
    arch: "ath79",
    subarch: "generic",
    pkg_arch: "mips_24kc",
  }
```

## 🔍 Troubleshooting

### Check Server Status

```bash
# Verify server is running
ps | grep udpbd-server
netstat -un | grep 48573

# Monitor connections
tcpdump -i any port 48573
```

### Test Connectivity

```bash
# From another Linux machine
echo -ne '\x00\x01\x00' | nc -u router-ip 48573
```

### Common Issues

**"Permission denied" errors:**

```bash
# Check device permissions
ls -l /dev/sda1

# Run with correct user
sudo udpbd-server /dev/sda1
```

**"Address already in use":**

```bash
# Kill existing instance
killall udpbd-server

# Check what's using the port
netstat -unlp | grep 48573
```

**PS2 can't connect:**

- Verify OPL is UDPBD-enabled build
- Check network configuration
- Ensure firewall allows UDP port 48573

## 📋 Technical Details

- **Protocol**: UDPBD v2
- **Port**: 48573 (0xBDBD)
- **Transport**: UDP
- **Block Size**: Adaptive (32-512 bytes)
- **Max Transfer**: 512 sectors (256KB) per request

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with your OpenWrt target
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **ps2max** - Original UDPBD server implementation
- **OpenWrt Community** - SDK and build system
- **OPL Developers** - UDPBD integration in Open PS2 Loader

---

**⚡ Performance Tip:** Use wired Ethernet connection for best performance. Wi-Fi may introduce latency and packet loss affecting game loading times.

**🎯 Pro Tip:** For best PS2 compatibility, use FAT32 formatted USB drives and serve the entire block device (`/dev/sda1`) rather than individual files.

