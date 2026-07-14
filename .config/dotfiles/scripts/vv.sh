#!/usr/bin/env bash
set -euo pipefail

SESSION="dev"

case ${1:-} in
	-r) tmux kill-session -t "$SESSION" 2>/dev/null || true ;;
	-k) tmux kill-session -t "$SESSION" 2>/dev/null || true; exit ;;
	"") ;;
	*) printf 'usage: %s [-r|-k]\n' "$0" >&2; exit 2 ;;
esac

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
	tmux new-session -d -s "$SESSION" -n editor
	tmux send-keys -t "$SESSION:editor" nvim Enter
	tmux new-window -d -t "$SESSION" -n console
	tmux new-window -d -t "$SESSION" -n top
	tmux send-keys -t "$SESSION:top" btop Enter
fi

exec tmux attach-session -t "$SESSION"
