#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

artifact=.lavish/project-starter-operating-system.html
failures=0
if [[ ! -f "$artifact" ]]; then
  printf 'presentation check missing: %s\n' "$artifact" >&2
  failures=$((failures + 1))
else
  for phrase in 'Project Starter Operating System' 'aria-labelledby' 'Compaction' 'Specialists' 'Research'; do
    if ! grep -qF "$phrase" "$artifact"; then
      printf 'presentation missing concept: %s\n' "$phrase" >&2
      failures=$((failures + 1))
    fi
  done
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
