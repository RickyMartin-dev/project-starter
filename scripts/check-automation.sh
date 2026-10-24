#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

for file in docs/automation.md prompts/autopilot.md docs/state/automatic-handoff.md .githooks/pre-commit .githooks/pre-push .githooks/post-checkout .githooks/post-merge; do
  if [[ ! -f "$file" ]]; then
    printf 'automation check missing: %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
done

for command in 'start_session' 'finish_session' 'refresh_local_context' 'automatic_snapshot' 'automatic_handoff' 'archive_snapshot_optional' 'refresh_snapshot_checkpoint'; do
  if ! grep -qF "$command()" scripts/project; then
    printf 'automation check missing project function: %s\n' "$command" >&2
    failures=$((failures + 1))
  fi
done

if [[ ! -x scripts/snapshot-next-action.sh ]]; then
  printf 'automation check helper is missing or not executable: scripts/snapshot-next-action.sh\n' >&2
  failures=$((failures + 1))
fi

for command in 'start)' 'finish)' 'archive-snapshot)' '--task' '--summary' 'PROJECT_SNAPSHOT_ARCHIVE_ROOT' 'second-brain-checkpoint.md' 'core.hooksPath'; do
  if ! grep -qF -- "$command" scripts/project; then
    printf 'automation check missing project interface: %s\n' "$command" >&2
    failures=$((failures + 1))
  fi
done

for invariant in 'json_safe()' 'suggest_upgrades --json' "tr '\\r\\n\\t'"; do
  if ! grep -qF -- "$invariant" scripts/project; then
    printf 'automation check missing safety invariant: %s\n' "$invariant" >&2
    failures=$((failures + 1))
  fi
done

fixture_dir="$(mktemp -d)"
trap 'rm -rf "$fixture_dir"' EXIT
cat > "$fixture_dir/checkpoint.md" <<'EOF'
## Open work and next action

- Review the deployment notes.

## Other section

- Ignore this later item.
EOF
expected_action='Review the deployment notes.'
actual_action="$(scripts/snapshot-next-action.sh "$fixture_dir/checkpoint.md")"
if [[ "$actual_action" != "$expected_action" ]]; then
  printf 'automation check expected checkpoint next action %q, got %q.\n' "$expected_action" "$actual_action" >&2
  failures=$((failures + 1))
fi
fallback_action='Review active plans and project upgrade suggestions to choose the next task.'
cat > "$fixture_dir/checkpoint-placeholder.md" <<'EOF'
## Open work and next action

- <Update before compaction or handoff.>
EOF
actual_action="$(scripts/snapshot-next-action.sh "$fixture_dir/checkpoint-placeholder.md")"
if [[ "$actual_action" != "$fallback_action" ]]; then
  printf 'automation check expected the neutral next-action fallback, got %q.\n' "$actual_action" >&2
  failures=$((failures + 1))
fi

for hook in .githooks/pre-commit .githooks/pre-push .githooks/post-checkout .githooks/post-merge; do
  if [[ ! -x "$hook" ]]; then
    printf 'automation check hook is not executable: %s\n' "$hook" >&2
    failures=$((failures + 1))
  fi
done

if grep -RInE \
  -e 'git[[:space:]]+push[[:space:]]+--force' \
  -e 'curl[[:space:]].*\|[[:space:]]*(sh|bash)' \
  -e 'rm[[:space:]]+-rf[[:space:]]+/' \
  .githooks docs/automation.md prompts/autopilot.md >/dev/null 2>&1; then
  printf 'automation check found a prohibited destructive or remote execution pattern.\n' >&2
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  printf 'automation check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'automation check passed.\n'
