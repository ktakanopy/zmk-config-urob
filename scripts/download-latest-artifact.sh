#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"
workflow="build.yml"
download_dir="$root_dir/downloaded"
side="${1:-}"
mount_point="${2:-}"
uf2_wait_seconds="${UF2_WAIT_SECONDS:-120}"

if [[ -n "$side" && "$side" != "left" && "$side" != "right" ]]; then
    echo "Usage: $0 [left|right] [mount-point]" >&2
    exit 1
fi

if [[ ! "$uf2_wait_seconds" =~ ^[0-9]+$ ]]; then
    echo "UF2_WAIT_SECONDS must be a non-negative integer." >&2
    exit 1
fi

find_mounted_uf2() {
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

if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) is required." >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated. Run: gh auth login -h github.com" >&2
    exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
    echo "unzip is required." >&2
    exit 1
fi

repo="$(gh repo view --json nameWithOwner --jq '.nameWithOwner')"
run_id="$(gh run list \
    --repo "$repo" \
    --workflow "$workflow" \
    --status success \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId')"

if [[ -z "$run_id" || "$run_id" == "null" ]]; then
    echo "No successful runs found for $workflow in $repo." >&2
    exit 1
fi

rm -rf -- "$download_dir"
mkdir -p -- "$download_dir"

gh run download "$run_id" \
    --repo "$repo" \
    --dir "$download_dir"

while IFS= read -r -d '' archive; do
    extract_dir="${archive%.zip}"
    mkdir -p -- "$extract_dir"
    unzip -q -o "$archive" -d "$extract_dir"
done < <(find "$download_dir" -type f -name '*.zip' -print0)

firmware_files=()
while IFS= read -r -d '' firmware_file; do
    firmware_files+=("$firmware_file")
done < <(find "$download_dir" -type f -name '*.uf2' ! -iname '*settings_reset*' -print0)

if [[ -n "$side" ]]; then
    matching_files=()
    for firmware_file in "${firmware_files[@]}"; do
        if [[ "$(basename -- "$firmware_file")" == *"$side"* ]]; then
            matching_files+=("$firmware_file")
        fi
    done
    firmware_files=("${matching_files[@]}")
fi

if [[ "${#firmware_files[@]}" -ne 1 ]]; then
    echo "Expected exactly one firmware file, found ${#firmware_files[@]}." >&2
    printf '  %s\n' "${firmware_files[@]}" >&2
    echo "Choose a side: $0 left  or  $0 right" >&2
    exit 1
fi

if [[ -z "$mount_point" ]]; then
    for ((attempt = 0; attempt <= uf2_wait_seconds; attempt++)); do
        mount_known_uf2_devices
        find_mounted_uf2

        if [[ "${#mount_points[@]}" -eq 1 ]]; then
            mount_point="${mount_points[0]}"
            break
        fi

        if [[ "${#mount_points[@]}" -gt 1 ]]; then
            echo "More than one UF2 device is mounted." >&2
            printf '  %s\n' "${mount_points[@]}" >&2
            exit 1
        fi

        ((attempt == uf2_wait_seconds)) || sleep 1
    done

    if [[ -z "$mount_point" ]]; then
        echo "No UF2 device appeared within $uf2_wait_seconds seconds." >&2
        echo "Put the keyboard half in bootloader mode or provide its mount point." >&2
        exit 1
    fi
fi

if [[ ! -f "$mount_point/INFO_UF2.TXT" ]]; then
    echo "Not a UF2 bootloader volume: $mount_point" >&2
    exit 1
fi

firmware_file="${firmware_files[0]}"
cp -- "$firmware_file" "$mount_point/"

echo "Downloaded artifacts from run $run_id to $download_dir"
echo "Copied $(basename -- "$firmware_file") to $mount_point"
