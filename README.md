# Device Tree for the Infinix Smart 9 HD (X6532C)

The Infinix Smart 9 HD (codenamed "X6532C") is an entry-level smartphone from
Infinix, announced in January 2025. It ships with Android 14 Go Edition (XOS 14)
on top of the MediaTek MT6765 platform, marketed as the Helio G50, with 3 or 4 GB
of LPDDR4X RAM, 64 GB of eMMC 5.1 storage and a 6.7 inch 90 Hz display.

This tree targets **LineageOS 20.0 (Android 13)** on the **Android 12 vendor
partition**, with A/B + Virtual A/B, dynamic partitions (`super`) and no recovery
partition (the recovery resources live in `vendor_boot`).

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

Because the vendor interface (VNDK) is **31**, the ROM has to speak VNDK 31 to the
vendor partition no matter which platform it runs. That is a supported upgrade
path, not a reason to stay on Android 12:

- `PRODUCT_PACKAGES += com.android.vndk.v31` installs the VNDK 31 **APEX**.
  Android 13 does not deliver old VNDKs as `/system/lib/vndk-31` directories;
  `com.android.vndk.v31` is an `apex_vndk` module that is non-updatable and
  `system_ext_specific`, so its libraries sit in
  `/system_ext/apex/com.android.vndk.v31` and init bind-mounts them at
  `/apex/com.android.vndk.v31`. `linkerconfig` builds the vendor linker
  namespace at boot from `ro.vndk.version=31`, so that mount is what lets a
  vendor HAL resolve `libcutils`, `libbase`, `libhidlbase` and friends.
  `PRODUCT_EXTRA_VNDK_VERSIONS := 31` is set too — it validates the
  `prebuilts/vndk/v31` snapshot — but on its own it installs nothing in a
  device build.
- `BOARD_VNDK_VERSION` stays `current` (33): the platform is built at its own
  VNDK, and the vendor partition is never rebuilt.

`ro.product.first_api_level` is restated as 31 on `/product`. The stock vendor
build.prop ends with 34 (the device shipped with Android 14), which implies
VINTF level 8 — a level an Android 13 framework cannot provide. init resolves
`ro.product.*` from the first partition in `ro.product.property_source_order`,
and that order begins with `product`, so the platform copy wins.

The stock system is an Android 14 GSI-style image, but the vendor is Android 12;
the vendor side is the fixed point, and it is the side this ROM keeps untouched.

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
./tools/fetch-gapps.sh          # optional; without it the build is vanilla
source build/envsetup.sh
lunch lineage_X6532C-userdebug
mka droid
```

`lineage_X6532C.mk` inherits `vendor/lineage/config/common_full_phone.mk` on top
of `full_base_telephony.mk`; `common.mk` carries no AOSP base of its own, and
without the inherit there is no `LINEAGE_VERSION` and no LineageOS package set.
`PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true` is needed because
`build/make/core/Makefile` clears `INTERNAL_OTA_PACKAGE_TARGET` when
`recovery_fstab` is empty, which is always the case for a `TARGET_NO_RECOVERY`
tree — with that target empty, `bacon` has no dependencies and ninja compiles
nothing.

The build target is `droid`, not `bacon`: a package signed with the AOSP test keys
is rejected by the stock recovery, and a payload OTA would write `vendor_boot`,
which is where TWRP lives. `droid` produces the raw images instead.

### Google apps

`tools/fetch-gapps.sh` downloads a pinned MindTheGapps 13.0.0 **arm** archive,
verifies its sha256, unpacks it under `gapps/` and writes `gapps/gapps.mk` with
explicit `PRODUCT_COPY_FILES` lines. `device.mk` inherits that makefile only when
it exists, so a tree that was merely `repo sync`ed builds vanilla LineageOS.

The arm (32-bit) archive is the correct one: userspace here is `armeabi-v7a`
only and `ro.vendor.product.cpu.abilist64` is empty, so arm64 payload would never
be loaded. 467 MB lands in `product` and 16 MB in `system_ext`.

### VINTF

The stock vendor manifest is `target-level="5"` but declares HAL versions newer
than the AOSP level-5 framework matrix (radio 1.6, wifi 1.5, usb 1.3, audio 7.0,
24 `mtkradioex@3.0` instances, 18 `lbs@1.0` instances, and more), so `checkvintf`
rejects the pair.

`vintf/compatibility_matrix.device.xml` is generated from the stock vendor
manifest by `tools/gen-vintf-matrix.py` and lists every one of those instances as
`optional="true"`. It is **not wired into the build yet**: `device.mk` sets
`PRODUCT_ENFORCE_VINTF_MANIFEST := false` for the bring-up run, so that the first
build is not lost to a hand-written matrix. Stage 2 sets
`DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE` in `BoardConfig.mk` and removes that
line together.

## Repository layout

```
AndroidProducts.mk      product list
lineage_X6532C.mk       product definition
BoardConfig.mk          board configuration (all values from firmware)
device.mk               packages, permissions, properties, GApps hook
system.prop             platform properties
vendor.prop             stock vendor/build.prop (TARGET_VENDOR_PROP)
odm.prop                stock vendor/odm/etc/build.prop (TARGET_ODM_PROP)
extract-files.sh        pull blobs from device/dump
setup-makefiles.sh      generate blob makefiles
proprietary-files.txt   vendor blob list
lineage.dependencies    blob repository
prebuilt/               kernel, dtb, dtbo, modules, modules.load, fstab
rootdir/init/           device init (init.X6532C.rc)
configs/                media configuration
sepolicy/               device policy (x6532c_boot.te)
overlay/                RRO overlays
bin/                    x6532c CLI + x6532c-boot.sh
tools/                  fetch-gapps.sh, gen-vintf-matrix.py
vintf/                  generated device compatibility matrix (stage 2)
gapps/                  Google apps payload (git-ignored, fetched by CI)
```

## Status

The tree is structurally complete and the Android 13 deltas are answered in one
place each: ramdisk in `boot.img` (no `init_boot`), VNDK 31 snapshot alongside a
VNDK 33 platform, and `vendor_boot` built but never flashed so TWRP survives.

What is still open:

1. **On-device bring-up.** Everything here is verified statically against the
   firmware dump; no image produced by this tree has been booted yet.
2. **VINTF enforcement** is disabled for the first build and the compatibility
   matrix is not wired in. See the Build section above.
3. **Kernel** is still the stock prebuilt — there is no MT6765 source for this
   device.
4. **`x6532c_boot` is permissive.** The device-tree sepolicy domain that writes
   the Transsion touch nodes needs the real denial list from a first boot before
   it can be tightened.

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
