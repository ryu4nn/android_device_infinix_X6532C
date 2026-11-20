#
# device.mk — Infinix Smart 9 HD (X6532C)
#
# Facts used here were read from this device's firmware (see BoardConfig.mk).
# The hardware HALs are prebuilt in the vendor partition, so this file only
# declares platform packages, permissions, A/B OTA and device properties.
#

# Hard-coded on purpose: when this file is evaluated through inherit-product
# the value of $(call my-dir) is the temporary product makefile under out/,
# not this directory, so $(LOCAL_PATH) would be empty here.
LOCAL_PATH := device/infinix/X6532C

# ------------------------------------------------------------------
# API / Treble
# ------------------------------------------------------------------
PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_TARGET_VNDK_VERSION := 31

# ------------------------------------------------------------------
# Partitions: dynamic (super), A/B with virtual A/B
# ro.boot.dynamic_partitions=true, ro.build.ab_update=true
# ro.vendor.build.dont_use_vabc=true  -> no background compression
# ------------------------------------------------------------------
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# No fixed partition sizes are declared: system/system_ext/vendor/product are
# sized from the actual build output and must fit BOARD_MAIN_SIZE.
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    product \
    system \
    system_ext \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot

PRODUCT_PACKAGES += \
    update_engine \
    update_engine_client \
    update_engine_sideload \
    update_verifier \
    bootctl

# ------------------------------------------------------------------
# FBE (f2fs userdata, metadata partition, Trustonic gatekeeper/keymint in vendor)
# ------------------------------------------------------------------
PRODUCT_PACKAGES += \
    fsck.f2fs \
    make_f2fs

# make_f2fs_casefold is host-only (it has no target variant), so it belongs in
# PRODUCT_HOST_PACKAGES; listing it in PRODUCT_PACKAGES is a hard build error.
PRODUCT_HOST_PACKAGES += \
    make_f2fs_casefold

# ------------------------------------------------------------------
# Hardware feature permissions
#
# The stock vendor partition already ships every android.hardware.* /
# android.software.* XML under vendor/etc/permissions (34 files, copied
# back verbatim by the blob repo). Copying them again from the platform
# would create duplicate PRODUCT_COPY_FILES rules for the same
# destination path, which is a hard build error. So the platform copies
# are intentionally not declared here.
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Device-specific files installed into the *rebuilt* system partition.
# The vendor partition itself is not rebuilt; its files come from the
# blob repo via $(LOCAL_PATH)/lineage.dependencies, so nothing for
# vendor is listed here either (fstab.mt6765 and the vendor init rc's
# are already part of the blob repo).
# ------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/init/init.X6532C.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.X6532C.rc

# First-stage init reads the fstab from the vendor ramdisk, not from /vendor,
# because /vendor is itself a logical partition that first stage has to mount.
# The file is the stock one with the erofs alternatives and the avb flags
# removed (this ROM builds ext4 images and does not sign them).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/prebuilt/fstab.mt6765:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.mt6765

# Build-time RRO overlays
PRODUCT_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# ------------------------------------------------------------------
# Device properties
# ------------------------------------------------------------------
PRODUCT_PRODUCT_PROPERTIES += \
    ro.hardware.egl=meow \
    ro.hardware.gatekeeper=trustonic \
    ro.hardware.kmsetkey=trustonic \
    ro.hardware.paytrigger=trustonic \
    ro.hardware.hwcomposer=mtk_common \
    ro.opengles.version=196610 \
    ro.zygote=zygote32 \
    ro.crypto.volume.filenames_mode=aes-256-cts \
    ro.sf.lcd_density=320

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.telephony.default_network=9

# ------------------------------------------------------------------
# Inherit media/audio configs shipped with the device tree
# ------------------------------------------------------------------
$(call inherit-product, $(LOCAL_PATH)/configs/media.mk)
