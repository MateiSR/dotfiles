#!/usr/bin/env bash
# Quality gates: lint -> typecheck -> build -> test. Failures-only output.
# Usage: gates.sh [project-dir]
#   GATES_DETECT=1 gates.sh   prints the detected plan without running anything.
set -u
cd "${1:-.}" || exit 1

fail=0
summary=()

run_step() {
  local name="$1"; shift
  if [ "${GATES_DETECT:-0}" = 1 ]; then
    summary+=("plan: $name -> $*")
    return 0
  fi
  local start out rc dur
  start=$(date +%s)
  out=$("$@" 2>&1); rc=$?
  dur=$(( $(date +%s) - start ))
  if [ "$rc" -eq 0 ]; then
    summary+=("✓ $name (${dur}s)")
  else
    summary+=("✗ $name (${dur}s, exit $rc)")
    echo "--- $name failed; last 40 lines ---"
    echo "$out" | tail -n 40
    fail=1
  fi
  return "$rc"
}

if [ -f package.json ]; then
  pm=npm
  [ -f pnpm-lock.yaml ] && pm=pnpm
  { [ -f bun.lock ] || [ -f bun.lockb ]; } && pm=bun
  has_script() { jq -e --arg s "$1" '.scripts[$s] // empty' package.json >/dev/null 2>&1; }

  has_script lint && run_step lint "$pm" run lint
  if has_script typecheck; then
    run_step typecheck "$pm" run typecheck
  elif [ -f tsconfig.json ]; then
    run_step typecheck "$pm" exec tsc --noEmit
  fi
  build_rc=0
  if has_script build; then
    run_step build "$pm" run build || build_rc=$?
  fi
  if [ "$build_rc" -ne 0 ]; then
    summary+=("- test skipped (build failed)")
  elif has_script test; then
    run_step test "$pm" run test
  elif compgen -G '*.test.*' >/dev/null || [ -d test ] || [ -d tests ]; then
    run_step test node --test
  fi
elif [ -f pyproject.toml ] || [ -f setup.py ]; then
  command -v ruff >/dev/null 2>&1 && run_step lint ruff check .
  if [ -d tests ] || compgen -G 'test_*.py' >/dev/null; then
    run_step test python -m pytest -q -x
  fi
else
  echo "gates: no package.json or pyproject.toml in $PWD — nothing to run"
  exit 0
fi

printf '%s\n' "${summary[@]}"
exit "$fail"
