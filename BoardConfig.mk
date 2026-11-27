#
# BoardConfig.mk — Infinix Smart 9 HD (X6532C), MediaTek MT6765
#
# Target : LineageOS 20.0 (Android 13), running on the Android 12 vendor side.
# Layout : A/B + Virtual A/B, dynamic partitions (super), no recovery partition.
#
# Android 13 versus Android 12 deltas that this board config has to answer:
#
#  * VNDK 33 framework against a VNDK 31 vendor. Handled by shipping VNDK 31
#    snapshots from prebuilts/vndk/v31 (PRODUCT_EXTRA_VNDK_VERSIONS, device.mk),
#    which is the supported upgrade path. The vendor never gets rebuilt.
#  * init_boot. Android 13 normally moves the generic ramdisk there. This
#    device has the partition but it is 8 MiB of zeroes (verified with
#    hexdump on init_boot_a.img) and the stock boot.img is header v4 with a
#    1380093 byte ramdisk. So BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE and
#    BOARD_PREBUILT_INIT_BOOT_IMAGE are deliberately NOT defined: with
#    BUILDING_INIT_BOOT_IMAGE unset, build/make/core/Makefile:991 keeps
#    --ramdisk on boot.img, which is the layout the bootloader here reads.
#  * Recovery. It lives in vendor_boot on this device (that is why the TWRP
#    image is a 64 MiB vendor_boot.img). Nothing in this ROM writes
#    vendor_boot, so the stock/TWRP recovery stays untouched.
#
# Every number here was read from this device's own firmware, the SP Flash Tool
# package "X6532C-MF380ABCDEFGH-UGo-OP-260417V1675":
#
#   MT6765_Android_scatter.txt        partition sizes and offsets
#   lpdump super.img                  dynamic partition groups/sizes
#   unpack_bootimg boot.img           header v4, kernel + generic ramdisk
#   unpack_bootimg vendor_boot.img    dtb, load addresses, vendor ramdisk
#   avbtool info_image vbmeta*.img    AVB state (active slot: verification off)
#
# system/vendor split (read from the images):
#   system      Android 14 (SDK 34), Transsion "TSSI" / AGo-64, 32-bit
#   vendor      Android 12 (SDK 31), Infinix-X6532C, VNDK 31   <- ROM must match this
#

DEVICE_PATH := device/infinix/X6532C

# ------------------------------------------------------------------
# Architecture: userspace is 32-bit only
#   ro.vendor.product.cpu.abilist = armeabi-v7a,armeabi
#   ro.zygote = zygote32
#   vendor/lib = 721 libraries, vendor/lib64 = 2 libraries
#
# The kernel, however, is 64-bit (GKI 5.10 aarch64) and therefore exposes the
# 64-bit binder protocol; 32-bit processes reach it through the compat ioctls.
# config.mk demands this flag for PRODUCT_SHIPPING_API_LEVEL >= 28, and leaving
# it unset would make libbinder assume a 32-bit BINDER_IPC_32BIT kernel.
# ------------------------------------------------------------------
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53
TARGET_USES_64_BIT_BINDER := true

# ------------------------------------------------------------------
# Platform
# ------------------------------------------------------------------
TARGET_BOARD_PLATFORM := mt6765
TARGET_BOOTLOADER_BOARD_NAME := mt6765
BOARD_USES_MTK_HARDWARE := true
TARGET_NO_BOOTLOADER := true

# ------------------------------------------------------------------
# Kernel — prebuilt. No kernel source is published for this device, so the
# stock 5.10.237 kernel from boot.img is used as-is.
# ------------------------------------------------------------------
BOARD_KERNEL_IMAGE_NAME := Image
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Load addresses, verified against the vendor_boot header:
#   kernel  0x40080000 = 0x40078000 + 0x00008000
#   ramdisk 0x51b00000 = 0x40078000 + 0x11a88000
#   tags/dtb 0x47880000 = 0x40078000 + 0x07808000
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x11a88000
BOARD_KERNEL_TAGS_OFFSET := 0x07808000
BOARD_DTB_OFFSET := 0x07808000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_RAMDISK_USE_LZ4 := true

BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# Device tree: the DTB lives in vendor_boot (a header v4 boot image carries
# none), dtbo has its own partition.
#
# build/make only wires the vendor_boot --dtb argument when
# BOARD_INCLUDE_DTB_IN_BOOTIMG is set, and it assembles the dtb image it passes
# by concatenating every *.dtb found in BOARD_PREBUILT_DTBIMAGE_DIR. This
# device's vendor_boot dtb section is a dt_table (magic d7b7ab1e), byte-identical
# to the stock one, so it is stored as prebuilt/dtb.dtb.
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.dtb
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

# Kernel modules live in the vendor_boot vendor ramdisk (/lib/modules):
# 156 .ko files, 140 loaded by first-stage init. The load order is not
# alphabetical — dependent modules must come after their dependencies — so the
# stock modules.load is shipped verbatim. The remaining 16 modules only appear
# in the stock modules.load.recovery and belong to the recovery ramdisk.
VENDOR_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(VENDOR_KERNEL_MODULES)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(shell cat $(DEVICE_PATH)/prebuilt/modules.load)

