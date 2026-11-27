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

# The vendor partition is VNDK 31 (vendor/etc/selinux/plat_sepolicy_vers.txt
# reads 31.0). Android 13 builds the platform at VNDK 33, so the v31 snapshot
# is installed as well: that is what provides /system/lib/vndk-31 and
# ld.config.31.txt for the vendor linker namespace. prebuilts/vndk/v31 is part
# of the default LineageOS 20.0 manifest.
PRODUCT_EXTRA_VNDK_VERSIONS := 31

# BRING-UP: the stock vendor manifest is target-level 5 but declares HAL
# versions newer than the AOSP level-5 matrix, so checkvintf rejects the pair.
# vintf/compatibility_matrix.device.xml describes them; wiring it in is stage 2
# (the note in BoardConfig.mk explains why it is not wired for run 1).
PRODUCT_ENFORCE_VINTF_MANIFEST := false

# ------------------------------------------------------------------
# Partitions: dynamic (super), A/B with virtual A/B
# ro.boot.dynamic_partitions=true, ro.build.ab_update=true
# ro.vendor.build.dont_use_vabc=true  -> no background compression
# ------------------------------------------------------------------
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# No fixed partition sizes are declared: system/system_ext/vendor/product are
# sized from the actual build output and must fit BOARD_MAIN_SIZE.
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# build/make/core/Makefile:4321 drops the whole OTA package
# (INTERNAL_OTA_PACKAGE_TARGET) when recovery_fstab is empty, and that variable
# never gets set on a tree built with TARGET_NO_RECOVERY. With it empty, bacon
# has no dependencies at all and ninja finishes without compiling anything.
# The recovery_fstab check only exists for non-A/B update packages; this device
# is AB_OTA_UPDATER, where the payload does not use it.
PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true

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

# ------------------------------------------------------------------
# X6532C integration: touch gestures, touch game mode, panel refresh rate.
#
# Both scripts are the ones proven on the ArrowOS repack. The boot script runs
# from init.X6532C.rc once sys.boot_completed=1, inside a device-owned domain
# (sepolicy/x6532c_boot.te) rather than a borrowed one, because the Transsion
# /proc nodes are labelled by the prebuilt vendor policy.
# ------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bin/x6532c-boot.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/x6532c-boot.sh \
    $(LOCAL_PATH)/bin/x6532c:$(TARGET_COPY_OUT_SYSTEM)/bin/x6532c

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

# ------------------------------------------------------------------
# Google apps
#
# No proprietary binaries live in this repository. tools/fetch-gapps.sh
# downloads a pinned MindTheGapps 13.0.0 arm archive, verifies its sha256,
# extracts system/ under gapps/ and writes gapps/gapps.mk with explicit
# PRODUCT_COPY_FILES lines. CI runs it before lunch; a tree that was only
# synced (no gapps/gapps.mk) builds vanilla LineageOS instead, so this never
# breaks a plain `repo sync` checkout.
# ------------------------------------------------------------------
GAPPS_DIR := $(LOCAL_PATH)/gapps

ifneq ($(wildcard $(GAPPS_DIR)/gapps.mk),)
$(call inherit-product, $(GAPPS_DIR)/gapps.mk)

# MindTheGapps ships its own privilege allowlists; keep PackageManager in log
# mode so a missing entry degrades instead of taking system_server down.
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=log
endif
