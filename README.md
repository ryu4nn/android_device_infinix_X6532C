# Device Tree for the Infinix Smart 9 HD (X6532C)

The Infinix Smart 9 HD (codenamed "X6532C") is an entry-level smartphone from
Infinix, announced in January 2025. It ships with Android 14 Go Edition (XOS 14)
on top of the MediaTek MT6765 platform, marketed as the Helio G50, with 3 or 4 GB
of LPDDR4X RAM, 64 GB of eMMC 5.1 storage and a 6.7 inch 90 Hz display.

This tree targets **LineageOS 19.1 (Android 12.1)** with A/B + Virtual A/B,
dynamic partitions (`super`) and no recovery partition (the recovery resources
live in `vendor_boot`).

It was written from a read-only dump of the device itself, **not** copied from
any public tree. Every number in `BoardConfig.mk` was read from:

| Source                          | Used for                                              |
| ------------------------------- | ----------------------------------------------------- |
| `MT6765_Android_scatter.txt`    | partition sizes (`boot`, `vendor_boot`, `dtbo`, `super`) |
| `lpdump super.img`              | dynamic partition layout (group `main`)               |
| `unpack_bootimg boot.img`       | header v4, kernel + generic ramdisk                   |
| `unpack_bootimg vendor_boot.img`| dtb, load addresses, kernel modules                   |
| `avbtool info_image vbmeta*.img`| AVB state of the active slot                          |

## Device specifications

| Feature                 | Specification                                      |
| :---------------------- | :------------------------------------------------- |
| Chipset                 | MediaTek MT6765 (Helio G50), 12 nm                 |
| CPU                     | Octa-core (8x Cortex-A53, up to 2.2 GHz)           |
| GPU                     | Imagination PowerVR GE8320                         |
| Memory                  | 3 / 4 GB LPDDR4X                                   |
| Shipped Android Version | 14 (Go edition, XOS 14)                            |
| Storage                 | 64 GB eMMC 5.1, microSDXC up to 1 TB               |
| SIM                     | Dual Nano-SIM (dual stand-by)                      |
| Battery                 | 5000 mAh Li-Po, 10 W wired charging                |
| Dimensions              | 165.7 x 77.1 x 8.4 mm, 188 g                       |
| Display                 | 6.7 inch IPS LCD, 720 x 1600 (HD+), 90 Hz          |
| Rear Camera             | 13 MP f/1.9 (wide), AF, plus auxiliary lens        |
| Front Camera            | 8 MP                                               |
| Fingerprint             | Side-mounted (power button)                        |
| Sensors                 | Accelerometer, Proximity, Compass                  |
| Speakers                | Stereo, DTS                                        |

## Firmware facts

The device is **Treble**, but system and vendor are different versions:

| Partition | Version               | Identity                                              |
| --------- | --------------------- | ----------------------------------------------------- |
| `system`  | **Android 14 (SDK 34)** | Transsion `TSSI` / `AGo-64`, 32-bit (Go)            |
| `vendor`  | **Android 12 (SDK 31)** | `Infinix-X6532C`, VNDK 31                            |

Because the vendor interface (VNDK) is **31**, the correct ROM is **Android 12.1**.
The stock system is an Android 14 GSI-style image, but the vendor is Android 12 —
so a custom ROM has to follow the **vendor** side.

Other relevant facts:

- Userspace is **32-bit only** (`ro.vendor.product.cpu.abilist=armeabi-v7a,armeabi`, `ro.zygote=zygote32`).
- Vendor security patch: `2025-07-05`.
- Vendor fingerprint: `Infinix/X6532C-OP/Infinix-X6532C:12/SP1A.210812.016/260417V1882:user/release-keys`.
- Gatekeeper / KeyMint use the **Trustonic TEE** (`ro.hardware.gatekeeper=trustonic`).
- The bootloader is on **slot b**; `vbmeta` flags=3 (verification and hashtree disabled).

## Kernel

The device is **GKI-style**: `boot` carries the kernel and the generic ramdisk,
`vendor_boot` carries the vendor ramdisk, the dtb and the kernel modules. There is
**no kernel source** for this MT6765, so the tree uses the **stock prebuilt
kernel**:

```
prebuilt/kernel       Linux 5.10.237 (Image.gz, header v4)
prebuilt/dtb.dtb      vendor_boot dtb section (dt_table, byte-identical to stock)
prebuilt/dtbo.img     stock dtbo
prebuilt/modules/     156 kernel modules (.ko)
prebuilt/modules.load first-stage load order, 140 modules, stock verbatim
prebuilt/fstab.mt6765 first-stage fstab (ext4 only, no avb flags)
```

