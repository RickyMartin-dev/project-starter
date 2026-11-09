#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0
fail() {
  printf '%s\n' "$1" >&2
  failures=$((failures + 1))
}

for path in PRODUCT.md DESIGN.md .lavish/theme.css .lavish/theme.js \
  .claude/skills/impeccable/SKILL.md .agents/skills/impeccable/SKILL.md .cursor/skills/impeccable/SKILL.md \
  .claude/agents/impeccable-finish-reviewer.md .cursor/agents/impeccable-finish-reviewer.md; do
  [[ -f "$path" ]] || fail "design check missing: $path"
done

for hook in .claude/settings.json .cursor/hooks.json .codex/hooks.json; do
  if ! grep -qF 'skills/impeccable/scripts/impeccable' "$hook" 2>/dev/null; then
    fail "design hook missing from $hook; run: npx impeccable install --providers=claude,codex,cursor --scope=project"
  fi
done

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for provider in .agents .claude .cursor; do
    if ! git check-ignore -q "$provider/skills/impeccable/scripts/bin/engine"; then
      fail "Impeccable engine binaries must stay ignored: $provider/skills/impeccable/scripts/bin/"
    fi
  done
fi

grep -qF 'impeccable' prompts/present.md || fail 'prompts/present.md must route visual work through the impeccable skill.'
grep -qF 'DESIGN.md' AGENTS.md || fail 'AGENTS.md must point design work at DESIGN.md.'

if (( failures > 0 )); then
  printf 'design check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'design check passed.\n'
