#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"

info "[+] Fixing cache directory permissions"

# Ensure directory exists
mkdir -p "$CACHE_DIR"

# Restore ownership
sudo chown -R "$USER:$USER" "$CACHE_DIR"

# Restrict directory permissions
chmod 755 "$CACHE_DIR"

ok "[✓] Cache permissions fixed"
