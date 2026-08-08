#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

src="$SCRIPT_DIR/../../../../i3config"

info "[+] Copying configuration from: $src"

if [[ ! -d "$src" ]]; then
    error "[!] Config source not found: $src"
    exit 1
fi

rsync -a --update "$src/" "$HOME/"

ok "[✓] Config sync complete"
