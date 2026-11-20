# Device tree — Infinix Smart 9 HD (X6532C)

Device tree for the **Infinix Smart 9 HD (X6532C)** — MediaTek **MT6765**,
targeting **LineageOS 19.1 (Android 12.1)**, A/B + Virtual A/B, dynamic
partitions (`super`), and **no recovery partition** (recovery resources live in
`vendor_boot`).

This tree was built from the device's own firmware, **not** copied from any
public tree. Every number in `BoardConfig.mk` was read from:

| Source | Used for |
| --- | --- |
| `MT6765_Android_scatter.txt` | partition sizes (`boot`, `vendor_boot`, `dtbo`, `super`) |
| `lpdump super.img` | dynamic partition layout (group `main`) |
| `unpack_bootimg boot.img` | header v4, kernel + generic ramdisk |
| `unpack_bootimg vendor_boot.img` | dtb, load addresses, 161 kernel modules |
| `avbtool info_image vbmeta*.img` | AVB state of the active slot |

## Firmware facts

The device is **Treble**, but system and vendor are different versions:

| Partition | Version | Identity |
| --- | --- | --- |
| `system` | **Android 14 (SDK 34)** | Transsion `TSSI` / `AGo-64`, 32-bit (Go) |
| `vendor` | **Android 12 (SDK 31)** | `Infinix-X6532C`, VNDK 31 |

Because the vendor interface (VNDK) is **31**, the correct ROM is **Android 12.1**.
The stock system is Android 14 GSI-style, but the vendor is Android 12 — so a
custom ROM must follow the **vendor** side.

Other important facts:

- Userspace is **32-bit only** (`ro.vendor.product.cpu.abilist=armeabi-v7a,armeabi`, `ro.zygote=zygote32`).
- Vendor security patch: `2025-07-05`.
- Vendor fingerprint: `Infinix/X6532C-OP/Infinix-X6532C:12/SP1A.210812.016/260417V1882:user/release-keys`.
- Gatekeeper / KeyMint / kmSetKey use the **Trustonic TEE** (`ro.hardware.gatekeeper=trustonic`).
- Bootloader is on **slot b**; `vbmeta` flags=3 (verification + hashtree disabled).

## Kernel

The device is **GKI-style**: `boot` = kernel + generic ramdisk, `vendor_boot` =
vendor ramdisk + dtb + modules. There is **no kernel source** for this MT6765,
so the tree uses the **stock prebuilt kernel**:

```
prebuilt/kernel     Linux 5.10.237 (Image, header v4)
prebuilt/dtb.img    device tree (from vendor_boot)
prebuilt/dtbo.img   stock dtbo
prebuilt/modules/   161 kernel modules (.ko)
```

If matching MT6765 kernel source ever shows up, replace
`TARGET_PREBUILT_KERNEL` with the built kernel.

## Blobs

The blob list is `proprietary-files.txt` (**1993 vendor files**, generated from
the firmware `/vendor`). The blobs themselves live in a separate repo:

```
android_vendor_infinix_X6532C  ->  vendor/infinix/X6532C
```

Regenerate with:

```bash
./extract-files.sh /path/to/dump     # or "adb" if the device is connected
```

## Build

```bash
source build/envsetup.sh
lunch lineage_X6532C-userdebug
mka bacon
```

## Structure

```
AndroidProducts.mk      product list
lineage_X6532C.mk       product definition
BoardConfig.mk          board configuration (all values from firmware)
device.mk               packages, permissions, properties
system.prop             device properties
extract-files.sh        pull blobs from device/dump
setup-makefiles.sh      generate blob makefiles
proprietary-files.txt   vendor blob list
lineage.dependencies    blob repo
prebuilt/               kernel, dtb, dtbo, modules
rootdir/etc/            fstab.mt6765
rootdir/init/           device init
configs/                media configuration
sepolicy/               (placeholder) device policy
overlay/                (placeholder) RRO overlay
```

## Status / not done yet

This is a structurally complete tree with accurate device data, but it is
**not guaranteed to boot**:

1. **Blob repo** (`android_vendor_infinix_X6532C`) must be in the manifest.
2. **Common MTK trees** must be added: `device/mediatek/sepolicy`,
   `hardware/mediatek`, etc.
3. **Kernel** is still prebuilt — without source, only the stock kernel can be used.
4. **Sepolicy**, **overlay** and **configs** are placeholders and must be filled
   in during bring-up.

Without kernel source and the common MTK trees, this ROM can be built but the
bring-up is complex; for an MT6765 device like this the most realistic path
remains **GSI + stock vendor**.

---

# Device tree (ID) — Infinix Smart 9 HD (X6532C)

Device tree untuk **Infinix Smart 9 HD (X6532C)** — MediaTek **MT6765**,
target **LineageOS 19.1 (Android 12.1)**, A/B + Virtual A/B, dynamic partition
(`super`), **tanpa partisi recovery** (resource recovery ada di `vendor_boot`).

Tree ini dibuat dari firmware device itu sendiri, **bukan** disalin dari tree
publik. Semua angka di `BoardConfig.mk` dibaca dari scatter, `lpdump`,
`unpack_bootimg`, dan `avbtool`.

## Fakta firmware

Device ini **Treble**, tapi system dan vendor beda versi: `system` = Android 14
(SDK 34, Transsion `TSSI`/`AGo-64`, 32-bit), `vendor` = Android 12 (SDK 31,
`Infinix-X6532C`, VNDK 31). Karena VNDK = 31, ROM yang benar adalah
**Android 12.1**.

- Userspace **hanya 32-bit**.
- Security patch vendor `2025-07-05`.
- Gatekeeper/KeyMint pakai **Trustonic TEE**.
- Bootloader di **slot b**, `vbmeta` flags=3 (verifikasi mati).

## Kernel

Device ini **GKI-style**, dan **tidak ada source kernel**, jadi tree memakai
kernel prebuilt stock (5.10.237) + dtb + dtbo + 161 modul.

## Build

```bash
source build/envsetup.sh
lunch lineage_X6532C-userdebug
mka bacon
```

## Yang belum selesai

Kerangka lengkap dan akurat, tapi **belum dijamin boot**: blob repo harus masuk
manifest, tree MTK umum perlu ditambah, kernel masih prebuilt, dan
sepolicy/overlay/configs masih placeholder. Untuk MT6765 seperti ini jalur
paling realistis tetap **GSI + vendor stock**.
