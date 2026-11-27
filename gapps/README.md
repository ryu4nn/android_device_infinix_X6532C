# Google apps payload

This directory is empty in git on purpose. It is filled by

```sh
./tools/fetch-gapps.sh
```

which downloads a pinned MindTheGapps 13.0.0 arm archive, verifies its sha256,
unpacks it into `system/`, `product/` and `system_ext/`, and writes two generated
files: `Android.mk` with one prebuilt module per APK, and `gapps.mk` with the
`PRODUCT_PACKAGES` and `PRODUCT_COPY_FILES` lines that install them.

`device.mk` inherits `gapps.mk` only when it exists, so a tree that was merely
`repo sync`ed builds vanilla LineageOS.

| | |
| --- | --- |
| Archive | `MindTheGapps-13.0.0-arm-20231025_200806.zip` |
| Size | 227,368,711 bytes |
| sha256 | `9f0c3663872488acf98eb3dd548ed53a584f119161192dcd20f904b4cd05a37e` |

The arm (32-bit) archive is required: this device is `armeabi-v7a` only
(`ro.vendor.product.cpu.abilist64` is empty), so the arm64 package would install
libraries no process can load.

## Layout

MindTheGapps 13 stores almost everything under `system/product`, which is a
separate logical partition here, so the mapping is:

| Archive path | Image |
| --- | --- |
| `system/product/*` | `product.img` |
| `system/system_ext/*` | `system_ext.img` |
| `system/*` | `system.img` |

APKs install through `Android.mk` as `MtG_<Name>` prebuilt modules into the
directory they occupy in the archive. Module class `APPS` gives each one its own
subdirectory (`product/priv-app/MtG_GmsCore/MtG_GmsCore.apk`); the two
`product/overlay` overlays are the exception and install flat, because a runtime
resource overlay has to be a bare `<Name>.apk`. The `MtG_` prefix keeps the
module names from colliding with a module the platform already defines.

`system/addon.d/{addond_head,addond_tail}` is dropped: those are OpenGApps
installer fragments, never executed by anything, and LineageOS has its own
backuptool entries under `/system/addon.d`. With that excluded the arm archive
contributes nothing to `system.img` at all — the whole 483 MB lands in
`product` (≈467 MB) and `system_ext` (≈16 MB).

`system/product/etc/init/gapps.rc` (sets `ro.com.google.gmsversion`) therefore
lands in `product/etc/init/`, which init loads like any other partition script.