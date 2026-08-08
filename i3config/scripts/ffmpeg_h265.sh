#!/bin/bash

# =============================================================================
# Description:
#   Monitors a directory for new video files and processes them with ffmpeg,
#   distributing the encoding workload across multiple CPU core sets (CCD-aware).
#   Uses inotifywait for real-time file detection and maintains a queue system
#   with automatic load balancing.
#
# Architecture:
#   - Watches /mnt/mergerfs/ffmpeg for new files
#   - Uses a dual-CPUSET system (presumably for dual CCD/CCX CPUs like AMD EPYC)
#   - Each CPUSET handles one encoding job at a time
#   - Automatically assigns free CPUSETs to new jobs
#   - Prevents duplicate processing with .processing markers
#
# Key Features:
#   - Real-time monitoring via inotifywait
#   - CPU affinity control via taskset
#   - Automatic job queue management
#   - Skip already processed files
#   - Non-blocking parallel processing (max 2 concurrent jobs)
#   - Cleanup of temporary marker files
# =============================================================================

set -euo pipefail # Strict mode: exit on error, undefined variables, pipe failures

# =============================================================================
# CONFIGURATION
# =============================================================================

# Directory to monitor for new video files
WATCH_DIR="/mnt/mergerfs/ffmpeg"

# CPU core assignments for each processing slot
# Each CPUSET defines which physical cores to use for encoding
# Designed for dual-CCD/CCX CPUs (e.g., AMD EPYC, Ryzen with multiple CCXs)
# CPUSET[0]: First CCD (cores 0,2,4,6,8,10,12,14,16-23)
# CPUSET[1]: Second CCD (cores 1,3,5,7,9,11,13,15,24-31)
# This ensures each encoding job stays within one CCD for better cache locality
CPUSETS=(
    "0,2,4,6,8,10,12,14,16-23" # Processing slot 0
    "1,3,5,7,9,11,13,15,24-31" # Processing slot 1
)

# =============================================================================
# GLOBALS
# =============================================================================

# Array tracking PIDs currently using each CPUSET
# Empty string = CPUSET is free, PID = currently in use
declare -a PIDS=("" "")

# =============================================================================
# MAIN PROCESSING LOOP
# =============================================================================

while :; do
    found=0 # Flag: 1 if we found and processed a file, 0 if queue was empty

    # Iterate through all files in the watch directory
    for queue in "$WATCH_DIR"/*; do
        # Skip if no files exist
        [[ -e "$queue" ]] || continue

        # Skip files that are already being processed (have .processing extension)
        [[ "$queue" == *.processing ]] && continue

        # Mark file as being processed
        found=1
        processing="$queue.processing"
        mv "$queue" "$processing"

        # Get absolute path to the file
        file=$(readlink -f "$processing")

        # Validate the input file exists
        [[ -f "$file" ]] || {
            echo "Missing input: $file"
            rm -f "$processing"
            continue
        }

        # Generate output filename (convert to h265)
        output="${file%.*}-h265.mp4"

        # Skip if output already exists (previons run completed)
        if [[ -f "$output" ]]; then
            echo "Skipping existing output: $output"
            rm -f "$processing"
            continue
        fi

        # =====================================================================
        # CPUSET ALLOCATION - Find an available processing slot
        # =====================================================================
        while :; do
            free_index=-1

            # Check each CPUSET slot
            for i in "${!CPUSETS[@]}"; do
                pid="${PIDS[$i]}"

                # Slot is free if no PID assigned
                if [[ -z "$pid" ]]; then
                    free_index=$i
                    break
                fi

                # Check if the process is still running
                # kill -0 sends no signal, just checks if process exists
                if ! kill -0 "$pid" 2>/dev/null; then
                    # Process died, free up the slot
                    PIDS[$i]=""
                    free_index=$i
                    break
                fi
            done

            # Exit allocation loop if we found a free slot
            ((free_index >= 0)) && break

            # No free slots - wait for any child process to finish
            # wait -n waits for the next child process to exit
            wait -n
        done

        # =====================================================================
        # START ENCODING JOB
        # =====================================================================
        echo "Starting: $file"
        echo "CPUSET[$free_index]: ${CPUSETS[$free_index]}"

        # Launch ffmpeg with CPU affinity and optimized settings
        taskset -c "${CPUSETS[$free_index]}" \
            ffmpeg -hide_banner \
            -threads 16 \
            -i "$file" \
            -c:v libx265 \
            -x265-params "pools=16" \
            -vtag hvc1 \
            -c:a copy \
            "$output" &

        # Store the PID of the background process
        PIDS[$free_index]=$!

        # Remove the .processing marker immediately after starting
        # The file is no longer in the queue; it's being actively processed
        rm -f "$processing"
    done

    # =====================================================================
    # QUEUE EMPTY - Wait for new files
    # =====================================================================
    # If no files were found in the directory, wait for new files to appear
    ((found == 0)) &&
        inotifywait -q \
            -e create \
            -e moved_to \
            "$WATCH_DIR"
done

# =============================================================================
# NOTES:
# =============================================================================
# 1. This script is designed to run indefinitely (while : loop)
# 2. Handles a maximum of 2 concurrent encoding jobs (one per CPUSET)
# 3. Uses the .processing extension as a lock file to prevent duplicate processing
# 4. x265 pools parameter is set to 16 to match the thread count
# 5. Audio is stream-copied (-c:a copy) to preserve quality and speed
# 6. The script uses set -euo pipefail for robustness
# 7. CPU core assignments should be adjusted based on your specific CPU topology
# 8. For AMD CPUs, using separate CCDs reduces L3 cache contention
# =============================================================================
