#!/bin/bash
set -euo pipefail

QUEUE_DIR="/mnt/mergerfs/ffmpeg"

mkdir -p "$QUEUE_DIR"

for file in "$@"; do
    [[ -f "$file" ]] || {
        echo "Skipping missing file: $file"
        continue
    }

    ln -s -- "$file" "$QUEUE_DIR/$(basename "$file")"
done
