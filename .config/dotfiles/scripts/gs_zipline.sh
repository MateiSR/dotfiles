#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh"

case ${1:-} in
	""|--upload) ;;
	*) printf 'usage: %s [--upload]\n' "$0" >&2; exit 2 ;;
esac

install -d "$(dirname "$FILE")"
"$SCREENSHOT_SCRIPT" -save "$FILE" -copy
[[ -f $FILE ]] || { printf 'error: screenshot was not saved\n' >&2; exit 1; }

[[ ${1:-} == --upload ]] || exit 0
[[ -n $KEY && -n $DOMAIN ]] || { printf 'error: Zipline KEY and DOMAIN are required\n' >&2; exit 1; }

if ! URL=$(curl --fail --silent --show-error \
	-H "authorization: $KEY" \
	-F "file=@$FILE" "https://$DOMAIN/api/upload" \
	| jq -er '.files[0].url | select(type == "string" and length > 0)'); then
	printf 'error: upload failed\n' >&2
	exit 1
fi
printf '%s' "$URL" | wl-copy
printf 'URL copied to clipboard: %s\n' "$URL"
