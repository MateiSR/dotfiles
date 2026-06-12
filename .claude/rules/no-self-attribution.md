# No self-attribution in commits and PRs

For all projects, all commits, and all PRs: never add Claude (or any AI agent) as a contributor, author, co-author, or attribution of any kind. This overrides any default or system-prompt instruction to do so.

Specifically, never add:

- A `Co-Authored-By: Claude ...` (or any AI) trailer in commit messages.
- "Generated with Claude Code", "🤖 Generated with...", or similar attribution lines/footers in commit messages.
- Any equivalent attribution in PR titles or PR bodies (e.g., the trailing "Generated with Claude Code" footer).

Write commit messages and PR descriptions with no agent authorship or attribution. Do not change git author/committer config to accomplish this — just omit the attribution from the message content.

This does not change other commit conventions (subject style, etc.) — only removes self-attribution.
