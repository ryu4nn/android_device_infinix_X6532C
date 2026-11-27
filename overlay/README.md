# RRO overlay — Infinix Smart 9 HD (X6532C)

Static (build-time) framework/package overlays for device-specific defaults,
such as telephony, display, power and connectivity booleans.

## Convention

```
overlay/
  frameworks/base/core/res/res/values/config.xml
  packages/apps/Settings/res/values/config.xml
  ...
```

Each overlay is picked up automatically by the build when the directory is
listed in the product makefile via `PRODUCT_PACKAGE_OVERLAYS` (LineageOS adds
`$(LOCAL_PATH)/overlay` by convention, but it must be declared).

## Status

Empty placeholder. Real values are added during bring-up once the stock vendor
defaults are known to need overriding on LineageOS 20.0.
