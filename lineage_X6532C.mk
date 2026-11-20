#
# lineage_X6532C.mk — Infinix Smart 9 HD (X6532C)
#
# 32-bit only (armeabi-v7a/armeabi), so no core_64_bit.mk.
#

# Inherit from the common AOSP 12.1 phone configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit the device
$(call inherit-product, device/infinix/X6532C/device.mk)

# Inherit the prebuilt blobs (vendor repository)
$(call inherit-product, vendor/infinix/X6532C/X6532C-vendor.mk)

# ------------------------------------------------------------------
# Product identity
# ------------------------------------------------------------------
PRODUCT_DEVICE := X6532C
PRODUCT_NAME := lineage_X6532C
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X6532C
PRODUCT_MANUFACTURER := INFINIX

PRODUCT_SHIPPING_API_LEVEL := 31
PRODUCT_CHARACTERISTICS := default

# Build fingerprint of the vendor side, kept for compatibility checks
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="Infinix/X6532C-OP/Infinix-X6532C:12/SP1A.210812.016/260417V1882:user/release-keys"

BUILD_FINGERPRINT := Infinix/X6532C-OP/Infinix-X6532C:12/SP1A.210812.016/260417V1882:user/release-keys
