# Google apps payload

This directory is empty in git on purpose. It is filled by

```sh
./tools/fetch-gapps.sh
```

which downloads a pinned MindTheGapps 13.0.0 arm archive, verifies its sha256,
unpacks it into `system/`, `product/` and `system_ext/`, and writes `gapps.mk`
with one `PRODUCT_COPY_FILES` line per file.

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

`system/addon.d/{addond_head,addond_tail}` is dropped: those are OpenGApps
installer fragments, never executed by anything, and LineageOS has its own
backuptool entries under `/system/addon.d`. With that excluded the arm archive
contributes nothing to `system.img` at all — the whole 483 MB lands in
`product` (≈467 MB) and `system_ext` (≈16 MB).

`system/product/etc/init/gapps.rc` (sets `ro.com.google.gmsversion`) therefore
lands in `product/etc/init/`, which init loads like any other partition script.