#!/usr/bin/env bash

set -euo pipefail

wait_seconds="${1:-${UF2_WAIT_SECONDS:-120}}"

if [[ ! "$wait_seconds" =~ ^[0-9]+$ ]]; then
    echo "Wait time must be a non-negative integer." >&2
    exit 1
fi

find_mounted_uf2() {
    local mount_root info_file
    mount_points=()

    for mount_root in /Volumes "/run/media/$USER" "/media/$USER"; do
        [[ -d "$mount_root" ]] || continue
        while IFS= read -r -d '' info_file; do
            mount_points+=("$(dirname -- "$info_file")")
        done < <(find "$mount_root" -maxdepth 2 -type f -name INFO_UF2.TXT -print0 2>/dev/null)
    done
}

mount_known_uf2_devices() {
    command -v lsblk >/dev/null 2>&1 || return 0
    command -v udisksctl >/dev/null 2>&1 || return 0

    while IFS= read -r device; do
        [[ -n "$device" ]] || continue
        udisksctl mount --block-device "$device" >/dev/null 2>&1 || true
    done < <(lsblk -rpno PATH,LABEL | awk 'toupper($2) ~ /^(NICENANO|NRF52BOOT|UF2)/ { print $1 }')
}

for ((attempt = 0; attempt <= wait_seconds; attempt++)); do
    mount_known_uf2_devices
    find_mounted_uf2

    if [[ "${#mount_points[@]}" -eq 1 ]]; then
        printf '%s\n' "${mount_points[0]}"
        exit 0
    fi

    if [[ "${#mount_points[@]}" -gt 1 ]]; then
        echo "More than one UF2 device is mounted." >&2
        printf '  %s\n' "${mount_points[@]}" >&2
        exit 1
    fi

    ((attempt == wait_seconds)) || sleep 1
done

echo "No UF2 device appeared within $wait_seconds seconds." >&2
echo "Put the keyboard half in bootloader mode and try again." >&2
exit 1
