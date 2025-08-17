#!/bin/bash

# Get the current directory
CURRENT_DIR="$(pwd)"

# Check if copyparty is already running and kill it
pids=$(pgrep -f "copyparty.*-p 8080")
if [ -n "$pids" ]; then
    echo "Killing existing copyparty instances with PIDs: $pids"
    kill $pids
    sleep 2
fi

# Create a temporary directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download copyparty to the temporary directory
curl -L https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py -o "$TMP_DIR/copyparty-sfx.py"

# Make it executable
chmod +x "$TMP_DIR/copyparty-sfx.py"

# Run copyparty with the current directory as the only shared folder
# Added --no-db to avoid database conflicts
python3 "$TMP_DIR/copyparty-sfx.py" -p 8080 --no-db -v ".:$(basename "$CURRENT_DIR"):rw"