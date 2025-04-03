#!/bin/bash
IMAGEPATH="$HOME/Pictures/Screenshots" # Where to store screenshots before they're deleted
timestamp=$(date +"%m-%d-%y-T%H-%M-%S")
IMAGENAME="Screenshot-zipline-$timestamp" # Not really important, tells Flameshot what file to send and delete
KEY=""
DOMAIN="" # Your upload domain (without http:// or https://)
FILE="$IMAGEPATH/$IMAGENAME.png" # File path and file name combined
SCREENSHOT_SCRIPT="$HOME/.config/dotfiles/scripts/grim_slurp.sh" # Path to the grim_slurp script
