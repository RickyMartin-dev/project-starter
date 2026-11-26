#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/learning-evidence.sh"
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

if [[ -f docs/state/friction.md ]]; then
  friction_pattern='^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| [a-z0-9][a-z0-9-]* \| [^|]+ \| [^|]+ \| [^|]+ \| (open|fixed|correction|lesson)$'
  while IFS= read -r line; do
    if [[ ! "$line" =~ $friction_pattern ]]; then
      printf 'docs/state/friction.md has a malformed log line: %s\n' "$line" >&2
      failures=$((failures + 1))
    fi
  done < <(awk '/^## Log/ { in_log = 1; next } /^## / { in_log = 0 } in_log && /^- /' docs/state/friction.md)
fi

snapshot_count=0
for snapshot in docs/compactions/*.md; do
  [[ -f "$snapshot" ]] || continue
  [[ "$snapshot" == "docs/compactions/README.md" ]] && continue
  snapshot_count=$((snapshot_count + 1))
done
lesson_count=0
if [[ -f docs/lessons.md ]]; then
  lesson_records="$(grep -E '^- `?[0-9]{4}-[0-9]{2}-[0-9]{2} — ' docs/lessons.md || true)"
  lesson_count="$(printf '%s\n' "$lesson_records" | grep -c . || true)"
  lesson_check_re=' — check: (.*)$'
  lesson_source_re=' — source: (standing user correction|general lesson) \(docs/state/friction\.md\) — check:'
  lesson_evidence_re=' — evidence: (.*) — source: general lesson \(docs/state/friction\.md\) — check:'
  lesson_new_format_re=' — [a-z0-9][a-z0-9-]*: .* — apply: .* — evidence:'
  while IFS= read -r lesson; do
    [[ -n "$lesson" ]] || continue
    check=''
    check_value=''
    if [[ "$lesson" =~ $lesson_check_re ]]; then
      check="${BASH_REMATCH[1]}"
      check="${check%\`}"
      check="${check#"${check%%[![:space:]]*}"}"
      check="${check%"${check##*[![:space:]]}"}"
      check_value="$check"
      if [[ "$check" == none:* ]]; then
        check="${check#none:}"
        check="${check#"${check%%[![:space:]]*}"}"
        check="${check%"${check##*[![:space:]]}"}"
      fi
    fi
    if [[ -z "$check" ]]; then
      printf 'learning check: dated lesson must include an enforcing check or a written none reason: %s\n' "$lesson" >&2
      failures=$((failures + 1))
    fi
    if [[ "$lesson" =~ $lesson_new_format_re && "$lesson" != *' — source: '* ]]; then
      printf 'learning check: new-format lessons require a recognized source marker: %s\n' "$lesson" >&2
      failures=$((failures + 1))
    elif [[ "$lesson" == *' — source: '* ]]; then
      if [[ ! "$lesson" =~ $lesson_source_re ]]; then
        printf 'learning check: lesson source must be standing user correction or general lesson: %s\n' "$lesson" >&2
        failures=$((failures + 1))
      elif [[ "${BASH_REMATCH[1]}" == general\ lesson ]]; then
        if [[ "$lesson" =~ $lesson_evidence_re ]]; then
          if ! learning_validate_general_evidence "$ROOT_DIR" "${BASH_REMATCH[1]}" "$check_value"; then
            failures=$((failures + 1))
          fi
        else
          printf 'learning check: general lesson is missing its evidence field: %s\n' "$lesson" >&2
          failures=$((failures + 1))
        fi
      fi
    fi
  done <<< "$lesson_records"
fi
if (( snapshot_count > 5 && lesson_count == 0 )); then
  printf 'learning check: %s snapshots but no recorded lessons; run ./scripts/project learn and record lessons in docs/lessons.md.\n' "$snapshot_count" >&2
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  printf 'learning check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'learning check passed: %s proposal(s).\n' "$proposal_count"
