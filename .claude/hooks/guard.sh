#!/usr/bin/env bash
# PreToolUse guard for Bash: denies clearly destructive commands, passes everything else.
# Kept deliberately short to avoid false positives.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$1"
  exit 0
}

# rm with any flags targeting exactly /, /*, ~, or $HOME (not paths beneath them)
if printf '%s' "$cmd" | grep -qE '(^|\s|[;&|])rm\s+(-[a-zA-Z-]+\s+)*("?/"?|/\*|~|~/|"?\$HOME"?/?)(\s|$)'; then
  deny "rm targeting / or home blocked"
fi
printf '%s' "$cmd" | grep -q -- '--no-preserve-root' && deny "--no-preserve-root blocked"
if printf '%s' "$cmd" | grep -qE 'git\s+push[^;|&]*(\s--force(\s|$)|\s-f(\s|$))'; then
  deny "force push blocked (run --force-with-lease yourself if intended)"
fi
printf '%s' "$cmd" | grep -qE 'dd\s[^;|&]*of=/dev/(sd|nvme|vd|hd|mmcblk)' && deny "dd to block device blocked"
printf '%s' "$cmd" | grep -qE '>\s*/dev/(sd|nvme|vd|hd|mmcblk)' && deny "redirect to block device blocked"
printf '%s' "$cmd" | grep -qE '(^|\s)mkfs(\.|\s)' && deny "mkfs blocked"
printf '%s' "$cmd" | grep -qE 'chmod\s+(-[a-zA-Z]*R[a-zA-Z]*\s+)?777\s+/(\s|$)' && deny "chmod 777 on / blocked"

exit 0
