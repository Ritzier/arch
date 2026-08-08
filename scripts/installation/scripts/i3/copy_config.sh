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

# -----------------------------
# 1. Copy .config
# -----------------------------
if [[ -d "$src/.config" ]]; then
    info "[+] Syncing ~/.config"

    mkdir -p "$HOME/.config"

    rsync -a --update "$src/.config/" "$HOME/.config/"
fi

# -----------------------------
# 2. Copy .local
# -----------------------------
if [[ -d "$src/.local" ]]; then
    info "[+] Syncing ~/.local"

    mkdir -p "$HOME/.local"

    rsync -a --update "$src/.local/" "$HOME/.local/"
fi

# -----------------------------
# 3. Copy .local
# -----------------------------
if [[ -d "$src/.cargo" ]]; then
    info "[+] Syncing ~/.local"

    mkdir -p "$HOME/.local"

    rsync -a --update "$src/.local/" "$HOME/.local/"
fi

# -----------------------------
# 4. Copy root dotfiles (like .zshrc, .xinitrc)
# -----------------------------
info "[+] Syncing root dotfiles"

shopt -s dotglob nullglob

for file in "$src"/.* "$src"/*; do
    [[ -f "$file" ]] || continue

    name="$(basename "$file")"

    # skip . and ..
    [[ "$name" == "." || "$name" == ".." ]] && continue

    # skip directories
    [[ -d "$file" ]] && continue

    # avoid overwriting sensitive system-managed files if needed
    case "$name" in
    .gitignore | .git | README.md)
        continue
        ;;
    esac

    info "[+] Installing $name → $HOME/$name"
    cp -f "$file" "$HOME/$name"
done

# -----------------------------
# 5. Copy .local
# -----------------------------
if [[ -d "$src/scripts" ]]; then
    info "[+] Syncing ~/scripts"

    mkdir -p "$HOME/scripts"

    rsync -a --update "$src/scripts/" "$HOME/scripts/"
fi

shopt -u dotglob nullglob

ok "[✓] Config sync complete"
