#!/usr/bin/env bash

# Shared read-only validation for lesson evidence. The CLI runs the validated
# check script; check-learning.sh reuses the same evidence and path rules.
learning_check_script_path() {
  local root="$1" check="$2" script root_real scripts_real
  script="${check#./}"
  if [[ ! "$script" =~ ^scripts/[A-Za-z0-9_-]+\.sh$ ]] || \
     [[ "$script" == scripts/learning-evidence.sh ]] || \
     [[ ! -f "$root/$script" || ! -x "$root/$script" || -L "$root/$script" || -L "$root/scripts" ]]; then
    return 1
  fi
  root_real="$(cd "$root" && pwd -P)" || return 1
  scripts_real="$(cd "$root/scripts" && pwd -P)" || return 1
  [[ "$scripts_real" == "$root_real/scripts" ]] || return 1
  printf '%s' "$script"
}

learning_verification_cites_check() {
  local cause="$1" script="$2" normalized_cause marker suffix
  normalized_cause="$(printf '%s' "$cause" | sed -E 's/[Vv][Ee][Rr][Ii][Ff][Ii][Cc][Aa][Tt][Ii][Oo][Nn][[:space:]]+[Pp][Aa][Ss][Ss][Ee][Dd]:[[:space:]]*/verification passed: /g; s|verification passed: \./|verification passed: |g')"
  marker="verification passed: $script"
  if [[ "$normalized_cause" != *"$marker"* ]]; then
    return 1
  fi
  suffix="${normalized_cause#*"$marker"}"
  case "$suffix" in
    ''|[[:space:]]*|';'*|','*|')'*|':'*|'.'|.[[:space:]]*|'.;'*) return 0 ;;
    *) return 1 ;;
  esac
}

learning_validate_general_evidence() {
  local root="$1" cause="$2" check="$3" record scripts_real root_real script reason
  local -a task_records=()
  root_real="$(cd "$root" && pwd -P)" || return 1
  if [[ ! -d "$root/docs/compactions" || -L "$root/docs" || -L "$root/docs/compactions" ]]; then
    printf 'general lesson evidence must be stored under the repository docs/compactions directory.\n' >&2
    return 1
  fi
  scripts_real="$(cd "$root/docs/compactions" && pwd -P)" || return 1
  if [[ "$scripts_real" != "$root_real/docs/compactions" ]]; then
    printf 'general lesson evidence must resolve inside the repository docs/compactions directory.\n' >&2
    return 1
  fi
  while IFS= read -r record; do
    [[ -n "$record" && -f "$root/$record" && ! -L "$root/$record" ]] || continue
    [[ ! -f "$root/docs/compactions/README.md" || ! "$root/$record" -ef "$root/docs/compactions/README.md" ]] || continue
    local duplicate=false existing
    if (( ${#task_records[@]} > 0 )); then
      for existing in "${task_records[@]}"; do
        if [[ "$root/$record" -ef "$root/$existing" ]]; then
          duplicate=true
          break
        fi
      done
    fi
    [[ "$duplicate" == true ]] || task_records+=("$record")
  done < <(printf '%s\n' "$cause" | grep -Eo 'docs/compactions/[[:alnum:]][[:alnum:]._-]*\.md' || true)
  if (( ${#task_records[@]} < 2 )); then
    printf 'a general lesson needs two distinct existing docs/compactions task records in its cause.\n' >&2
    return 1
  fi
  if ! printf '%s\n' "$cause" | grep -Eiq 'verification[[:space:]]+passed:[[:space:]]*[^[:space:]].*'; then
    printf 'a general lesson cause must cite successful verification as "verification passed: <result>".\n' >&2
    return 1
  fi
  if [[ "$check" == none:* ]]; then
    reason="${check#none:}"
    reason="$(printf '%s' "$reason" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    if [[ -z "$reason" ]]; then
      printf 'a lesson with check: none must include a reason.\n' >&2
      return 1
    fi
  else
    script="$(learning_check_script_path "$root" "$check")" || {
      printf 'a general lesson check must name an executable regular script directly under scripts/.\n' >&2
      return 1
    }
    if ! learning_verification_cites_check "$cause" "$script"; then
      printf 'cite the successful enforcing check as "verification passed: %s" in the cause.\n' "$script" >&2
      return 1
    fi
  fi
}
