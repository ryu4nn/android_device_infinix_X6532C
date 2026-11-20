#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# setup-makefiles.sh — generate the vendor makefiles (Android.mk, Android.bp,
# BoardConfigVendor.mk) for vendor/infinix/X6532C from proprietary-files.txt.
#

set -e

# Required variables
DEVICE=X6532C
VENDOR=infinix

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false

# Write the makefiles
write_headers
write_makefiles "${MY_DIR}/proprietary-files.txt" true

# Finish
write_footers
