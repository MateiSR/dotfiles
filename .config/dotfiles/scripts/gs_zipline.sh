#!/bin/bash

source "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh"

# Take screenshot, save to file and copy to clipboard
$SCREENSHOT_SCRIPT -save "$FILE" -copy

if [ ! -f "$FILE" ]; then
    echo "Aborted." >&2
    exit 1
fi

echo "Screenshot saved to $FILE and copied to clipboard"

# Upload if --upload flag is passed
if [ "$1" = "--upload" ]; then
    URL=$(curl -s \
      -H "Content-Type: multipart/form-data" \
      -H "authorization: $KEY" \
      -F "file=@$FILE" "https://$DOMAIN/api/upload" | jq -r '.files[0].url')

    if [ -n "$URL" ] && [ "$URL" != "null" ]; then
        printf "%s" "$URL" | wl-copy
        echo "URL copied to clipboard: $URL"
    else
        echo "Upload failed" >&2
        exit 1
    fi
fi

