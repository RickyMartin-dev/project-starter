#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

if find . -type f ! -path './.git/*' ! -path './scripts/check-secrets.sh' \( \
  -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.key' -o \
  -iname '*credentials*' -o -iname '*secret*' \
\) -print -quit | grep -q .; then
  printf 'sensitive-looking file found; remove it or add a reviewed safe example: ' >&2
  find . -type f ! -path './.git/*' ! -path './scripts/check-secrets.sh' \( \
    -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.key' -o \
    -iname '*credentials*' -o -iname '*secret*' \
  \) -print >&2
  failures=$((failures + 1))
fi

credential_patterns=(
  'BEGIN (RSA|OPENSSH|EC|PGP) PRIVATE KEY|BEGIN (ENCRYPTED )?PRIVATE KEY'
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  'gh[pousr]_[A-Za-z0-9_]{20,}'
  'github_pat_[A-Za-z0-9_]{20,}'
  'xox[baprs]-[A-Za-z0-9-]{20,}'
  'sk-[A-Za-z0-9]{20,}'
  'sk-proj-[A-Za-z0-9_-]{20,}'
)

scan_files=()
if [[ -d .git ]]; then
  while IFS= read -r -d '' file; do
    [[ "$file" == "scripts/check-secrets.sh" ]] || scan_files+=("$file")
  done < <(git ls-files --cached --others --exclude-standard -z)
else
  while IFS= read -r -d '' file; do
    [[ "$file" == "./scripts/check-secrets.sh" ]] || scan_files+=("${file#./}")
  done < <(find . -type f ! -path './.git/*' -print0)
fi

for pattern in "${credential_patterns[@]}"; do
  for file in "${scan_files[@]}"; do
    if grep -aE "$pattern" "$file" >/dev/null 2>&1; then
      printf 'possible credential material matched in %s: %s\n' "$file" "$pattern" >&2
      failures=$((failures + 1))
      break
    fi
  done
done

if (( failures > 0 )); then
  printf 'secret check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'secret check passed.\n'
