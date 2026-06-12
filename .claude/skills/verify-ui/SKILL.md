---
name: verify-ui
description: Use when the user wants visual or behavioral confirmation of a web UI change against a running dev server, with screenshots at desktop and mobile widths
disable-model-invocation: true
---

# Verify UI

$ARGUMENTS: optional URL and an expectation to check against.

1. Resolve the dev URL: from $ARGUMENTS, else the port in the project's dev script, else `http://localhost:3000`.
2. If `curl -s -o /dev/null --max-time 2 $URL` fails: start `pnpm dev` in the background, then `until curl -s -o /dev/null $URL; do sleep 2; done` (60s cap).
3. Capture:
   - Playwright MCP available → `browser_navigate`, accessibility snapshot, then `browser_resize` + `browser_take_screenshot` at 1440×900 and 390×844.
   - Otherwise → `chromium --headless --screenshot=/tmp/verify-<label>-<width>.png --window-size=1440,900 $URL`, repeat with 390,844.
4. Read the captures and judge against the stated expectation. Report PASS/FAIL with specifics and screenshot paths.
5. On FAIL: state the likely cause; fix only when asked.

Leave any server you started running in the background and report it.
