#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# validate inputs
# ------------------------------
if [[ $# -lt 1 || -z "${1:-}" ]]; then
    echo "Usage: $0 <config_file>" >&2
    exit 1
fi

CONFIG_FILE="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

load_config "${CONFIG_FILE}"

# ------------------------------
# validate required variables
# ------------------------------
: "${OLLAMA:?GPU is not set in config}"

packages=()

case "$OLLAMA" in
ollama | ollama-cuda | ollama-vulkan | ollama-rocm)
    packages+=("$OLLAMA")
    ;;
*)
    error "[!] Unknown Ollama: $OLLAMA"
    exit 1
    ;;
esac

# ------------------------------
# package validation / install
# ------------------------------
require_package "${packages[@]}"

# ------------------------------
# configure ollama storage directory
# ------------------------------
OLLAMA_OVERRIDE_DIR="/etc/systemd/system/ollama.service.d"
OLLAMA_OVERRIDE_FILE="$OLLAMA_OVERRIDE_DIR/override.conf"

sudo mkdir -p "$OLLAMA_OVERRIDE_DIR"
sudo tee "$OLLAMA_OVERRIDE_FILE" >/dev/null <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_ORIGINS=*"
EOF

# Configure custom model storage directory
if [[ -v OLLAMA_PATH ]]; then
    sudo tee -a "$OLLAMA_OVERRIDE_FILE" >/dev/null <<EOF
Environment="OLLAMA_MODELS=$OLLAMA_PATH" 
EOF
fi

# ------------------------------
# enable and restart service
# ------------------------------
SERVICE=ollama
sudo systemctl daemon-reload
if systemctl is-active --quiet "$SERVICE"; then
    echo "Restarting $SERVICE..."
    sudo systemctl restart "$SERVICE"
else
    echo "Enabling and starting $SERVICE..."
    sudo systemctl enable --now "$SERVICE"
fi

# ------------------------------
# wait for service status verification
# ------------------------------
for ((i = 0; i < 10; i++)); do
    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE is running."
        exit 0
    fi
    sleep 1
done

echo "ERROR: $SERVICE failed to start." >&2
systemctl --no-pager --full status "$SERVICE"
exit 1
