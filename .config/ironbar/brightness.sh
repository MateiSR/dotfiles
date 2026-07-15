#!/bin/sh

backlights() {
	brightnessctl --class backlight --list --machine-readable
}

case ${1:-} in
get)
	backlights | awk -F, 'NR == 1 { sub(/%$/, "", $4); print $4; found = 1 } END { exit !found }'
	;;
label)
	backlights | awk -F, '{ printf "%sDisplay %d  %s", NR == 1 ? "" : "   ·   ", NR, $4 } END { if (NR) print ""; exit !NR }'
	;;
set)
	value=${2%.*}
	case $value in
		'' | *[!0-9]*) exit 2 ;;
	esac
	[ "$value" -ge 5 ] && [ "$value" -le 100 ] || exit 2
	devices=$(backlights | cut -d, -f1)
	[ -n "$devices" ] || exit 1
	printf '%s\n' "$devices" | while IFS= read -r device; do
		brightnessctl --quiet --device "$device" set "$value%"
	done
	;;
*)
	exit 2
	;;
esac
