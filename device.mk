#
# device.mk — Infinix Smart 9 HD (X6532C)
#
# Facts used here were read from this device's firmware (see BoardConfig.mk).
# The hardware HALs are prebuilt in the vendor partition, so this file only
# declares platform packages, permissions, A/B OTA and device properties.
#

LOCAL_PATH := $(call my-dir)

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
    make_f2fs \
    make_f2fs_casefold

# ------------------------------------------------------------------
# Hardware feature permissions
# ------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.audio.output.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.output.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
    frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.sip.voip.xml

# ------------------------------------------------------------------
# Vendor / ODM device-specific files that the build stage expects
# (the vendor partition itself is not rebuilt; these come from the
#  blob repo via $(LOCAL_PATH)/lineage.dependencies)
# ------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6765:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6765 \
    $(LOCAL_PATH)/rootdir/init/init.X6532C.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.X6532C.rc

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
