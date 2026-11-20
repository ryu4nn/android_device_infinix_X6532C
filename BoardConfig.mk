#
# BoardConfig.mk — Infinix Smart 9 HD (X6532C), MediaTek MT6765
#
# Target : LineageOS 19.1 (Android 12.1), matching the vendor side.
# Layout : A/B + Virtual A/B, dynamic partitions (super), no recovery partition.
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
# ------------------------------------------------------------------
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

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

# Kernel modules live in the vendor_boot vendor ramdisk (/lib/modules),
# 161 files, 140 loaded at first stage (stock modules.load).
VENDOR_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)/prebuilt/modules/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(VENDOR_KERNEL_MODULES)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(patsubst $(DEVICE_PATH)/prebuilt/modules/%,%,$(VENDOR_KERNEL_MODULES))

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
# Treble / VNDK — vendor is VNDK 31, and LineageOS 19.1 is VNDK 31
# ------------------------------------------------------------------
BOARD_VNDK_VERSION := current

# ------------------------------------------------------------------
# Display
# ------------------------------------------------------------------
TARGET_SCREEN_DENSITY := 320

# ------------------------------------------------------------------
# Properties
# ------------------------------------------------------------------
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# ------------------------------------------------------------------
# SELinux: device-side additions only (vendor policy stays in vendor)
# ------------------------------------------------------------------
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# ------------------------------------------------------------------
# Build fixes for the minimal manifest used by this device
# ------------------------------------------------------------------
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# The build must not pick up the recovery-only bits from the OrangeFox tree
TARGET_NO_RECOVERY := true

# ------------------------------------------------------------------
# Assertions: accept both the product name and the vendor device name
# ------------------------------------------------------------------
TARGET_OTA_ASSERT_DEVICE := X6532C,Infinix-X6532C,X6532C-OP
