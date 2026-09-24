#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "README.md"
  "AGENTS.md"
  "CLAUDE.md"
  "docs/project-brief.md"
  "docs/project-commands.md"
  "docs/architecture.md"
  "docs/agent-workflow.md"
  "docs/quality.md"
  "docs/security.md"
  "docs/verification-log.md"
  "docs/experiments/README.md"
  "docs/experiments/log.md"
  "docs/experiments/runs/.gitkeep"
  "docs/experiments/runs/2026-09-title-rendering.md"
  "docs/research/agentic-starter-repos.md"
  "docs/research/2026-09-agentic-starter-scout.md"
  "docs/templates/experiment.md"
  "docs/templates/scout-report.md"
  "prompts/plan.md"
  "prompts/implement.md"
  "prompts/verify.md"
  "prompts/review.md"
  "prompts/learn.md"
  "prompts/research.md"
  ".cursor/rules/00-shared-context.mdc"
  ".claude/rules/00-shared-context.md"
  ".cursor/commands/plan.md"
  ".cursor/commands/verify.md"
  ".cursor/commands/review.md"
  ".cursor/commands/learn.md"
  ".cursor/commands/research.md"
  ".claude/commands/plan.md"
  ".claude/commands/verify.md"
  ".claude/commands/review.md"
  ".claude/commands/learn.md"
  ".claude/commands/research.md"
)

failures=0
for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'missing: %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
done

agents_lines="$(wc -l < AGENTS.md | tr -d ' ')"
if (( agents_lines > 120 )); then
  printf 'AGENTS.md is %s lines; keep the root map under 120 lines.\n' "$agents_lines" >&2
  failures=$((failures + 1))
fi

if ! grep -q '^@AGENTS\.md$' CLAUDE.md; then
  printf 'CLAUDE.md must import AGENTS.md as its shared source of truth.\n' >&2
  failures=$((failures + 1))
fi

if ! grep -q 'AGENTS.md' .cursor/rules/00-shared-context.mdc; then
  printf 'Cursor shared rule must point to AGENTS.md.\n' >&2
  failures=$((failures + 1))
fi

if grep -RIl --exclude-dir=.git -E 'BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{20,}' . >/dev/null 2>&1; then
  printf 'possible credential material detected; inspect the repository.\n' >&2
  failures=$((failures + 1))
fi

while IFS= read -r script; do
  if [[ -f "$script" ]] && ! bash -n "$script"; then
    printf 'shell syntax error: %s\n' "$script" >&2
    failures=$((failures + 1))
  fi
done < <(find scripts -type f -name '*.sh' -print)

if [[ -d .git ]]; then
  if ! git diff --check; then
    printf 'whitespace errors detected by git diff --check.\n' >&2
    failures=$((failures + 1))
  fi
fi

if (( failures > 0 )); then
  printf 'starter check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'starter check passed: %s required files, AGENTS.md=%s lines.\n' "${#required_files[@]}" "$agents_lines"
