#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

command -v paru >/dev/null && {
    info "paru already installed"
    exit 0
}

info "[+] Setting up Paru (AUR helper)"

require_package rustup

# ---- Required packages ----
require_package git base-devel rustup

# ---- Ensure rust toolchain ----
if ! rustup toolchain list | grep -q stable; then
    info "Installing Rust stable toolchain"
    rustup toolchain install stable
fi

rustup default stable

# ---- Temp build dir ----
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

info "Using build dir: $BUILD_DIR"

cd "$BUILD_DIR"

# ---- Clone (shallow) ----
git clone --depth 1 https://aur.archlinux.org/paru.git
cd paru

# ---- Build & install ----
makepkg -si --noconfirm

ok "[✓] Paru installed successfully"
