#!/usr/bin/env bash
# Bootstrap these dotfiles on a fresh machine.
set -euo pipefail
cd "$(dirname "$0")"

command -v stow >/dev/null || { echo "install stow first: pacman -S stow" >&2; exit 1; }

stow --no-folding -v -t "$HOME" .

# Machine-local files, created from examples if missing (gitignored, never committed).
cp -n .config/dotfiles/machine.lua.example "$HOME/.config/dotfiles/machine.lua" || true
cp -n .config/dotfiles/git.conf.example "$HOME/.config/dotfiles/git.conf" || true
cp -n .config/dotfiles/scripts/gs_zipline_conf_example.sh "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh" || true
cp -n .config/waypaper/config.ini.example "$HOME/.config/waypaper/config.ini" || true

# Generated configs.
"$HOME/.config/waybar/generate-config.sh"
matugen image "$HOME/.config/dotfiles/wallpapers/er-1.jpeg" --source-color-index 0 || true

echo
echo "Done. Now edit for this machine:"
echo "  ~/.config/dotfiles/machine.lua   (monitors, gpu, plugins, autostart)"
echo "  ~/.config/dotfiles/git.conf      (git identity)"
