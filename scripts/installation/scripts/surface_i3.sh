#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$SCRIPT_DIR/../config/surface_i3.conf"
PACKAGES="$SCRIPT_DIR/../i3_packages/surface"
AUR_PACKAGES="$SCRIPT_DIR/../i3_packages/aur_packages"

# Load `common` utils
source "$SCRIPT_DIR/system/common.sh"

# Load `config`
load_config "$CONFIG"

# Required fields
FIELDS=(
    SERVICES
)
for f in "${FIELDS[@]}"; do
    [[ -n "${!f:-}" ]] || fail "missing field: $f "
done

# ---- Fix Cache ----
bash "$SCRIPT_DIR/system/fix_cache.sh"

# ---- Install packages ----
bash "$SCRIPT_DIR/system/packages.sh" "$PACKAGES"

# ---- Paru ----
bash "$SCRIPT_DIR/i3/paru.sh"

# ---- Aur Packages Install ----
bash "$SCRIPT_DIR/i3/aur_packages.sh" "$AUR_PACKAGES"

# ---- Copy Path ----
bash "$SCRIPT_DIR/i3/copy_config.sh"

# ---- Rust Toolchain ----
bash "$SCRIPT_DIR/i3/rust.sh" || true

# ---- Systemctl User ----
bash "$SCRIPT_DIR/i3/systemctl.sh" "$CONFIG" || true

# ---- VAAPI ----
bash "$SCRIPT_DIR/i3/vaapi.sh"

# ---- ZSH -----
bash "$SCRIPT_DIR/i3/zsh.sh"
bash "$SCRIPT_DIR/i3/zsh_theme.sh"

# ---- Fcitx5 ----
bash "$SCRIPT_DIR/i3/fcitx5_theme.sh"

# ---- Dark Theme ----
bash "$SCRIPT_DIR/i3/dark.sh"

# ---- Podman ----
bash "$SCRIPT_DIR/i3/podman.sh"

# ---- Surface ----
bash "$SCRIPT_DIR/i3/surface/surface.sh"
bash "$SCRIPT_DIR/i3/surface/polybar.sh"
