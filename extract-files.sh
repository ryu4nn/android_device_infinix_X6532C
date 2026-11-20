#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# extract-files.sh — pull the proprietary blobs of the Infinix Smart 9 HD
# (X6532C) into vendor/infinix/X6532C.
#
#   ./extract-files.sh                 # from a connected device over adb
#   ./extract-files.sh /path/to/dump   # from a directory of mounted partitions
#

set -e

# Required variables
DEVICE=X6532C
VENDOR=infinix
DEVICE_COMMON=X6532C

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Device specific fixups (patchelf / hex edits) go here.
function blob_fixup() {
    case "${1}" in
    # Example:
    #    vendor/lib/libfoo.so)
    #        "${PATCHELF}" --replace-needed "libbar.so" "libbar_v31.so" "${2}"
    #        ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

if [ -z "${SECTION}" ]; then
    "${MY_DIR}/setup-makefiles.sh"
fi
