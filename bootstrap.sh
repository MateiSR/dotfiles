#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
STOW_DIR=$(dirname -- "$ROOT")
STOW_PACKAGE=$(basename -- "$ROOT")
declare -A TRACKED=()
declare -A SEEN=()
simulation=""

command -v stow >/dev/null || { echo "install stow first: pacman -S stow" >&2; exit 1; }

while IFS= read -r -d '' path; do
	[[ -e $ROOT/$path || -L $ROOT/$path ]] || continue
	TRACKED["$path"]=1
done < <(git -C "$ROOT" ls-files -z)

link_is_owned() {
	local path=$1 target=$HOME/$1 link resolved
	[[ -L $target ]] || return 1
	link=$(readlink -- "$target")
	[[ $link == /* ]] || link=$(dirname -- "$target")/$link
	resolved=$(realpath -m -- "$link")
	[[ $resolved == "$ROOT/$path" ]]
}

if ! simulation=$(stow --simulate --no-folding -S -d "$STOW_DIR" -t "$HOME" "$STOW_PACKAGE" 2>&1); then
	printf '%s\n' "$simulation" >&2
	exit 1
fi

# Git history is the deletion ledger; unlike compat-mode restow, this never
# needs to search the target tree.
while IFS= read -r -d '' path; do
	[[ -n $path && $path != /* && $path != .. && $path != ../* && $path != */.. && $path != */../* ]] || continue
	[[ ${SEEN[$path]+yes} ]] && continue
	SEEN["$path"]=1
	[[ ${TRACKED[$path]+yes} || -e $ROOT/$path || -L $ROOT/$path ]] && continue
	if link_is_owned "$path"; then
		printf 'UNLINK: %s\n' "$path"
		rm -f -- "$HOME/$path"
	fi
done < <(git -C "$ROOT" log --all --reflog --format= --name-only -z)

stow --no-folding -S -v -d "$STOW_DIR" -t "$HOME" "$STOW_PACKAGE"

cp -n "$ROOT/.config/dotfiles/machine.lua.example" "$HOME/.config/dotfiles/machine.lua"
cp -n "$ROOT/.config/dotfiles/git.conf.example" "$HOME/.config/dotfiles/git.conf"
cp -n "$ROOT/.config/dotfiles/scripts/gs_zipline_conf_example.sh" "$HOME/.config/dotfiles/scripts/gs_zipline_conf.sh"
cp -n "$ROOT/.config/waypaper/config.ini.example" "$HOME/.config/waypaper/config.ini"

matugen image "$HOME/.config/dotfiles/wallpapers/er-1.jpeg" --source-color-index 0 || true

echo
echo "Done. Now edit for this machine:"
echo "  ~/.config/dotfiles/machine.lua   (monitors, gpu, plugins, autostart)"
echo "  ~/.config/dotfiles/git.conf      (git identity)"
