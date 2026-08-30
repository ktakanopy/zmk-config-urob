#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"

if ! command -v keymap >/dev/null 2>&1 || ! command -v rsvg-convert >/dev/null 2>&1; then
    if [[ "${DRAW_KEYMAP_IN_NIX:-0}" != 1 ]] && command -v nix >/dev/null 2>&1; then
        exec env DRAW_KEYMAP_IN_NIX=1 nix develop "$root_dir" --command "$script_dir/$(basename "$0")" "$@"
    fi

    echo "keymap-drawer e librsvg são necessários." >&2
    echo "Entre no ambiente com 'nix develop' ou instale 'keymap' e 'rsvg-convert'." >&2
    exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

keymap -c "$root_dir/draw/config.yaml" parse -z "$root_dir/config/base.keymap" >"$tmp_dir/base.yaml"
keymap -c "$root_dir/draw/config.yaml" draw "$tmp_dir/base.yaml" -k corne_rotated >"$tmp_dir/base.svg"
rsvg-convert -d 180 -p 180 -o "$tmp_dir/keymap.png" "$tmp_dir/base.svg"

mv "$tmp_dir/base.yaml" "$root_dir/draw/base.yaml"
mv "$tmp_dir/base.svg" "$root_dir/draw/base.svg"
cp "$root_dir/draw/base.svg" "$root_dir/draw/keymap.svg"
mv "$tmp_dir/keymap.png" "$root_dir/draw/keymap.png"

echo "Keymap gerado em $root_dir/draw/keymap.png"
