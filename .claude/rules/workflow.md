# Workflow

- Prefer the Grep/Glob tools over `grep`/`find` in Bash; keep Bash output small (quiet flags, tail failures).
- JS/TS projects: pnpm first (confirm via lockfile).
- Quality gates run batched at checkpoints (end of task, before commit) via `~/.claude/scripts/gates.sh` — never after each edit.
- At session start in a project, if `.claude/HANDOFF.md` exists there, read it before exploring the codebase.
- Route multi-file exploration, log digestion, and online research to sub-agents (Explore or general-purpose, model sonnet); do the reasoning on their summaries in the main thread.
- Commands expected to run long (dev servers, watch modes, big builds) go to background; never block on them.
- Simplicity first: minimum code that solves the problem — no speculative features, no abstractions for single-use code, no error handling for impossible scenarios.
- Surgical changes: every changed line traces to the request; don't "improve" adjacent code or comments; remove only orphans your own change created.
- Before non-trivial implementations, state assumptions and trade-offs explicitly; if a simpler approach exists, say so — then proceed (don't block waiting on answers).
