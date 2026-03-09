# ZeroClaw OpenWrt Package

This directory contains the OpenWrt package definition for ZeroClaw, allowing you to build `.ipk` packages for ARM-based OpenWrt devices.

## Features

- Cross-compilation for various ARM architectures (Cortex-A53, Cortex-A7, Cortex-A9)
- Automatic GitHub Actions workflow for building packages
- Proper init script for OpenWrt service management
- Default configuration optimized for embedded devices

## Supported Architectures

- `aarch64_cortex-a53` (64-bit ARMv8)
- `arm_cortex-a7_neon-vfpv4` (32-bit ARMv7 with NEON)
- `arm_cortex-a9` (32-bit ARMv7)

## GitHub Actions Workflow

The repository includes a GitHub Actions workflow (`.github/workflows/build-openwrt-ipk.yml`) that automatically builds ZeroClaw IPK packages when:

1. **Push to main/master branch** (automatic build for all supported architectures)
2. **Pull request** (builds for verification)
3. **Manual trigger** (workflow_dispatch with architecture selection)

### Manual Trigger

To manually trigger a build:

1. Go to the "Actions" tab in your GitHub repository
2. Select "Build OpenWrt IPK for ARM"
3. Click "Run workflow"
4. Select target architecture and OpenWrt version
5. Click "Run workflow"

## Package Structure

```
zeroclaw-openwrt/
├── Makefile              # OpenWrt package definition
├── files/
│   ├── config.toml      # Default configuration
│   └── zeroclaw.init    # OpenWrt init script
└── README.md            # This file
```

## Installation on OpenWrt Device

### Method 1: Using opkg (if you have internet access)

```bash
# Add your repository (if you host the IPK files)
echo "src/gz myrepo https://your-domain.com/packages" >> /etc/opkg/customfeeds.conf
opkg update
opkg install zeroclaw
```

### Method 2: Manual Installation

```bash
# Copy IPK to device (e.g., using scp)
scp zeroclaw-*.ipk root@openwrt-device:/tmp/

# Install on device
opkg install /tmp/zeroclaw-*.ipk
```

### Method 3: From GitHub Actions Artifacts

1. Download the IPK file from the GitHub Actions artifacts
2. Transfer to your OpenWrt device
3. Install with `opkg install /path/to/zeroclaw.ipk`

## Post-Installation Setup

After installation, you need to configure ZeroClaw:

```bash
# Run the onboarding wizard
zeroclaw onboard --interactive

# Or use environment variables for automated setup
export ZEROCLAW_API_KEY="your-api-key"
export ZEROCLAW_PROVIDER="openrouter"
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider "$ZEROCLAW_PROVIDER"
```

## Service Management

ZeroClaw installs as a service on OpenWrt:

```bash
# Start the service
/etc/init.d/zeroclaw start

# Stop the service
/etc/init.d/zeroclaw stop

# Enable auto-start on boot
/etc/init.d/zeroclaw enable

# Check status
/etc/init.d/zeroclaw status
```

## Configuration Files

- **Main config**: `/etc/zeroclaw/config.toml`
- **Data directory**: `/var/lib/zeroclaw/`
- **Log directory**: `/var/log/zeroclaw/`

## Building Locally

If you want to build the package locally:

```bash
# 1. Download the appropriate OpenWrt SDK for your target
# 2. Extract the SDK
tar -xf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*

# 3. Copy the zeroclaw-openwrt directory to package/
cp -r /path/to/zeroclaw-openwrt package/

# 4. Update feeds and configure
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig  # Select zeroclaw under Utilities

# 5. Build the package
make package/zeroclaw/compile V=s
```

## Dependencies

ZeroClaw requires the following OpenWrt packages:
- `libc`
- `libstdcpp`
- `libopenssl`
- `ca-bundle`

These are automatically handled by the package definition.

## Troubleshooting

### Build Issues

1. **Rust cross-compilation fails**: Ensure you have the Rust toolchain installed in the build environment
2. **Missing dependencies**: Check that all build dependencies are installed (see workflow file)
3. **SDK download fails**: The SDK URLs might change. Check the OpenWrt downloads page for updated URLs.

### Runtime Issues

1. **Service won't start**: Check logs at `/var/log/zeroclaw/`
2. **Permission issues**: Ensure `/var/lib/zeroclaw` and `/var/log/zeroclaw` are writable
3. **Configuration errors**: Run `zeroclaw doctor` to diagnose issues

## Contributing

To modify the package:

1. Edit `zeroclaw-openwrt/Makefile` for build changes
2. Edit `zeroclaw-openwrt/files/` for configuration and init script changes
3. Test with GitHub Actions or local SDK build
4. Submit a pull request

## License

Same as ZeroClaw project (MIT/Apache 2.0 dual license).