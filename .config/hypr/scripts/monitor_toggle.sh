#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: monitor_toggle.sh <monitor1> <monitor2>" >&2
	exit 1
fi

monitor1=$1
monitor2=$2
current_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Hyprland 0.55+ Lua config requires Lua dispatch syntax over IPC;
# the legacy `focusmonitor <name>` form no longer parses.
if [ "$current_monitor" != "$monitor1" ]; then
	target=$monitor1
else
	target=$monitor2
fi

hyprctl dispatch "hl.dsp.focus({ monitor = \"${target}\" })"
