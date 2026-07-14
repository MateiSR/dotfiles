#!/usr/bin/env bash
set -euo pipefail

STATE_DIR=${MATUGEN_SDDM_STATE_DIR:-/var/lib/matugen-sddm}
CONFIG=${MATUGEN_SDDM_CONFIG:-${XDG_CACHE_HOME:-$HOME/.cache}/matugen/sddm-astronaut.conf}
SYNC_MODE=${MATUGEN_SDDM_SYNC:-0}

if (($# > 1)); then
	printf 'usage: %s [wallpaper]\n' "$0" >&2
	exit 2
fi

if [[ ! -d "$STATE_DIR" || ! -w "$STATE_DIR" ]]; then
	[[ $SYNC_MODE == 1 ]] && exit 0
	printf 'error: run install.sh once to configure SDDM\n' >&2
	exit 1
fi

if (($# == 1)) && [[ $SYNC_MODE != 1 ]]; then
	[[ -f $1 ]] || { printf 'error: wallpaper not found: %s\n' "$1" >&2; exit 1; }
	exec matugen image "$1" --source-color-index 0
fi

[[ -f "$CONFIG" ]] || { printf 'error: generated config not found: %s\n' "$CONFIG" >&2; exit 1; }

image=""
while IFS= read -r line; do
	case $line in
		'# MatugenImage='*) image=${line#\# MatugenImage=}; break ;;
	esac
done < "$CONFIG"

[[ -n "$image" && -f "$image" ]] || { printf 'error: generated wallpaper is unavailable: %s\n' "$image" >&2; exit 1; }

tmp_config=$(mktemp "$STATE_DIR/.theme.conf.XXXXXXXX")
tmp_wallpaper=$(mktemp "$STATE_DIR/.wallpaper.XXXXXXXX")
cleanup() { rm -f -- "$tmp_config" "$tmp_wallpaper"; }
trap cleanup EXIT

install -m 0644 "$CONFIG" "$tmp_config"
install -m 0644 "$image" "$tmp_wallpaper"
mv -f -- "$tmp_wallpaper" "$STATE_DIR/wallpaper"
mv -f -- "$tmp_config" "$STATE_DIR/theme.conf"
trap - EXIT

printf 'SDDM theme updated.\n'
