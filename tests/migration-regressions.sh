#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
TEST_ROOT=$(mktemp -d /tmp/dotfiles-migration-test.XXXXXX)
trap 'rm -rf -- "$TEST_ROOT"' EXIT

# A read-only Git object must not block archive restoration.
HOME=$TEST_ROOT/restore-home
XDG_STATE_HOME=$TEST_ROOT/state
POINT=$XDG_STATE_HOME/dotfiles-migration/test
PACK=$HOME/.config/hypr/plugins/test/.git/objects/pack/test.pack
mkdir -p "$(dirname -- "$PACK")" "$POINT"
printf 'archived\n' > "$PACK"
chmod 0444 "$PACK"
tar -C "$HOME" -czpf "$POINT/user-home.tar.gz" .config/hypr
(cd "$POINT" && sha256sum user-home.tar.gz > SHA256SUMS)
: > "$POINT/COMPLETE"
chmod 0644 "$PACK"
printf 'failed migration\n' > "$PACK"
chmod 0444 "$PACK"
env -u HYPRLAND_INSTANCE_SIGNATURE -u XDG_RUNTIME_DIR \
	HOME="$HOME" XDG_STATE_HOME="$XDG_STATE_HOME" \
	"$ROOT/migrate-v3.sh" restore test --yes >/dev/null
[[ $(< "$PACK") == archived ]]

# Config verification must not execute live-only workspace setup.
HOME=$TEST_ROOT/verify-home
mkdir -p "$HOME/.config/dotfiles" "$HOME/.config/hypr/plugins/split-monitor-workspaces/lua"
stow --no-folding -S -d "$(dirname -- "$ROOT")" -t "$HOME" "$(basename -- "$ROOT")"
cp "$ROOT/.config/dotfiles/machine.lua.example" "$HOME/.config/dotfiles/machine.lua"
printf '%s\n' 'return { setup = function() error("live plugin executed during verification") end }' \
	> "$HOME/.config/hypr/plugins/split-monitor-workspaces/lua/split-monitor-workspaces.lua"
if ! output=$(DOTFILES_VERIFY_CONFIG=1 Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua" 2>&1); then
	printf '%s\n' "$output" >&2
	exit 1
fi

printf 'migration regressions: ok\n'
