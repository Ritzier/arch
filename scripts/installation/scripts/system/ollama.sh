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
if [[ -v OLLAMA_PATH ]]; then
    # Create the directory if it doesn't exist
    if [[ ! -d "$OLLAMA_PATH" ]]; then
        sudo mkdir -p "$OLLAMA_PATH"
    fi

    # Ensure the directory is owned by ollama
    current_owner=$(stat -c '%U:%G' "$OLLAMA_PATH" 2>/dev/null || true)
    if [[ "$current_owner" != "ollama:ollama" ]]; then
        sudo chown -R ollama:ollama "$OLLAMA_PATH"
        sudo chmod 755 "$OLLAMA_PATH"
    fi
fi

# ------------------------------
# modify systemd unit file configuration
# ------------------------------
SERVICE_FILE=/usr/lib/systemd/system/ollama.service

if [[ -f "$SERVICE_FILE" ]]; then
    # Remove existing OLLAMA_MODELS lines
    sudo sed -i '/^[[:space:]]*#\?[[:space:]]*Environment="OLLAMA_MODELS=/d' "$SERVICE_FILE"

    if [[ -n "${OLLAMA_PATH:-}" ]]; then
        # Insert custom path while keeping default commented for reference
        sudo sed -i '/^Environment="HOME=/a # Environment="OLLAMA_MODELS=/var/lib/ollama"\nEnvironment="OLLAMA_MODELS='"$OLLAMA_PATH"'"' "$SERVICE_FILE"
    else
        # Restore default configuration
        sudo sed -i '/^Environment="HOME=/a Environment="OLLAMA_MODELS=/var/lib/ollama"' "$SERVICE_FILE"
    fi

    sudo systemctl daemon-reload
fi

# ------------------------------
# enable and restart service
# ------------------------------
SERVICE=ollama
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
