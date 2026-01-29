#!/bin/bash

source "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh"

echo "Saving screenshot to $FILE"

# run grim_slurp script
$SCREENSHOT_SCRIPT -save "$FILE" -copy

if [ -f "$FILE" ]; then
    echo "$FILE exists."
    wl-copy < $FILE
    
    URL=$(curl \
      -H "Content-Type: multipart/form-data" \
      -H "authorization: $KEY" \
      -F "file=@$FILE" "https://$DOMAIN/api/upload" | jq -r '.files[0]' | jq -r '.url')
    # printf instead of echo as echo appends a newline
    wl-copy $(printf "%s" "$URL")
    echo "URL copied to clipboard: $URL"
    # rm "$IMAGEPATH$IMAGENAME.png" # Delete the image locally
    notify-send "Screenshot Uploaded" "Screenshot uploaded and link copied to clipboard." --icon=dialog-information
else 
    echo "Aborted." >&2
fi

