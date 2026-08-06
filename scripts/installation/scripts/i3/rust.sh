#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../system/common.sh"

info "[+] Setting up Rust toolchain"

command -v rustup >/dev/null || {
    error "[!] rustup not installed"
    exit 1
}

# -----------------------------
# Toolchains
# -----------------------------
rustup toolchain install stable
rustup toolchain install nightly

rustup default stable

# -----------------------------
# WASM target
# -----------------------------
rustup target add wasm32-unknown-unknown

# -----------------------------
# cargo-binstall (safe install)
# -----------------------------
if ! command -v cargo-binstall >/dev/null; then
    info "[+] Installing cargo-binstall"
    sudo pacman -Syu --needed --noconfirm cargo-binstall
    cargo install cargo-binstall
fi

# -----------------------------
# Rust tools
# -----------------------------
cargo binstall cargo-leptos leptosfmt -y

# -----------------------------
# LspMux
# -----------------------------

LSPMUX_DIR="$HOME/.config/lspmux"

mkdir -p "$LSPMUX_DIR"

cat >"$LSPMUX_DIR/config.toml" <<EOF
instance_timeout = 600
gc_interval = 15

listen = "$LSPMUX_DIR/lspmux.sock"
connect = "$LSPMUX_DIR/lspmux.sock"

log_filters = "info"

pass_environment = ["PATH"]
EOF

systemctl --user daemon-reload

if systemctl --user list-unit-files | grep -q lspmux.socket; then
    systemctl --user enable --now lspmux.socket
else
    systemctl --user enable --now lspmux.service
fi
