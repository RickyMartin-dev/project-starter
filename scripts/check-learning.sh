#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0
proposal_count=0
for proposal in docs/state/proposals/*.md; do
  [[ -f "$proposal" ]] || continue
  [[ "$proposal" == "docs/state/proposals/README.md" ]] && continue
  proposal_count=$((proposal_count + 1))
  for section in '## Problem or observation' '## Evidence commands' '## Scope' '## Expected benefit' '## Rollback' '## Security and trust review' '## Reviewer decision'; do
    if ! grep -qF "$section" "$proposal"; then
      printf '%s is missing required section: %s\n' "$proposal" "$section" >&2
      failures=$((failures + 1))
    fi
  done
  if grep -aE 'BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{20,}' "$proposal" >/dev/null 2>&1; then
    printf '%s contains possible credential material.\n' "$proposal" >&2
    failures=$((failures + 1))
  fi
  if ! grep -qE 'Status: (proposed|approved|rejected)' "$proposal"; then
    printf '%s must declare a supported status.\n' "$proposal" >&2
    failures=$((failures + 1))
  fi
done

if ! grep -q 'verification-log' docs/state/proposals/README.md || ! grep -q 'approved' prompts/promote.md; then
  printf 'learning promotion guidance is incomplete.\n' >&2
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  printf 'learning check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'learning check passed: %s proposal(s).\n' "$proposal_count"
