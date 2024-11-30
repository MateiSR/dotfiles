#!/bin/bash

# Get the current monitor in focus
current_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

if [ $# -ne 2 ]; then
    echo "Usage: monitor_toggle.sh <monitor1> <monitor2>" >&2
    exit 1
fi

# Define the monitor names
monitor1=$1
monitor2=$2
echo "Monitor 1: $monitor1"
echo "Monitor 2: $monitor2"

# Toggle focus between the monitors
if [ "$current_monitor" != "$monitor1" ]; then
    hyprctl dispatch focusmonitor "$monitor1"
else
    hyprctl dispatch focusmonitor "$monitor2"
fi

