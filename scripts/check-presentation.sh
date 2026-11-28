#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

artifact=.lavish/project-starter-operating-system.html
walkthrough=.lavish/repo-walkthrough.html
readiness=resources/agent-readiness-report.html
failures=0
if [[ ! -f "$artifact" ]]; then
  printf 'presentation check missing: %s\n' "$artifact" >&2
  failures=$((failures + 1))
else
  for phrase in 'Project Starter Operating System' 'aria-labelledby' 'Compaction' 'Specialists' 'Research' 'Project records'; do
    if ! grep -qF "$phrase" "$artifact"; then
      printf 'presentation missing concept: %s\n' "$phrase" >&2
      failures=$((failures + 1))
    fi
  done
  if grep -qiE 'stale compactions|unreviewed proposals' "$artifact"; then
    printf 'presentation claims upgrade suggestions detect freshness or proposal review state.\n' >&2
    failures=$((failures + 1))
  fi
fi
if [[ ! -f "$walkthrough" ]]; then
  printf 'walkthrough report missing: %s\n' "$walkthrough" >&2
  failures=$((failures + 1))
else
  for phrase in 'End-to-End Walkthrough' 'The six findings and how they were closed' 'placeholderWarnings: false'; do
    if ! grep -qF "$phrase" "$walkthrough"; then
      printf 'walkthrough report missing concept: %s\n' "$phrase" >&2
      failures=$((failures + 1))
    fi
  done
fi
if [[ ! -f "$readiness" ]]; then
  printf 'presentation check missing: %s\n' "$readiness" >&2
  failures=$((failures + 1))
else
  for phrase in 'Project Starter · Readiness review' 'id="gaps"' 'update-project-logic' 'GITHUB_STEP_SUMMARY' 'No service or model training' 'agent-ecosystem-gaps.md'; do
    if ! grep -qF "$phrase" "$readiness"; then
      printf 'readiness report missing concept: %s\n' "$phrase" >&2
      failures=$((failures + 1))
    fi
  done
  if ! grep -qF 'href="../.lavish/theme.css"' "$readiness" || ! grep -qF 'src="../.lavish/theme.js"' "$readiness"; then
    printf 'readiness report must use the local Lavish theme assets.\n' >&2
    failures=$((failures + 1))
  fi
  if grep -qE '<script[^>]+https?://' "$readiness"; then
    printf 'readiness report must not load external scripts.\n' >&2
    failures=$((failures + 1))
  fi
fi
if ! grep -qF 'lavish-axi .lavish/project-starter-operating-system.html' docs/presentations/README.md; then
  printf 'presentation docs must include the Lavish launch command.\n' >&2
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  printf 'presentation check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'presentation check passed.\n'
