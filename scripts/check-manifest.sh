#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$ROOT_DIR/.agentic/manifest.json"

if [[ ! -f "$manifest" ]]; then
  printf 'manifest check failed: missing %s\n' "$manifest" >&2
  exit 1
fi

failures=0
for key in schemaVersion templateVersion sourceOfTruth doctorCommand releaseCheckCommand learningProposalDirectory promotionPrompt compactionCommand compactionDirectory researchCommand researchDirectory upgradeCommand upgradeSuggestionCommand upgradeDirectory specialistCommand specialistDirectory specialistFactoryPrompt presentationArtifact workflowIds hardeningChecks adapterSurfaces durableState mutableProjectFiles upgradePolicy; do
  if ! grep -qE "^[[:space:]]+\"$key\"[[:space:]]*:" "$manifest"; then
    printf 'manifest missing key: %s\n' "$key" >&2
    failures=$((failures + 1))
  fi
done

if ! grep -qE '^[[:space:]]*\{[[:space:]]*$' "$manifest" || ! tail -n 1 "$manifest" | grep -qE '^[[:space:]]*\}[[:space:]]*$'; then
  printf 'manifest must be a simple object with opening and closing braces.\n' >&2
  failures=$((failures + 1))
fi

if ! grep -qE '"schemaVersion"[[:space:]]*:[[:space:]]*[0-9]+' "$manifest"; then
  printf 'manifest schemaVersion must be numeric.\n' >&2
  failures=$((failures + 1))
fi
if ! grep -qE '"sourceOfTruth"[[:space:]]*:[[:space:]]*"AGENTS\.md"' "$manifest"; then
  printf 'manifest sourceOfTruth must remain AGENTS.md.\n' >&2
  failures=$((failures + 1))
fi
if ! grep -qE '"adapterSurfaces"[[:space:]]*:[[:space:]]*\[' "$manifest" || ! grep -qE '"mutableProjectFiles"[[:space:]]*:[[:space:]]*\[' "$manifest" || ! grep -qE '"hardeningChecks"[[:space:]]*:[[:space:]]*\[' "$manifest"; then
  printf 'manifest adapterSurfaces, mutableProjectFiles, and hardeningChecks must be arrays.\n' >&2
  failures=$((failures + 1))
fi

if ! awk '
  function has_comma(value) { return value ~ /,[[:space:]]*$/ }
  function is_close_brace(value) { return value ~ /^[[:space:]]*}[[:space:]]*$/ }
  function is_close_bracket(value) { return value ~ /^[[:space:]]*\][[:space:]]*,?[[:space:]]*$/ }
  function is_array_open(value) { return value ~ /^[[:space:]]*"[A-Za-z][A-Za-z0-9]*"[[:space:]]*:[[:space:]]*\[[[:space:]]*$/ }
  function is_scalar(value) {
    return value ~ /^[[:space:]]*"[A-Za-z][A-Za-z0-9]*"[[:space:]]*:[[:space:]]*[0-9]+[[:space:]]*,?[[:space:]]*$/ ||
      value ~ /^[[:space:]]*"[A-Za-z][A-Za-z0-9]*"[[:space:]]*:[[:space:]]*"[^"]*"[[:space:]]*,?[[:space:]]*$/
  }
  function is_array_item(value) { return value ~ /^[[:space:]]*"[^"]+"[[:space:]]*,?[[:space:]]*$/ }
  { lines[NR] = $0 }
  END {
    valid = (NR >= 2 && lines[1] ~ /^[[:space:]]*\{[[:space:]]*$/ && is_close_brace(lines[NR]))
    in_array = 0
    for (i = 2; i < NR && valid; i++) {
      current = lines[i]
      following = lines[i + 1]
      if (in_array) {
        if (is_close_bracket(current)) {
          if (previous_item_had_comma) valid = 0
          if (is_close_brace(following)) {
            if (has_comma(current)) valid = 0
          } else if (!has_comma(current)) {
            valid = 0
          }
          in_array = 0
        } else if (is_array_item(current)) {
          previous_item_had_comma = has_comma(current)
          if (is_close_bracket(following)) {
            if (previous_item_had_comma) valid = 0
          } else if (!previous_item_had_comma) {
            valid = 0
          }
        } else {
          valid = 0
        }
        continue
      }
      if (is_array_open(current)) {
        in_array = 1
        previous_item_had_comma = 0
      } else if (is_scalar(current)) {
        if (is_close_brace(following)) {
          if (has_comma(current)) valid = 0
        } else if (!has_comma(current)) {
          valid = 0
        }
      } else {
        valid = 0
      }
    }
    if (in_array) valid = 0
    exit(valid ? 0 : 1)
  }
' "$manifest"; then
  printf 'manifest JSON shape is invalid for the starter contract.\n' >&2
  failures=$((failures + 1))
fi

expected_values=(
  '"docsRoot": "docs/"'
  '"doctorCommand": "./scripts/project doctor"'
  '"releaseCheckCommand": "./scripts/project release-check"'
  '"learningProposalDirectory": "docs/state/proposals/"'
  '"promotionPrompt": "prompts/promote.md"'
  '"compactionCommand": "./scripts/project compact <slug>"'
  '"compactionDirectory": "docs/compactions/"'
  '"researchCommand": "./scripts/project research <slug> <question>"'
  '"researchDirectory": "docs/research/"'
  '"upgradeCommand": "./scripts/project upgrade <slug> <title>"'
  '"upgradeSuggestionCommand": "./scripts/project suggest-upgrades"'
  '"upgradeDirectory": "docs/upgrades/"'
  '"specialistCommand": "./scripts/project specialist <slug> <title>"'
  '"specialistDirectory": "agents/specialists/"'
  '"specialistFactoryPrompt": "prompts/factory.md"'
  '"presentationArtifact": ".lavish/project-starter-operating-system.html"'
  '"workflowIds": ['
  '"durableState": "docs/state/"'
)
for value in "${expected_values[@]}"; do
  if ! grep -qF "$value" "$manifest"; then
    printf 'manifest contract value missing or changed: %s\n' "$value" >&2
    failures=$((failures + 1))
  fi
done

for path in AGENTS.md CLAUDE.md .claude/rules .claude/commands .cursor/rules .cursor/commands docs/state docs/state/proposals docs/compactions docs/research docs/upgrades agents agents/specialists .lavish prompts/promote.md prompts/factory.md; do
  if [[ ! -e "$ROOT_DIR/$path" ]]; then
    printf 'manifest-referenced path is missing: %s\n' "$path" >&2
    failures=$((failures + 1))
  fi
done

for check in check-secrets.sh check-workflows.sh check-instruction-surfaces.sh check-manifest.sh check-hardening-fixtures.sh check-learning.sh check-memory.sh check-research.sh check-upgrades.sh check-specialists.sh check-presentation.sh; do
  if ! grep -qF "scripts/$check" "$manifest"; then
    printf 'manifest hardeningChecks is missing scripts/%s.\n' "$check" >&2
    failures=$((failures + 1))
  fi
done

for workflow in plan verify review learn research promote compact upgrade specialist present; do
  if ! grep -qF "\"$workflow\"" "$manifest"; then
    printf 'manifest workflowIds is missing: %s.\n' "$workflow" >&2
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  printf 'manifest check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'manifest check passed.\n'
