#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../system/common.sh"

info "[+] Surface environment setup"

# -----------------------------
# 1. Xresources
# -----------------------------
xres="$HOME/.Xresources"

if [[ ! -f "$xres" ]]; then
    cat >"$xres" <<'EOF'
Xft.dpi: 192
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintfull
Xft.hinting: 1
Xft.antialias: 1
Xft.rgba: rgb
EOF
    ok "[✓] Created .Xresources"
else
    ok "[✓] .Xresources already exists"
fi

# -----------------------------
# 2. xinitrc
# -----------------------------
xinit="$HOME/.xinitrc"

if [[ ! -f "$xinit" ]]; then
    echo "xrdb -merge ~/.Xresources" >"$xinit"
    ok "[✓] Created .xinitrc"
else
    ok "[✓] .xinitrc already exists"
fi