`modules.load` is kept in the stock order because module dependencies have to be
loaded before the modules that use them; an alphabetical list does not boot. The
other 16 modules in `prebuilt/modules/` only appear in the stock
`modules.load.recovery` and are recovery-only.

`prebuilt/fstab.mt6765` goes into the vendor ramdisk as
`first_stage_ramdisk/fstab.mt6765`: first-stage init reads the fstab from the
ramdisk, because `/vendor` is itself a logical partition that still has to be
mounted. The second-stage fstab stays the untouched stock copy at
`/vendor/etc/fstab.mt6765` from the blob repo.

If matching MT6765 kernel source ever shows up, replace
`TARGET_PREBUILT_KERNEL` with the built kernel.

## Blobs

The blob list is `proprietary-files.txt` (1993 vendor files), generated from the
firmware `/vendor`. The blobs themselves live in a separate repository:

```
android_vendor_infinix_X6532C  ->  vendor/infinix/X6532C
```

Its makefile copies 1932 files. Regenerate both with:

```bash
./extract-files.sh /path/to/dump     # or "adb" if the device is connected
```

### Vendor and ODM build.prop

Two property files are kept in this tree instead of the blob repository:
`vendor.prop` (the stock `vendor/build.prop`, 627 lines) and `odm.prop` (the
stock `vendor/odm/etc/build.prop`). Both are fed through `TARGET_VENDOR_PROP` and
`TARGET_ODM_PROP`, because `build/make/core/sysprop.mk` generates those exact
files (`vendor/build.prop`, `vendor/odm/etc/build.prop`) from the product
configuration, and a `PRODUCT_COPY_FILES` entry pointing at them would be
silently overwritten. `vendor_dlkm` and `odm_dlkm` have no such hook; their
build.prop is generated by the build (identity properties only — the one real
property, `persist.sys.usb.config=none`, is also in `vendor.prop`).

Because the stock file carries identity properties that the build regenerates,
`BUILD_BROKEN_DUP_SYSPROP` is enabled; otherwise `post_process_props.py` fails on
the duplicates.

## Build

```bash
source build/envsetup.sh
lunch lineage_X6532C-userdebug
mka bacon
```

`lineage_X6532C.mk` inherits `vendor/lineage/config/common_full_phone.mk` on top
of `full_base_telephony.mk`; LineageOS 19.1's `common.mk` carries no AOSP base of
its own, and without the inherit there is no `LINEAGE_VERSION` and no LineageOS
package set. `PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true` is needed because
`build/make/core/Makefile:4321` clears `INTERNAL_OTA_PACKAGE_TARGET` when
`recovery_fstab` is empty, which is always the case for a `TARGET_NO_RECOVERY`
tree — with that target empty, `bacon` has no dependencies and ninja compiles
nothing.

CI builds `m droid` instead of `mka bacon`: a package signed with the AOSP test
keys is rejected by the stock recovery, so the build produces partition images
rather than an OTA zip.

## Repository layout

```
AndroidProducts.mk      product list
lineage_X6532C.mk       product definition
BoardConfig.mk          board configuration (all values from firmware)
device.mk               packages, permissions, properties
system.prop             platform properties
vendor.prop             stock vendor/build.prop (TARGET_VENDOR_PROP)
odm.prop                stock vendor/odm/etc/build.prop (TARGET_ODM_PROP)
extract-files.sh        pull blobs from device/dump
setup-makefiles.sh      generate blob makefiles
proprietary-files.txt   vendor blob list
lineage.dependencies    blob repository
prebuilt/               kernel, dtb, dtbo, modules, modules.load, fstab
rootdir/init/           device init
configs/                media configuration
sepolicy/               (placeholder) device policy
overlay/                (placeholder) RRO overlay
```

## Status

This is a structurally complete tree with accurate device data, but it is **not
guaranteed to boot**:

1. **Blob repository** (`android_vendor_infinix_X6532C`) must be in the manifest.
2. **Common MTK trees** must be added: `device/mediatek/sepolicy`,
   `hardware/mediatek`, etc.
3. **Kernel** is still prebuilt — without source, only the stock kernel can be used.
4. **Sepolicy**, **overlay** and **configs** are placeholders and must be filled
   in during bring-up.

Without kernel source and the common MTK trees, this ROM can be built but the
bring-up is complex; for an MT6765 device like this the most realistic path
remains **GSI + stock vendor**.

## Copyright

```
#
# Copyright (C) 2025 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
```
