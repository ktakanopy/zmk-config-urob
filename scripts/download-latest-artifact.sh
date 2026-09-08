#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
root_dir="$(cd -- "$script_dir/.." && pwd)"
workflow="build.yml"
download_dir="$root_dir/downloaded"

if ! command -v gh >/dev/null 2>&1; then
    echo "GitHub CLI (gh) is required." >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated. Run: gh auth login -h github.com" >&2
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

echo "Downloaded artifacts from run $run_id to $download_dir"
