#
# configs/media.mk — Infinix Smart 9 HD (X6532C)
#
# MediaTek media codecs / audio. The real XMLs live in the vendor partition
# (vendor/etc/media_codecs*.xml, vendor/etc/mtk_audio*). Nothing needs to be
# built from source here; the vendor blobs provide everything.
#
# This file exists so device.mk can inherit device-specific config knobs.
#

# Software codecs
PRODUCT_PACKAGES += \
    libavcodec \
    libavformat

# MediaTek OMX/C2 shims are prebuilt in vendor (libstagefright_soft_*).
