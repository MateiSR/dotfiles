---
name: ship
description: Use when the user wants to commit completed work, optionally pushing or opening a PR — quality gates run first
disable-model-invocation: true
---

# Ship

Gate → stage → commit, one checkpoint command. $ARGUMENTS: optional message hint, plus `push` and/or `pr`.

1. Run `~/.claude/scripts/gates.sh` from the project root. Any failure: show the summary and STOP — never commit over red gates, never bypass with `--no-verify`. Offer to fix instead.
2. Review `git status` and `git diff --stat` to understand what changed.
3. `git add -A`, then commit with a Conventional Commit message (`feat:`/`fix:`/`docs:`/`refactor:`/`chore:`) derived from the diff and any hint in $ARGUMENTS. No AI attribution of any kind (no-self-attribution rule).
4. If $ARGUMENTS contains `push`: `git push` (set upstream if needed). If `pr`: push, then `gh pr create` with a short summary body — again no attribution.
5. Report one line: hash + message (+ PR URL).

If gates pass but the working tree mixes unrelated changes, say so and propose a split instead of one mixed commit.
