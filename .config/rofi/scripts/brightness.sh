#!/bin/bash

# Rofi theme configuration
# Ensure this path is correct for your system. Rofi usually expands '~'.
THEME_PATH="~/.config/rofi/themes/squared-material-dark-orange.rasi"

# Function to display errors using Rofi
show_rofi_error() {
    rofi -e "$1" -theme "$THEME_PATH"
}

# Check for required commands
if ! command -v rofi &> /dev/null; then
    echo "Error: rofi command not found. Please install rofi." >&2
    # Attempt to show error in rofi if possible, though rofi itself is missing.
    # This is a fallback if the script is run from a terminal.
    exit 1
fi

if ! command -v ddcutil &> /dev/null; then
    show_rofi_error "Error: ddcutil command not found. Please install ddcutil."
    echo "Error: ddcutil command not found. Please install ddcutil." >&2
    exit 1
fi

if ! command -v wayland-info &> /dev/null; then
    show_rofi_error "Error: wayland-info command not found. Please install it (e.g., part of wayland-utils)."
    echo "Error: wayland-info command not found. Please install it." >&2
    exit 1
fi

# Get number of monitors using wayland-info
# stderr is redirected to /dev/null to suppress errors if wayland-info fails for some reason
NUM_MONITORS=$(wayland-info 2>/dev/null | grep -c "interface: 'wl_output'")

# Exit if no monitors are found
if [ "$NUM_MONITORS" -eq 0 ]; then
    show_rofi_error "No Wayland outputs (monitors) found."
    echo "No Wayland outputs (monitors) found. Exiting." >&2
    exit 1
fi

# Prompt user for brightness value using rofi
# -dmenu: run in dmenu mode (accepts typed input)
# -p: prompt text displayed to the user
# -mesg: an initial message or instruction
# -theme: path to the Rofi theme file
SELECTED_VALUE=$(rofi -dmenu \
                    -theme "$THEME_PATH" \
                    -p "Brightness" \
                    -mesg "Enter brightness level (1-100)")

# Check if the user cancelled rofi (e.g., pressed Esc, resulting in empty selection)
if [ -z "$SELECTED_VALUE" ]; then
    # echo "No value entered. Exiting gracefully." >&2 # Optional: log to stderr
    exit 0 # Exit gracefully if rofi was cancelled
fi

# Validate the input:
# 1. Check if it's an integer.
# 2. Check if it's within the 1-100 range.
if ! [[ "$SELECTED_VALUE" =~ ^[0-9]+$ ]]; then
    show_rofi_error "Invalid input: '$SELECTED_VALUE' is not a valid number."
    exit 1
fi

# Convert to integer for numerical comparison
BRIGHTNESS_LEVEL=$((SELECTED_VALUE))

if [ "$BRIGHTNESS_LEVEL" -lt 1 ] || [ "$BRIGHTNESS_LEVEL" -gt 100 ]; then
    show_rofi_error "Invalid input: Brightness must be between 1 and 100. You entered '$BRIGHTNESS_LEVEL'."
    exit 1
fi

# Set brightness for all detected monitors
# ddcutil display numbers are typically 1-indexed (e.g., Display 1, Display 2).
# This loop iterates from 1 up to the number of monitors found.
SUCCESS_COUNT=0
FAILURE_COUNT=0
for (( display_num=1; display_num<="$NUM_MONITORS"; display_num++ )); do
    # echo "Attempting to set brightness to $BRIGHTNESS_LEVEL% for display $display_num..." # For debugging
    if ddcutil setvcp 10 "$BRIGHTNESS_LEVEL" --display "$display_num"; then
        # echo "Successfully set brightness for display $display_num." # For debugging
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        # If ddcutil fails for a specific display, show a message.
        # This might occur if a display doesn't support DDC/CI,
        # or if permissions for /dev/i2c-* devices are not correctly set.
        show_rofi_error "Failed to set brightness for display $display_num. Check ddcutil setup (permissions, i2c-dev module) or display compatibility."
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        # The script will continue trying to set brightness for other monitors.
    fi
done

if [ "$SUCCESS_COUNT" -gt 0 ] && [ "$FAILURE_COUNT" -eq 0 ]; then
    # Optionally, show a success message if all went well.
    # notify-send "Brightness" "Set to $BRIGHTNESS_LEVEL% for $SUCCESS_COUNT monitor(s)." -t 2000
    : # Do nothing, success is implicit
elif [ "$SUCCESS_COUNT" -eq 0 ] && [ "$FAILURE_COUNT" -gt 0 ]; then
    show_rofi_error "Failed to set brightness for any monitor."
elif [ "$SUCCESS_COUNT" -gt 0 ] && [ "$FAILURE_COUNT" -gt 0 ]; then
    show_rofi_error "Set brightness for $SUCCESS_COUNT monitor(s), but failed for $FAILURE_COUNT."
fi

exit 0

