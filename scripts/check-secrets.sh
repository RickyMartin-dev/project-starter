#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

failures=0

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

# Reviewed allowlist of gitignored paths (downloaded binaries or reference checkouts) that are skipped.
# A listed path is skipped only when git confirms it is ignored and untracked.
allowlist_file=".agentic/secret-scan-ignore"
allowlist_globs=()
if [[ -f "$allowlist_file" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -n "$line" ]] && allowlist_globs+=("$line")
  done < "$allowlist_file"
fi

# Directory-shaped allowlist entries are validated once and pruned as a unit.
# This keeps large ignored reference checkouts from spawning a Git process for
# every upstream file. Any tracked or unignored root fails closed before prune.
allowlisted_roots=()
pruned_roots=()
if (( ${#allowlist_globs[@]} > 0 )); then
  for glob in "${allowlist_globs[@]}"; do
    root="$glob"
    case "$glob" in
      */\*|*/\*\*) root="${glob%/*}" ;;
    esac
    [[ -d "$root" ]] || continue
    duplicate=false
    if (( ${#allowlisted_roots[@]} > 0 )); then
      for existing_root in "${allowlisted_roots[@]}"; do
        [[ "$existing_root" == "$root" ]] && duplicate=true
      done
    fi
    [[ "$duplicate" == true ]] || allowlisted_roots+=("$root")
  done
fi

if (( ${#allowlisted_roots[@]} > 0 )); then
  for root in "${allowlisted_roots[@]}"; do
    root_has_files=false
    if find "$root" \( -type d -name .git -prune \) -o \( \( -type f -o -type l \) -print -quit \) | grep -q .; then
      root_has_files=true
    elif git rev-parse --show-toplevel >/dev/null 2>&1 &&
         git ls-files --error-unmatch -- "$root" >/dev/null 2>&1; then
      root_has_files=true
    fi
    [[ "$root_has_files" == true ]] || continue
    if ! git rev-parse --show-toplevel >/dev/null 2>&1 ||
       ! git check-ignore --no-index -q -- "$root" ||
       git ls-files --error-unmatch -- "$root" >/dev/null 2>&1; then
      printf 'secret scan allowlist violation: %s matches %s but is tracked or not gitignored; allowlisted paths must be gitignored.\n' "$root" "$allowlist_file" >&2
      failures=$((failures + 1))
    fi
    pruned_roots+=("$root")
  done
fi

is_allowlisted() {
  local candidate="$1" glob
  if (( ${#allowlist_globs[@]} == 0 )); then
    return 1
  fi
  for glob in "${allowlist_globs[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$candidate" == $glob ]]; then
      return 0
    fi
  done
  return 1
}

is_under_pruned_root() {
  local candidate="$1" root
  if (( ${#pruned_roots[@]} > 0 )); then
    for root in "${pruned_roots[@]}"; do
      if [[ "$candidate" == "$root" || "$candidate" == "$root"/* ]]; then
        return 0
      fi
    done
  fi
  return 1
}

scan_files=()
name_matches=()
collect_candidate() {
  local file="$1" include_generated="${2:-false}"
  case "$file" in
    scripts/check-secrets.sh|.agentic/secret-scan-ignore|.git/*|*/.git/*) return 0 ;;
    node_modules/*|dist/*|build/*|coverage/*)
      [[ "$include_generated" == true ]] || return 0
      ;;
  esac
  is_under_pruned_root "$file" && return 0
  if is_allowlisted "$file"; then
    if git rev-parse --show-toplevel >/dev/null 2>&1 &&
       git check-ignore --no-index -q -- "$file" &&
       ! git ls-files --error-unmatch -- "$file" >/dev/null 2>&1; then
      return 0
    fi
    printf 'secret scan allowlist violation: %s matches %s but is tracked or not gitignored; allowlisted paths must be gitignored.\n' "$file" "$allowlist_file" >&2
    failures=$((failures + 1))
  fi
  local base="${file##*/}" sensitive_name=false
  shopt -s nocasematch
  [[ "$base" == *credentials* || "$base" == *secret* ]] && sensitive_name=true
  shopt -u nocasematch
  if [[ "$file" == .env || "$file" == .env.* || "$file" == */.env || "$file" == */.env.* || \
        "$file" == *.pem || "$file" == *.key || "$sensitive_name" == true ]]; then
    name_matches+=("$file")
  fi
  case "$file" in
    .codex/*|.agent-state/*) return 0 ;;
  esac
  scan_files+=("$file")
}

# Git enumeration does not descend into ignored nested repositories and may
# return only their directory entry. Walk the filesystem as well, pruning every
# Git metadata directory; this preserves filename coverage for ignored and
# nested checkout contents while allowing the reviewed path allowlist to apply.
find_prune_args=()
if (( ${#pruned_roots[@]} > 0 )); then
  for root in "${pruned_roots[@]}"; do
    find_prune_args+=( -path "./$root" -prune -o )
  done
fi
generated_roots=(node_modules dist build coverage)
for root in "${generated_roots[@]}"; do
  if [[ -d "$root" ]]; then
    find_prune_args+=( -path "./$root" -prune -o )
  fi
done
while IFS= read -r -d '' file; do
  relative_file="${file#./}"
  collect_candidate "$relative_file"
done < <(
  if (( ${#find_prune_args[@]} > 0 )); then
    find . "${find_prune_args[@]}" \( -type d -name .git -prune \) -o \( \( -type f -o -type l \) -print0 \)
  else
    find . \( -type d -name .git -prune \) -o \( \( -type f -o -type l \) -print0 \)
  fi
)

# Generated dependency/build trees are excluded from filesystem traversal, but
# any files deliberately tracked there remain in the filename and content scan.
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  while IFS= read -r -d '' file; do
    collect_candidate "$file" true
  done < <(git ls-files --cached -z -- node_modules dist build coverage)
fi

# A submodule or nested checkout registered as a Git link has no regular file
# at its path, so inspect those tracked entries explicitly. Allowlisting still
# rejects a tracked Git link even when its directory is ignored.
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  while IFS= read -r -d '' entry; do
    mode="${entry%% *}"
    candidate="${entry#*$'\t'}"
    if [[ "$mode" == 160000 ]]; then
      collect_candidate "$candidate"
    fi
  done < <(git ls-files --stage -z)
fi

if (( ${#name_matches[@]} > 0 )); then
  printf 'sensitive-looking file found; remove it or add a reviewed safe example: ' >&2
  printf '%s\n' "${name_matches[@]}" >&2
  failures=$((failures + 1))
fi

if (( ${#scan_files[@]} > 0 )); then
  for pattern in "${credential_patterns[@]}"; do
    for file in "${scan_files[@]}"; do
      if grep -aE "$pattern" "$file" >/dev/null 2>&1; then
        printf 'possible credential material matched in %s: %s\n' "$file" "$pattern" >&2
        failures=$((failures + 1))
        break
      fi
    done
  done
fi

if (( failures > 0 )); then
  printf 'secret check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'secret check passed.\n'
