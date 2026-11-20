# Device tree — Infinix Smart 9 HD (X6532C)

Device tree untuk **Infinix Smart 9 HD (X6532C)** — MediaTek **MT6765**,
target **LineageOS 19.1 (Android 12.1)**, A/B + Virtual A/B, dynamic partition
(`super`), dan **tanpa partisi recovery** (resource recovery ada di `vendor_boot`).

Tree ini dibuat dari firmware resmi device itu sendiri, bukan disalin dari tree
publik. Semua angka di `BoardConfig.mk` dibaca dari:

| Sumber | Dipakai untuk |
| --- | --- |
| `MT6765_Android_scatter.txt` | ukuran partisi (`boot`, `vendor_boot`, `dtbo`, `super`) |
| `lpdump super.img` | layout dynamic partition (group `main`) |
| `unpack_bootimg boot.img` | header v4, kernel + generic ramdisk |
| `unpack_bootimg vendor_boot.img` | dtb, load address, 161 kernel module |
| `avbtool info_image vbmeta*.img` | status AVB slot aktif |

## Kondisi firmware

Device ini **Treble**, tapi system dan vendor beda versi:

| Partisi | Versi | Identitas |
| --- | --- | --- |
| `system` | **Android 14 (SDK 34)** | Transsion `TSSI` / `AGo-64`, 32-bit (Go) |
| `vendor` | **Android 12 (SDK 31)** | `Infinix-X6532C`, VNDK 31 |

Karena interface vendor (VNDK) = **31**, ROM yang benar adalah **Android 12.1**.
System stock adalah Android 14 ala GSI, tapi vendor-nya Android 12 — jadi custom
ROM harus ikut sisi **vendor**.

Fakta penting:

- Userspace **hanya 32-bit** (`ro.vendor.product.cpu.abilist=armeabi-v7a,armeabi`, `ro.zygote=zygote32`).
- Security patch vendor: `2025-07-05`.
- Fingerprint vendor: `Infinix/X6532C-OP/Infinix-X6532C:12/SP1A.210812.016/260417V1882:user/release-keys`.
- Gatekeeper / KeyMint / kmSetKey memakai **Trustonic TEE** (`ro.hardware.gatekeeper=trustonic`).
- Bootloader aktif di **slot b**, `vbmeta` flags=3 (verifikasi + hashtree mati).

## Kernel

**Tidak ada source kernel** yang dirilis Infinix untuk MT6765 ini, jadi tree ini
memakai **kernel prebuilt** dari `boot.img` stock:

```
prebuilt/kernel     Linux 5.10.237 (Image, header v4)
prebuilt/dtb.img    device tree (dari vendor_boot)
prebuilt/dtbo.img   dtbo stock
prebuilt/modules/   161 modul kernel (.ko)
```

Kalau nanti dapat source kernel MT6765 yang cocok, ganti `TARGET_PREBUILT_KERNEL`
dengan build dari source.

## Blob

Daftar blob ada di `proprietary-files.txt` (dibuat dari isi `vendor/` firmware,
**1993 file**). Blobnya sendiri masuk ke repo terpisah:

```
android_vendor_infinix_X6532C  ->  vendor/infinix/X6532C
```

Repo itu belum dibuat; generate sendiri dengan:

```bash
./extract-files.sh /path/ke/dump     # atau "adb" kalau device tersambung
```

## Build

```bash
source build/envsetup.sh
lunch lineage_X6532C-userdebug
mka bacon
```

## Struktur

```
AndroidProducts.mk      daftar product
lineage_X6532C.mk       product definition
BoardConfig.mk          konfigurasi board (semua angka dari firmware)
device.mk               package, permission, property
system.prop             property device
extract-files.sh        tarik blob dari device/dump
setup-makefiles.sh      generate makefile blob
proprietary-files.txt   daftar blob vendor
lineage.dependencies    repo blob
prebuilt/               kernel, dtb, dtbo, modules
rootdir/etc/            fstab.mt6765
configs/                konfigurasi media
sepolicy/               (placeholder) policy device
overlay/                (placeholder) RRO overlay
```

## Yang belum selesai

Ini kerangka device tree yang lengkap secara struktur dan akurat untuk data
device, tapi **belum dijamin langsung boot**:

1. **Blob repo** (`android_vendor_infinix_X6532C`) belum diisi.
2. **Tree umum MTK** perlu ditambahkan ke manifest:
   `device/mediatek/sepolicy`, `hardware/mediatek`, dll.
3. **Kernel** masih prebuilt — tanpa source, hanya bisa pakai kernel stock.
4. **Sepolicy**, **overlay**, dan **configs** masih placeholder; perlu diisi
   kalau sudah masuk tahap bring-up.

Tanpa source kernel dan tanpa tree MTK umum, ROM ini bisa dibangun tapi
kompleks; jalur paling realistis untuk device MT6765 seperti ini tetap
**GSI + vendor stock**.
