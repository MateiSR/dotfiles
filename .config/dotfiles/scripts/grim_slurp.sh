#!/usr/bin/env bash
set -euo pipefail

usage() {
	printf 'usage: %s [-save <filepath>] [-copy]\n' "$0" >&2
}

(($#)) || { usage; exit 2; }

temp_file=$(mktemp)
freeze_pid=""
cleanup() {
	[[ -z $freeze_pid ]] || kill "$freeze_pid" 2>/dev/null || true
	rm -f -- "$temp_file"
}
trap cleanup EXIT

wayfreeze & freeze_pid=$!
sleep 0.1
grim -g "$(slurp)" "$temp_file" || { printf 'error: screenshot cancelled\n' >&2; exit 1; }
kill "$freeze_pid" 2>/dev/null || true
freeze_pid=""

while (($#)); do
	case $1 in
	-save)
		(($# >= 2)) || { usage; exit 2; }
		cp -- "$temp_file" "$2"
		printf 'Screenshot saved to %s\n' "$2"
		shift 2
		;;
	-copy)
		wl-copy < "$temp_file"
		printf 'Screenshot copied to clipboard\n'
		shift
		;;
	*)
		usage
		exit 2
		;;
	esac
done
