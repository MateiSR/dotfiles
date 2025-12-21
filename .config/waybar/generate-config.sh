#!/bin/bash

# Waybar Dynamic Config Generator
# Automatically detects system capabilities and generates appropriate config

CONFIG_DIR="$HOME/.config/waybar"
TEMPLATE="$CONFIG_DIR/config.template.jsonc"
OUTPUT="$CONFIG_DIR/config.jsonc"

# Detect system capabilities
has_battery() {
    [ -d /sys/class/power_supply/BAT* ] 2>/dev/null || \
    [ -d /sys/class/power_supply/battery ] 2>/dev/null
}

has_backlight() {
    [ -d /sys/class/backlight/* ] 2>/dev/null
}

has_bluetooth() {
    command -v bluetoothctl >/dev/null 2>&1 && \
    [ -d /sys/class/bluetooth ] 2>/dev/null
}

# Build modules-right array dynamically
build_modules_right() {
    local modules=()

    # Core modules that are always present
    modules+=("network")

    # Conditional modules
    if has_bluetooth; then
        modules+=("bluetooth")
    fi

    modules+=("pulseaudio")

    if has_backlight; then
        modules+=("backlight")
    fi

    modules+=("tray")
    modules+=("custom/notifications")

    if has_battery; then
        modules+=("battery")
    fi

    modules+=("custom/power")

    # Build JSON array with separators between modules
    local result="["
    local first=true
    for module in "${modules[@]}"; do
        if [ "$first" = true ]; then
            result+="\"$module\""
            first=false
        else
            result+=", \"custom/separator\", \"$module\""
        fi
    done
    result+="]"

    echo "$result"
}

# Generate the config
generate_config() {
    local modules_right=$(build_modules_right)

    # Read template and replace MODULES_RIGHT placeholder
    if [ -f "$TEMPLATE" ]; then
        echo "Generating config..."
        sed "s|\"MODULES_RIGHT\"|$modules_right|g" "$TEMPLATE" > "$OUTPUT"
        echo "Config generated successfully at $OUTPUT"
        echo "Modules right: $modules_right"
    else
        echo "Error: Template file not found at $TEMPLATE"
        exit 1
    fi
}

# Main
generate_config
