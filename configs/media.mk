#
# configs/media.mk — Infinix Smart 9 HD (X6532C)
#
# MediaTek media codecs / audio. The real XMLs and the OMX/C2 shims live in the
# vendor partition (vendor/etc/media_codecs*.xml, vendor/lib/libstagefright_*),
# so nothing needs to be built from source here.
#
# This file exists so device.mk can inherit device-specific media knobs.
# Keep it dependency-free: do not add module names that are not part of AOSP
# 12.1, or the build will stop with "module not found".
#

# Board-specific media feature declarations (none for now).
