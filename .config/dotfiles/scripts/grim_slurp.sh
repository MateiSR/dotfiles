#!/bin/bash

# Create a temporary file to store the screenshot
temp_file=$(mktemp)

# Freeze screen, capture screenshot using grim and slurp, then unfreeze
wayfreeze & PID=$!
sleep 0.1
grim -g "$(slurp)" "$temp_file"
grim_status=$?
kill $PID 2>/dev/null

if [ $grim_status -ne 0 ]; then
    echo "Error capturing screenshot."
    rm -f "$temp_file"
    exit 1
fi

# Check number of args
if [ $# -eq 0 ]; then
    echo "No arguments provided."
    echo "Usage: $0 -save <filepath> | -copy"
    rm -f "$temp_file"
    exit 1
fi

# Process arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -save)
            if [ -z "$2" ]; then
                echo "Error: -save requires a filepath."
                rm -f "$temp_file"
                exit 1
            fi
            cp "$temp_file" "$2"
            echo "Screenshot saved to $2"
            shift 2
            ;;
        -copy)
            # Copy from temp file to clipboard
            cat "$temp_file" | wl-copy
            echo "Screenshot copied to clipboard"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 -save <filepath> | -copy"
            rm -f "$temp_file"
            exit 1
            ;;
    esac
done

# Clean up the temporary file
rm -f "$temp_file"
exit 0
