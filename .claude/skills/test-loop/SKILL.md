---
name: test-loop
description: Use when the user hands over a failing test, test file, or target behavior and wants autonomous iteration until tests pass
disable-model-invocation: true
---

# Test Loop

$ARGUMENTS: a test path/pattern, or a behavior description — if a behavior, write the failing test first (superpowers:test-driven-development).

1. Run only the targeted test (`node --test <path>`, `pnpm test -- <pattern>`, or `pytest <path>`). Confirm it fails; read why.
2. Loop, max 10 iterations, no commentary between them: edit implementation → rerun the targeted test. Fix root causes — never weaken, skip, or delete an assertion to go green. If the test itself looks wrong, stop and say so.
3. On green: run `~/.claude/scripts/gates.sh` once to confirm nothing else broke.
4. Report once: what changed and why, iteration count, gates summary.
5. Still red after 10: stop and summarize attempts + current hypothesis (consider superpowers:systematic-debugging).
