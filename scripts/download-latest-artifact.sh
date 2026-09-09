#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"
workflow="build.yml"
download_dir="$root_dir/downloaded"

if [[ "$#" -ne 0 ]]; then
    echo "Usage: $0" >&2
    exit 1
fi

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

echo "Downloaded artifacts from run $run_id to $download_dir"
find "$download_dir" -type f -name '*.uf2' -print
