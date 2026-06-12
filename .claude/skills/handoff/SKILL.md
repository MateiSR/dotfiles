---
name: handoff
description: Use when ending a work session, switching tasks, or the user asks to save state for next time — persists session state so the next session skips re-discovery
disable-model-invocation: true
---

# Handoff

Write `<project-root>/.claude/HANDOFF.md`, overwriting any previous one. ≤40 lines, this shape:

    # Handoff — YYYY-MM-DD
    Goal: <the task, one line>
    State: <done / in-progress; what works; what's verified>
    Next: <ordered, concrete next steps>
    Files: <load-bearing file:line references>
    Gotchas: <decisions made, traps found, commands that matter>

Rules:
- Facts over narrative; absolute dates; `path:line` references.
- Include only what the next session cannot cheaply re-derive from code or git history.
- Ensure `.claude/HANDOFF.md` is listed in `.git/info/exclude` (never edit the project's `.gitignore` for this).

Counterpart: the global workflow rule says to read HANDOFF.md at session start when it exists.
