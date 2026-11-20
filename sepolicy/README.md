# Device sepolicy — Infinix Smart 9 HD (X6532C)

This directory holds the device tree's **system-side** SELinux policy.

The MT6765 **vendor** policy is prebuilt inside the vendor partition
(`vendor/etc/selinux/`) and is kept as-is, so nothing here duplicates it.

## What belongs here

Rules required by services/binaries that the device tree adds to system (for
example, the Trustonic keystore bring-up, MTK kernel-module loading, or
device-specific `/sys` nodes). During bring-up, watch `avc: denied` lines in
`dmesg`/`logcat` and add the corresponding `allow` rules here.

## Wiring

Enabled from `BoardConfig.mk` with:

```make
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
```

## Status

Empty on purpose. The stock vendor policy is sufficient for the base system;
device rules are added only when a denial is actually observed, so the policy
stays minimal and honest.