# ------------------------------------------------------------------
# Partitions (MT6765_Android_scatter.txt, byte sizes)
# ------------------------------------------------------------------
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432          # 32 MiB
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864   # 64 MiB
BOARD_DTBOIMG_PARTITION_SIZE := 8388608             # 8 MiB
BOARD_SUPER_PARTITION_SIZE := 5368709120            # 5 GiB

# lpdump: one group named "main" (main_a / main_b), max 5366611968 bytes.
# system_ext, and the Transsion tr_* partitions are also in this group; a
# custom ROM only builds the four AOSP ones.
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_PARTITION_LIST := system system_ext vendor product
BOARD_MAIN_SIZE := 5364514816

BOARD_USES_METADATA_PARTITION := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs

TARGET_COPY_OUT_SYSTEM := system
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product

BOARD_BUILD_SYSTEM_ROOT_IMAGE := false
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true
BOARD_HAS_LARGE_FILESYSTEM := true

# ------------------------------------------------------------------
# AVB. Active slot b has vbmeta flags=3 (verification + hashtree disabled),
# so an unsigned footer is correct; vbmeta does not need to be reflashed.
# ------------------------------------------------------------------
BOARD_AVB_ENABLE := true
BOARD_AVB_ALGORITHM := NONE
BOARD_AVB_VBMETA_SYSTEM := system system_ext
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := NONE
BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := NONE

# ------------------------------------------------------------------
# Treble / VNDK — the vendor is VNDK 31, the framework is VNDK 33
#
# BOARD_VNDK_VERSION stays "current" (33 on T): the platform is built at its
# own VNDK. The 31 side is covered by installing the com.android.vndk.v31
# APEX (device.mk), which is how Android 13 delivers a VNDK older than the
# platform. There is no /system/lib/vndk-31 and no ld.config.31.txt in T:
# both belong to Android 10 and earlier.
# ------------------------------------------------------------------
BOARD_VNDK_VERSION := current

# ------------------------------------------------------------------
# VINTF: the stock vendor manifest is target-level 5 but declares newer HAL
# versions than the AOSP level-5 matrix knows (radio@1.6, wifi@1.5, usb@1.3,
# 24 mtkradioex@3.0 instances, 18 lbs@1.0 instances, ...). vintf/ holds a
# framework matrix fragment that permits them.
#
# BRING-UP: the fragment is not wired for the first build. Enabling it means
# the whole checkvintf pass must accept a hand-written matrix, and a mistake
# there costs a full run, so run 1 builds with PRODUCT_ENFORCE_VINTF_MANIFEST
# disabled and the fragment unused. Stage 2 turns both on together:
#
#   DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := $(DEVICE_PATH)/vintf/compatibility_matrix.device.xml
#
# and removes PRODUCT_ENFORCE_VINTF_MANIFEST := false from device.mk.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Display
# ------------------------------------------------------------------
TARGET_SCREEN_DENSITY := 320

# ------------------------------------------------------------------
# Properties
# ------------------------------------------------------------------
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# The vendor partition is rebuilt from the stock blobs, so its build.prop has to
# be the stock one too: 627 lines of ro.vendor.* / ro.product.vendor.* / MTK
# props that nothing in this tree would regenerate. Copying it as a
# PRODUCT_COPY_FILES entry does not work, because sysprop.mk owns that exact
# target (INSTALLED_VENDOR_BUILD_PROP_TARGET) and the generated file would
# replace it. TARGET_VENDOR_PROP is the supported hook: sysprop.mk concatenates
# it into the generated vendor/build.prop. odm/etc/build.prop works the same way
# through TARGET_ODM_PROP.
#
# vendor_dlkm and odm_dlkm have no such hook (sysprop.mk passes empty file and
# variable lists for them), so those two are left to the build; all they carry
# is ro.product.*_dlkm.* identity, and their one real property,
# persist.sys.usb.config=none, is already in vendor.prop.
TARGET_VENDOR_PROP := $(DEVICE_PATH)/vendor.prop
TARGET_ODM_PROP := $(DEVICE_PATH)/odm.prop

# ------------------------------------------------------------------
# SELinux: device-side additions only (vendor policy stays in vendor)
# ------------------------------------------------------------------
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# ------------------------------------------------------------------
# Build fixes for the minimal manifest used by this device
# ------------------------------------------------------------------
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# vendor.prop is the stock vendor build.prop, so the identity properties it
# carries (ro.product.vendor.*, ro.vendor.build.*) collide with the ones
# sysprop.mk generates from the product config. post_process_props.py treats a
# duplicate with a different value as a hard error unless duplicates are
# allowed; allow them and let the generated value win, the rest of the stock
# file is untouched.
BUILD_BROKEN_DUP_SYSPROP := true

# The build must not pick up the recovery-only bits from the OrangeFox tree
TARGET_NO_RECOVERY := true

# ------------------------------------------------------------------
# Assertions: accept both the product name and the vendor device name
# ------------------------------------------------------------------
TARGET_OTA_ASSERT_DEVICE := X6532C,Infinix-X6532C,X6532C-OP
