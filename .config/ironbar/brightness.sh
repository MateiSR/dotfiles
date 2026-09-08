#!/bin/sh
# Per-display backlight helper for ironbar.
# Displays are addressed by 1-based index into the name-sorted backlight list.

state=${XDG_RUNTIME_DIR:-/tmp}/ironbar-brightness-sync

devices() {
	brightnessctl --class backlight --list --machine-readable | cut -d, -f1 | sort
}

device_at() {
	devices | sed -n "${1}p"
}

percent_at() {
	device=$(device_at "$1")
	[ -n "$device" ] || return 1
	brightnessctl --class backlight --list --machine-readable |
		awk -F, -v d="$device" '$1 == d { sub(/%$/, "", $4); print $4; found = 1 } END { exit !found }'
}

apply() {
	for device in $1; do
		brightnessctl --quiet --class backlight --device "$device" set "$2%"
	done
}

index=${2:-1}

case ${1:-} in
get)
	percent_at "$index"
	;;
label)
	device=$(device_at "$index")
	[ -n "$device" ] || exit 1
	model=$(cat "/sys/class/backlight/$device/device/idModel" 2>/dev/null)
	printf '%s\n' "${model:-$device}"
	;;
has)
	[ -n "$(device_at "$index")" ]
	;;
synced)
	[ -f "$state" ]
	;;
row)
	# A per-display row is shown only while sync is off and that display exists.
	[ ! -f "$state" ] && [ -n "$(device_at "$index")" ]
	;;
sync-icon)
	# nf-md-link / nf-md-link_off, as octal UTF-8 so the glyphs survive editing.
	if [ -f "$state" ]; then
		printf '\363\260\214\267\n'
	else
		printf '\363\260\214\270\n'
	fi
	;;
toggle)
	if [ -f "$state" ]; then
		rm -f "$state"
	else
		: >"$state"
		value=$(percent_at 1) && apply "$(devices)" "$value"
	fi
	;;
set)
	value=${3%.*}
	case $value in
		'' | *[!0-9]*) exit 2 ;;
	esac
	[ "$value" -ge 5 ] && [ "$value" -le 100 ] || exit 2
	if [ "$index" = all ] || [ -f "$state" ]; then
		targets=$(devices)
	else
		targets=$(device_at "$index")
	fi
	[ -n "$targets" ] || exit 1
	apply "$targets" "$value"
	;;
*)
	exit 2
	;;
esac
