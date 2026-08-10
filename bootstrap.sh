#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
STOW_DIR=$(dirname -- "$ROOT")
STOW_PACKAGE=$(basename -- "$ROOT")
simulation=""

command -v stow >/dev/null || { echo "install stow first: pacman -S stow" >&2; exit 1; }

if ! simulation=$(stow --simulate --no-folding -S -d "$STOW_DIR" -t "$HOME" "$STOW_PACKAGE" 2>&1); then
	printf '%s\n' "$simulation" >&2
	exit 1
fi

# Stow only knows the package's current contents, so a file deleted from the
# repo leaves its link behind — dangling, and still pointing into $ROOT.
prune_stale_links() {
	find "$@" -xtype l -exec sh -c \
		'case $(realpath -m -- "$1") in "$0"/*) printf "UNLINK: %s\n" "$1"; rm -f -- "$1";; esac' \
		"$ROOT" {} \;
}
prune_stale_links "$HOME" -maxdepth 1
shopt -s dotglob nullglob
for dir in "$HOME"/*/; do
	if [[ -d $ROOT/${dir#"$HOME/"} ]]; then
		prune_stale_links "$dir"
	fi
done
shopt -u dotglob nullglob

stow --no-folding -S -v -d "$STOW_DIR" -t "$HOME" "$STOW_PACKAGE"

cp -n "$ROOT/.config/dotfiles/machine.lua.example" "$HOME/.config/dotfiles/machine.lua"
cp -n "$ROOT/.config/dotfiles/git.conf.example" "$HOME/.config/dotfiles/git.conf"
cp -n "$ROOT/.config/dotfiles/scripts/gs_zipline_conf_example.sh" "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh"
cp -n "$ROOT/.config/waypaper/config.ini.example" "$HOME/.config/waypaper/config.ini"

# Re-theme from the wallpaper actually in use; the example only seeds run one.
wallpaper=$(sed -n 's/^wallpaper = //p' "$HOME/.config/waypaper/config.ini" 2>/dev/null || true)
if [[ -n $wallpaper ]]; then
	matugen image "${wallpaper/#\~/$HOME}" --source-color-index 0 || true
fi

echo
echo "Done. Now edit for this machine:"
echo "  ~/.config/dotfiles/machine.lua   (monitors, gpu, plugins, autostart)"
echo "  ~/.config/dotfiles/git.conf      (git identity)"
