# 使用相对路径引用 rules.mk
include ../../rules.mk

# Package Metadata
PKG_NAME:=zeroclaw
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

# Source Code Information - using local source
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zeroclaw-labs/zeroclaw.git
PKG_SOURCE_DATE:=2026-03-09
PKG_SOURCE_VERSION:=main
PKG_MIRROR_HASH:=skip

# Package Configuration
SECTION:=utils
CATEGORY:=Utilities
TITLE:=ZeroClaw - Fast, small, and fully autonomous AI assistant infrastructure
URL:=https://github.com/zeroclaw-labs/zeroclaw
DEPENDS:=+libc +libstdcpp +libopenssl +ca-bundle +rust +cargo

# Define the build directory
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cargo.mk

# Package definition for opkg
define Package/$(PKG_NAME)
  SECTION:=$(SECTION)
  CATEGORY:=$(CATEGORY)
  TITLE:=$(TITLE)
  URL:=$(URL)
  DEPENDS:=$(DEPENDS)
endef

# Package description
define Package/$(PKG_NAME)/description
ZeroClaw is the runtime operating system for agentic workflows — infrastructure that abstracts models, tools, memory, and execution so agents can be built once and run anywhere.

Features:
- Lean Runtime by Default: Common CLI and status workflows run in a few-megabyte memory envelope
- Cost-Efficient Deployment: Designed for low-cost boards and small cloud instances
- Fast Cold Starts: Single-binary Rust runtime keeps command and daemon startup near-instant
- Portable Architecture: One binary-first workflow across ARM, x86, and RISC-V
- Secure by design: pairing, strict sandboxing, explicit allowlists, workspace scoping
endef

# Build/Configure: Steps to configure the package
define Build/Configure
	# Set up Rust cross-compilation environment
	( \
		cd $(PKG_BUILD_DIR); \
		mkdir -p .cargo; \
		echo '[target.$(RUSTC_TARGET_NAME)]' > .cargo/config.toml; \
		echo 'linker = "$(TARGET_CC)"' >> .cargo/config.toml; \
		echo 'rustflags = ["-C", "link-arg=-Wl,--allow-multiple-definition"]' >> .cargo/config.toml; \
	)
endef

# Build/Compile: Steps to compile the package
define Build/Compile
	# Set up Rust cross-compilation environment
	( \
		cd $(PKG_BUILD_DIR); \
		CARGO_HOME=$(PKG_BUILD_DIR)/.cargo \
		CC=$(TARGET_CC) \
		CXX=$(TARGET_CXX) \
		AR=$(TARGET_AR) \
		RUSTFLAGS="-C linker=$(TARGET_CC)" \
		$(CARGO) build \
			$(CARGO_VERBOSE) \
			$(CARGO_INSTALL_ARG) \
			--target $(RUSTC_TARGET_NAME) \
			--release \
			--locked; \
	)
endef

# Package/install: Commands to copy compiled files into the IPK
define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_NAME)/release/zeroclaw $(1)/usr/bin/
	
	# Create config directory
	$(INSTALL_DIR) $(1)/etc/zeroclaw
	$(INSTALL_CONF) ./files/config.toml $(1)/etc/zeroclaw/
	
	# Create init script
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/zeroclaw.init $(1)/etc/init.d/zeroclaw
	
	# Create service enable/disable symlinks
	$(INSTALL_DIR) $(1)/etc/rc.d
	ln -sf ../init.d/zeroclaw $(1)/etc/rc.d/S99zeroclaw
	ln -sf ../init.d/zeroclaw $(1)/etc/rc.d/K01zeroclaw
endef

# Call the BuildPackage macro to build the package
$(eval $(call BuildPackage,$(PKG_NAME)))
