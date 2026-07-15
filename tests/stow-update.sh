#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d /tmp/dotfiles-stow-update.XXXXXX)
trap 'rm -rf -- "$TEST_ROOT"' EXIT
export HOME=$TEST_ROOT/home
export XDG_STATE_HOME=$TEST_ROOT/state

mkdir -p "$HOME/.config/hypr" "$TEST_ROOT/bin"
ln -s "$(command -v true)" "$TEST_ROOT/bin/matugen"
export PATH=$TEST_ROOT/bin:$PATH
ln -s "$ROOT/.config/hypr/animations.conf" "$HOME/.config/hypr/animations.conf"
printf 'keep\n' > "$HOME/.config/hypr/custom.conf"

"$ROOT/bootstrap.sh" >/dev/null 2>&1

[[ ! -L $HOME/.config/hypr/animations.conf ]]
[[ $(< "$HOME/.config/hypr/custom.conf") == keep ]]
[[ -L $HOME/.config/hypr/hyprland.lua ]]

printf 'stow update check: ok\n'
