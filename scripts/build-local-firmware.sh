#!/usr/bin/env bash

set -euo pipefail

side="${1:-}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"
container="${ZMK_BUILD_CONTAINER:-zmk-build}"
sdk_dir="${ZEPHYR_SDK_INSTALL_DIR:-$HOME/.local/zephyr-sdk-0.16.5}"
west="$HOME/.local/venvs/zmk/bin/west"

if [[ "$side" != "left" && "$side" != "right" ]]; then
    echo "Usage: $0 left|right" >&2
    exit 1
fi

command -v podman >/dev/null 2>&1 || { echo "podman is required." >&2; exit 1; }
[[ -x "$west" ]] || { echo "west was not found at $west." >&2; exit 1; }
[[ -d "$sdk_dir" ]] || { echo "Zephyr SDK was not found at $sdk_dir." >&2; exit 1; }

podman start "$container" >/dev/null

build_dir="$root_dir/.build/deck-corne-$side"
firmware_dir="$root_dir/firmware"
firmware_file="$firmware_dir/corne_${side}-nice_nano_v2.uf2"

if [[ "$side" == "left" ]]; then
    shield="corne_left nice_view_adapter nice_view_dual"
else
    shield="corne_right"
fi

podman exec \
    --user "$(id -u):$(id -g)" \
    --workdir "$root_dir" \
    --env "HOME=$HOME" \
    --env "ZEPHYR_SDK_INSTALL_DIR=$sdk_dir" \
    "$container" \
    "$west" build \
        -s "$root_dir/zmk/app" \
        -d "$build_dir" \
        -b nice_nano_v2 -- \
        "-DZMK_CONFIG=$root_dir/config" \
        "-DSHIELD=$shield" >&2

mkdir -p -- "$firmware_dir"
cp -- "$build_dir/zephyr/zmk.uf2" "$firmware_file"
printf '%s\n' "$firmware_file"
