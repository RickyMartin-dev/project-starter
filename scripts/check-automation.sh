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

for command in 'start_session' 'finish_session' 'refresh_local_context' 'automatic_snapshot' 'automatic_handoff' 'archive_snapshot_optional' 'refresh_snapshot_checkpoint' 'recall_history' 'record_learning_review' 'month_has_records'; do
  if ! grep -qF "$command()" scripts/project; then
    printf 'automation check missing project function: %s\n' "$command" >&2
    failures=$((failures + 1))
  fi
done

if [[ ! -x scripts/snapshot-next-action.sh ]]; then
  printf 'automation check helper is missing or not executable: scripts/snapshot-next-action.sh\n' >&2
  failures=$((failures + 1))
fi

for command in 'start)' 'finish)' 'archive-snapshot)' 'recall)' '--task' '--summary' '--limit 1-10' 'PROJECT_SNAPSHOT_ARCHIVE_ROOT' 'second-brain-checkpoint.md' 'core.hooksPath'; do
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

# The release gate must still validate untracked whitespace from a linked worktree,
# where .git is a file instead of the main checkout's directory.
release_fixture="$fixture_dir/release-root"
release_worktree="$fixture_dir/release-linked-worktree"
mkdir -p "$release_fixture/scripts"
cp scripts/check-release.sh "$release_fixture/scripts/"
printf '#!/usr/bin/env bash\nexit 0\n' > "$release_fixture/scripts/check-starter.sh"
chmod +x "$release_fixture/scripts/check-release.sh" "$release_fixture/scripts/check-starter.sh"
git -C "$release_fixture" init -q
git -C "$release_fixture" config user.email fixture@example.invalid
git -C "$release_fixture" config user.name fixture
git -C "$release_fixture" add scripts
git -C "$release_fixture" commit -qm 'release fixture'
git -C "$release_fixture" worktree add --detach "$release_worktree" HEAD >/dev/null
printf 'trailing whitespace probe \n' > "$release_worktree/untracked-whitespace.txt"
if [[ ! -f "$release_worktree/.git" || -d "$release_worktree/.git" ]]; then
  printf 'automation fixture did not create a linked worktree.\n' >&2
  failures=$((failures + 1))
fi
if (cd "$release_worktree" && ./scripts/check-release.sh) > "$fixture_dir/release-worktree.log" 2>&1; then
  printf 'release check ignored untracked whitespace in a linked worktree.\n' >&2
  failures=$((failures + 1))
elif ! grep -qF 'whitespace errors detected in untracked file: untracked-whitespace.txt' "$fixture_dir/release-worktree.log"; then
  printf 'release check failed in a linked worktree for an unexpected reason.\n' >&2
  failures=$((failures + 1))
fi
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

project_fixture="$fixture_dir/project"
mkdir -p \
  "$project_fixture/scripts" \
  "$project_fixture/docs/templates" \
  "$project_fixture/docs/plans/active" \
  "$project_fixture/docs/compactions" \
  "$project_fixture/docs/state/proposals" \
  "$project_fixture/docs/research" \
  "$project_fixture/agents/specialists" \
  "$project_fixture/.githooks"
cp -p scripts/project scripts/snapshot-next-action.sh "$project_fixture/scripts/"
cp docs/templates/plan.md "$project_fixture/docs/templates/plan.md"
cat > "$project_fixture/scripts/check-starter.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
cat > "$project_fixture/scripts/check-release.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$project_fixture/scripts/check-starter.sh" "$project_fixture/scripts/check-release.sh"
cat > "$project_fixture/docs/project-brief.md" <<'EOF'
# Project Brief

replace-me
EOF
cat > "$project_fixture/docs/project-commands.md" <<'EOF'
# Project Commands

replace-me
EOF
for directory in docs/compactions docs/state/proposals docs/research; do
  mkdir -p "$project_fixture/$directory"
  printf '# Directory guide\n' > "$project_fixture/$directory/README.md"
done
printf '# Research backlog\n' > "$project_fixture/docs/research/backlog.md"
git -C "$project_fixture" init -q
test_git_config="$fixture_dir/gitconfig"
: > "$test_git_config"

suggestion_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" suggest-upgrades --json
)"
for expected in \
  'create the first compaction snapshot' \
  'record one project-local learning proposal' \
  'run a fresh project research comparison'; do
  if ! grep -qF "$expected" <<<"$suggestion_output"; then
    printf 'upgrade suggestions missed an empty record directory: %s\n' "$expected" >&2
    failures=$((failures + 1))
  fi
done

template_doctor_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" doctor --json
)"
if ! grep -qF '"placeholderWarnings":true' <<<"$template_doctor_output" || \
   ! grep -qF 'Replace project placeholders' <<<"$template_doctor_output"; then
  printf 'doctor did not explain the placeholder state accurately.\n' >&2
  failures=$((failures + 1))
fi
cat > "$project_fixture/docs/project-brief.md" <<'EOF'
# Project Brief

Fixture project identity.
EOF
cat > "$project_fixture/docs/project-commands.md" <<'EOF'
# Project Commands

Fixture project commands.
EOF
ready_doctor_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" doctor --json
)"
if ! grep -qF '"placeholderWarnings":false' <<<"$ready_doctor_output" || \
   ! grep -qF 'Project documentation is populated' <<<"$ready_doctor_output"; then
  printf 'doctor remediation remained stale after placeholders were removed.\n' >&2
  failures=$((failures + 1))
fi

aws_session_key="ASIA"'1234567890ABCDEF'
github_pat='github_pat_'"01234567890123456789"
slack_token='xoxb-'"12345678901234567890"
api_key='sk-'"proj-abcdefghijklmnopqrstuvwxyz1234"
private_key_kind='PRIVATE KEY'
encrypted_key_kind='ENCRYPTED PRIVATE KEY'
private_key_body='PRIVATE_KEY_BODY_SHOULD_NOT_SURVIVE'
encrypted_key_body='ENCRYPTED_KEY_BODY_SHOULD_NOT_SURVIVE'
task_payload="AWS $aws_session_key GitHub $github_pat Slack $slack_token API $api_key
-----BEGIN $private_key_kind-----
$private_key_body
-----END $private_key_kind-----
-----BEGIN $encrypted_key_kind-----
$encrypted_key_body
-----END $encrypted_key_kind-----"
start_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" start --task "$task_payload" --json
)"
if ! grep -qF '"hooks":"installed"' <<<"$start_output"; then
  printf 'CLI start did not install the project hooks in a clean fixture.\n' >&2
  failures=$((failures + 1))
fi
if [[ "$(git -C "$project_fixture" config --local --get core.hooksPath)" != '.githooks' ]]; then
  printf 'CLI start did not set the default project hooks path.\n' >&2
  failures=$((failures + 1))
fi
for output_file in "$project_fixture/.agent-state/second-brain-checkpoint.md"; do
  for secret in "$aws_session_key" "$github_pat" "$slack_token" "$api_key" "$private_key_body" "$encrypted_key_body"; do
    if grep -qF "$secret" "$output_file"; then
      printf 'CLI start snapshot redaction failed for a supported credential pattern.\n' >&2
      failures=$((failures + 1))
      break 2
    fi
  done
done
for secret in "$aws_session_key" "$github_pat" "$slack_token" "$api_key" "$private_key_body" "$encrypted_key_body"; do
  if grep -qF "$secret" <<<"$start_output"; then
    printf 'CLI start JSON redaction failed for a supported credential pattern.\n' >&2
    failures=$((failures + 1))
    break
  fi
done
cat > "$project_fixture/docs/compactions/2026-01-recallprobe.md" <<'EOF'
# Recall probe record

This sanitized project note is the recallprobe result used to orient a later task.
EOF
mkdir -p "$project_fixture/.agent-state" "$project_fixture/resources/hermes-agent"
printf '# Local state decoy\nrecallprobe should never appear from local state.\n' > "$project_fixture/.agent-state/decoy.md"
printf '# Ignored resource decoy\nrecallprobe should never appear from resources.\n' > "$project_fixture/resources/hermes-agent/decoy.md"
printf '/resources/\n' > "$project_fixture/.gitignore"
recall_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" recall recallprobe --limit 1 --json
)"
if ! grep -qF '"count":1' <<<"$recall_output" || \
   ! grep -qF 'docs/compactions/2026-01-recallprobe.md' <<<"$recall_output" || \
   grep -qE 'resources/|\.agent-state/' <<<"$recall_output"; then
  printf 'CLI recall did not return one canonical record or leaked an excluded path.\n' >&2
  failures=$((failures + 1))
fi
mkdir -p "$project_fixture/.agents/skills/frontmatter-recall"
cat > "$project_fixture/.agents/skills/frontmatter-recall/SKILL.md" <<'EOF'
---
name: frontmatter-recall
description: A fixture skill used to validate YAML frontmatter parsing.
---
# Frontmatter recall probe

This frontmatterprobe line should return with a stable title and line reference.
EOF
frontmatter_recall_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" recall $'frontmatterprobe\033' --limit 1 --json
)"
if [[ "$frontmatter_recall_output" == *$'\033'* ]]; then
  printf 'CLI recall emitted a terminal control character into JSON output.\n' >&2
  failures=$((failures + 1))
fi
if command -v python3 >/dev/null 2>&1; then
  frontmatter_recall_valid=true
  python3 -c 'import json,sys; d=json.load(sys.stdin); m=d["matches"][0]; assert d["count"]==1 and m["title"]=="Frontmatter recall probe" and m["line"]=="7" and "frontmatterprobe" in m["excerpt"] and m["source"].endswith(".agents/skills/frontmatter-recall/SKILL.md")' <<<"$frontmatter_recall_output" || frontmatter_recall_valid=false
else
  frontmatter_recall_valid=true
  for expected in '"title":"Frontmatter recall probe"' '"line":"7"' '"excerpt":"This frontmatterprobe'; do
    grep -qF "$expected" <<<"$frontmatter_recall_output" || frontmatter_recall_valid=false
  done
fi
if [[ "$frontmatter_recall_valid" != true ]]; then
  printf 'CLI recall did not parse YAML frontmatter or preserve its line and excerpt fields.\n' >&2
  failures=$((failures + 1))
fi
title_prefix="$(printf '%110s' '' | tr ' ' 'x')"
title_key_prefix='AKIA'
title_key_suffix='1234567890ABCDEF'
mkdir -p "$project_fixture/.agents/skills/partialcredential-recall"
printf '%s%s%s\n\nThis partialcredentialprobe output verifies complete-title sanitization.\n' '# ' "$title_prefix" "$title_key_prefix$title_key_suffix" > "$project_fixture/.agents/skills/partialcredential-recall/SKILL.md"
partial_credential_output="$(GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" "$project_fixture/scripts/project" recall partialcredentialprobe --limit 1 --json)"
if grep -qF 'AKIA' <<<"$partial_credential_output"; then
  printf 'CLI recall truncated a credential before sanitizing its title.\n' >&2
  failures=$((failures + 1))
fi
# Large result sets previously let `head` close the sort pipe early under
# pipefail. This exercises the public recall interface with output well beyond
# a typical pipe buffer while still requesting only one record.
mkdir -p "$project_fixture/docs/compactions/recall-load"
for index in $(seq 1 400); do
  printf '# Recall pressure %s\nThis recallpressure record has enough safe text to exercise bounded history sorting.\n' "$index" > "$project_fixture/docs/compactions/recall-load/$index.md"
done
recall_pressure_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" recall recallpressure --limit 1 --json
)"
recall_pressure_valid=true
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["count"]==1 and len(d["matches"])==1' <<<"$recall_pressure_output" || recall_pressure_valid=false
elif ! grep -qF '"count":1' <<<"$recall_pressure_output"; then
  recall_pressure_valid=false
fi
if [[ "$recall_pressure_valid" != true ]]; then
  printf 'CLI recall failed while limiting a large history result set.\n' >&2
  failures=$((failures + 1))
fi
recall_start_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" start --task 'recallprobe' --json
)"
if ! grep -qF '"status":"ready"' <<<"$recall_start_output" || \
   ! grep -qF 'docs/compactions/2026-01-recallprobe.md' "$project_fixture/.agent-state/session-context.md" || \
   grep -qF 'Local state decoy' "$project_fixture/.agent-state/session-context.md" || \
   grep -qF 'Ignored resource decoy' "$project_fixture/.agent-state/session-context.md"; then
  printf 'CLI start did not include bounded recall or included an excluded source.\n' >&2
  failures=$((failures + 1))
fi

if ! "$project_fixture/scripts/project" plan cli-smoke 'A Fixture Plan' >/dev/null || \
   ! grep -q 'A Fixture Plan' "$project_fixture/docs/plans/active/cli-smoke.md"; then
  printf 'CLI plan did not render its title into the plan template.\n' >&2
  failures=$((failures + 1))
fi
if "$project_fixture/scripts/project" plan cli-smoke 'Duplicate Plan' >/dev/null 2>&1; then
  printf 'CLI plan accepted a duplicate slug.\n' >&2
  failures=$((failures + 1))
fi

git -C "$project_fixture" config --local core.hooksPath custom-hooks
custom_hooks_output="$(
  GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" start --task 'custom hook path' --json
)"
if ! grep -qF '"hooks":"custom-hooks-configured"' <<<"$custom_hooks_output" || \
   [[ "$(git -C "$project_fixture" config --local --get core.hooksPath)" != 'custom-hooks' ]]; then
  printf 'CLI start failed to preserve a custom Git hooks path.\n' >&2
  failures=$((failures + 1))
fi

git -C "$project_fixture" config --local --unset core.hooksPath
real_git="$(command -v git)"
fake_bin="$fixture_dir/fake-bin"
mkdir -p "$fake_bin"
cat > "$fake_bin/git" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == '-C' && "\${3:-}" == 'config' && "\${4:-}" == 'core.hooksPath' && "\${5:-}" == '.githooks' ]]; then
  exit 1
fi
exec "$real_git" "\$@"
EOF
chmod +x "$fake_bin/git"
failed_install_output="$(
  PATH="$fake_bin:$PATH" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" start --task 'hook setup failure' --json
)"
if ! grep -qF '"hooks":"available-but-not-installed"' <<<"$failed_install_output"; then
  printf 'CLI start did not report a failed hook installation clearly.\n' >&2
  failures=$((failures + 1))
fi

finish_output="$(
  PROJECT_SNAPSHOT_ARCHIVE_ROOT='' GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" finish --summary 'fixture finished' --json
)"
if ! grep -qF '"status":"pass"' <<<"$finish_output" || \
   [[ ! -f "$project_fixture/docs/state/automatic-handoff.md" ]] || \
   ! find "$project_fixture/docs/compactions" -maxdepth 1 -type f -name '*automatic-session.md' -print -quit | grep -q .; then
  printf 'CLI finish did not create a passing snapshot and handoff.\n' >&2
  failures=$((failures + 1))
fi
passing_snapshot="$(find "$project_fixture/docs/compactions" -maxdepth 1 -type f -name '*automatic-session.md' -print -quit)"
if [[ -z "$passing_snapshot" ]] || \
   ! grep -qF 'scripts/check-starter.sh` — pass' "$passing_snapshot" || \
   ! grep -qF 'scripts/check-release.sh` — pass' "$passing_snapshot"; then
  printf 'CLI finish snapshot does not record passed checks accurately.\n' >&2
  failures=$((failures + 1))
fi
if grep -nE '[[:blank:]]+$' "$project_fixture/docs/state/automatic-handoff.md" >/dev/null; then
  printf 'CLI finish wrote trailing whitespace into the automatic handoff.\n' >&2
  failures=$((failures + 1))
fi
printf '#!/usr/bin/env bash\nexit 1\n' > "$project_fixture/scripts/check-release.sh"
failed_finish_output=''
if failed_finish_output="$(
  PROJECT_SNAPSHOT_ARCHIVE_ROOT='' GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" \
    "$project_fixture/scripts/project" finish --summary 'failed release fixture' --json
)"; then
  printf 'CLI finish reported success when the release check failed.\n' >&2
  failures=$((failures + 1))
fi
failed_snapshot_relative="$(printf '%s' "$failed_finish_output" | sed -n 's/.*"snapshot":"\([^"]*\)".*/\1/p')"
if ! grep -qF '"status":"fail"' <<<"$failed_finish_output" || \
   [[ -z "$failed_snapshot_relative" || ! -f "$project_fixture/$failed_snapshot_relative" ]] || \
   ! grep -qF 'scripts/check-starter.sh` — pass' "$project_fixture/$failed_snapshot_relative" || \
   ! grep -qF 'scripts/check-release.sh` — fail' "$project_fixture/$failed_snapshot_relative"; then
  printf 'CLI finish did not record a failed release check accurately in its snapshot.\n' >&2
  failures=$((failures + 1))
fi

# Friction log, finish --friction, learn, and the lessons gate.
friction_fixture="$fixture_dir/friction-project"
mkdir -p "$friction_fixture/docs/state/proposals" "$friction_fixture/docs/compactions" "$friction_fixture/prompts"
mkdir -p "$friction_fixture/scripts"
cp -p scripts/project scripts/snapshot-next-action.sh scripts/check-learning.sh scripts/archive_snapshot.py "$friction_fixture/scripts/"
for stub in check-starter.sh check-release.sh; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$friction_fixture/scripts/$stub"
  chmod +x "$friction_fixture/scripts/$stub"
done
cp docs/state/proposals/README.md "$friction_fixture/docs/state/proposals/README.md"
cp prompts/promote.md "$friction_fixture/prompts/promote.md"
printf '# Task A\nIndependent occurrence.\n' > "$friction_fixture/docs/compactions/2026-01-01-a.md"
printf '# Task B\nIndependent occurrence.\n' > "$friction_fixture/docs/compactions/2026-01-02-b.md"
printf '# Lessons\n\n## Log\n\n- `YYYY-MM-DD — replace this example with the first durable lesson — x`\n' > "$friction_fixture/docs/lessons.md"
friction_project() {
  (cd "$friction_fixture" && GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$test_git_config" ./scripts/project "$@")
}
friction_pattern='^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| [a-z0-9][a-z0-9-]* \| [^|]+ \| [^|]+ \| [^|]+ \| (open|fixed|lesson)$'
friction_project friction 'Alpha Area' 'sym | with pipe' 'cause' 'fix' >/dev/null
last_friction="$(tail -n 1 "$friction_fixture/docs/state/friction.md")"
if [[ ! "$last_friction" =~ $friction_pattern ]] || [[ "$last_friction" == *'sym |'* ]] || [[ "$last_friction" != *'| alpha-area |'* ]]; then
  printf 'CLI friction did not append a valid, pipe-stripped line.\n' >&2
  failures=$((failures + 1))
fi
if friction_project friction 'a' 's' 'c' 'f' --status bogus >/dev/null 2>&1; then
  printf 'CLI friction accepted an invalid status.\n' >&2
  failures=$((failures + 1))
fi
friction_count_before_bad_check="$(wc -l < "$friction_fixture/docs/state/friction.md" | tr -d ' ')"
if friction_project friction 'bad-check' 's' 'c' 'f' --status lesson --check 'none:' >/dev/null 2>&1; then
  printf 'CLI friction accepted an empty written reason for a lesson check.\n' >&2
  failures=$((failures + 1))
fi
if [[ "$(wc -l < "$friction_fixture/docs/state/friction.md" | tr -d ' ')" != "$friction_count_before_bad_check" ]]; then
  printf 'CLI friction partially wrote an invalid lesson entry.\n' >&2
  failures=$((failures + 1))
fi
finish_friction_output="$(PROJECT_SNAPSHOT_ARCHIVE_ROOT='' friction_project finish --summary 'friction fixture' --friction 'beta-area|symptom|cause|fix' --friction 'alpha-area|second symptom|cause|fix' --json)"
finish_json_valid=true
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["status"]=="pass" and d["snapshotArchive"]=="disabled" and d["retrospective"] is None' <<<"$finish_friction_output" || finish_json_valid=false
elif ! grep -qF '"status":"pass"' <<<"$finish_friction_output" || ! grep -qF '"retrospective":null' <<<"$finish_friction_output"; then
  finish_json_valid=false
fi
if [[ "$finish_json_valid" != true ]]; then
  printf 'CLI finish --json did not emit a valid JSON object with a null retrospective.\n' >&2
  failures=$((failures + 1))
fi
if ! grep -qF '| beta-area | symptom | cause | fix | open' "$friction_fixture/docs/state/friction.md"; then
  printf 'CLI finish --friction did not append an entry.\n' >&2
  failures=$((failures + 1))
fi
if ! grep -qF '"proposalsDrafted":1' <<<"$finish_friction_output" || \
   ! grep -qF '## Learning review' "$friction_fixture/.agent-state/second-brain-checkpoint.md" || \
   ! grep -qF 'proposal review drafted 1 proposal' "$friction_fixture/.agent-state/second-brain-checkpoint.md" || \
   ! grep -qF '## Learning review' "$(find "$friction_fixture/docs/compactions" -type f -name '*automatic-session.md' -print -quit)"; then
  printf 'CLI finish did not automatically group repeated friction into a learning record.\n' >&2
  failures=$((failures + 1))
fi
friction_project friction 'alpha-area' 'third symptom' 'cause' 'fix' >/dev/null
learn_output="$(friction_project learn --json)"
if ! ls "$friction_fixture"/docs/state/proposals/*-alpha-area.md >/dev/null 2>&1 || \
   ls "$friction_fixture"/docs/state/proposals/*-beta-area.md >/dev/null 2>&1 || \
   ! grep -qF '"area":"beta-area","count":1,"state":"watching"' <<<"$learn_output"; then
  printf 'CLI learn did not draft exactly the proposals for repeated areas.\n' >&2
  failures=$((failures + 1))
fi
alpha_proposal="$(ls "$friction_fixture"/docs/state/proposals/*-alpha-area.md 2>/dev/null | head -n 1)"
if [[ -z "$alpha_proposal" ]] || ! grep -qF 'Status: proposed' "$alpha_proposal" || ! grep -qF '## Proposed check' "$alpha_proposal"; then
  printf 'CLI learn proposal is missing required content.\n' >&2
  failures=$((failures + 1))
fi
if ! (cd "$friction_fixture" && ./scripts/check-learning.sh >/dev/null 2>&1); then
  printf 'learning gate failed with no snapshots in the fixture.\n' >&2
  failures=$((failures + 1))
fi
for index in 1 2 3 4 5 6; do
  printf '# Snapshot %s\n' "$index" > "$friction_fixture/docs/compactions/2026-01-0$index-snapshot.md"
done
if (cd "$friction_fixture" && ./scripts/check-learning.sh >/dev/null 2>&1); then
  printf 'learning gate passed with more than 5 snapshots and no lessons.\n' >&2
  failures=$((failures + 1))
fi
printf -- '- `2026-11-08 — a real lesson — evidence — check: none: fixture`\n' >> "$friction_fixture/docs/lessons.md"
if ! (cd "$friction_fixture" && ./scripts/check-learning.sh >/dev/null 2>&1); then
  printf 'learning gate failed even though a dated lesson exists.\n' >&2
  failures=$((failures + 1))
fi
standing_finish_output="$(PROJECT_SNAPSHOT_ARCHIVE_ROOT='' friction_project finish --summary 'standing correction fixture' --friction 'standing-correction|preserve the user rule|explicit user correction|record the sanitized rule|lesson' --json)"
if ! grep -qF '"lessonsCurated":1' <<<"$standing_finish_output" || \
   ! grep -qF 'standing-correction' "$friction_fixture/docs/state/friction.md" || \
   ! grep -qF 'check: none: explicit standing user correction requires semantic judgment' "$friction_fixture/docs/lessons.md"; then
  printf 'CLI finish did not immediately record an explicit standing correction as a lesson.\n' >&2
  failures=$((failures + 1))
fi
general_finish_output="$(PROJECT_SNAPSHOT_ARCHIVE_ROOT='' friction_project finish --summary 'verified general lesson fixture' --friction 'verified-general|same workflow issue|independent task records docs/compactions/2026-01-01-a.md and docs/compactions/2026-01-02-b.md; scripts/check-learning.sh passed|document the verified workflow|lesson|scripts/check-learning.sh' --json)"
if ! grep -qF '"lessonsCurated":1' <<<"$general_finish_output" || \
   ! grep -qF 'check: scripts/check-learning.sh' "$friction_fixture/docs/lessons.md" || \
   ! grep -qF 'independent task records docs/compactions/2026-01-01-a.md and docs/compactions/2026-01-02-b.md' "$friction_fixture/docs/lessons.md"; then
  printf 'CLI finish did not record a verified general lesson with cited evidence and its enforcing check.\n' >&2
  failures=$((failures + 1))
fi
if ! (cd "$friction_fixture" && ./scripts/check-learning.sh >/dev/null 2>&1); then
  printf 'learning gate failed after recording a verified general lesson with an enforcing check.\n' >&2
  failures=$((failures + 1))
fi
cp "$friction_fixture/docs/lessons.md" "$fixture_dir/lessons-valid.md"
printf -- '- `2026-11-09 — empty none reason — evidence — check: none:`\n' >> "$friction_fixture/docs/lessons.md"
if learning_output="$(cd "$friction_fixture" && ./scripts/check-learning.sh 2>&1)"; then
  printf 'learning gate accepted a bare none: check with no explanation.\n' >&2
  failures=$((failures + 1))
elif ! grep -qF 'dated lesson must include an enforcing check or a written none reason' <<<"$learning_output"; then
  printf 'learning gate rejected a bare none: check for an unexpected reason.\n' >&2
  failures=$((failures + 1))
fi
cp "$fixture_dir/lessons-valid.md" "$friction_fixture/docs/lessons.md"

# Evidence-based suggest-upgrades and retro
evidence_fixture="$fixture_dir/evidence-project"
mkdir -p "$evidence_fixture/docs/state/proposals" "$evidence_fixture/docs/compactions" "$evidence_fixture/docs/research" "$evidence_fixture/docs/retrospectives" "$evidence_fixture/.lavish" "$evidence_fixture/scripts"
cp -p scripts/project scripts/snapshot-next-action.sh "$evidence_fixture/scripts/"
for stub in check-starter.sh check-release.sh; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$evidence_fixture/scripts/$stub"
  chmod +x "$evidence_fixture/scripts/$stub"
done
printf '# Friction log\n\n## Log\n\n- 2026-11-01 | flaky-hook | s1 | c | f | open\n- 2026-11-02 | flaky-hook | s2 | c | f | open\n- 2026-11-03 | solo-area | s3 | c | f | open\n' > "$evidence_fixture/docs/state/friction.md"
printf '# Lessons\n\n## Log\n\n- `2026-11-01 — has check — e — check: scripts/x.sh`\n- `2026-11-02 — no check — e`\n' > "$evidence_fixture/docs/lessons.md"
printf '# Old research\n' > "$evidence_fixture/docs/research/2020-01-01-old.md"
evidence_out="$(cd "$evidence_fixture" && ./scripts/project suggest-upgrades)"
if ! grep -qF 'address recurring flaky-hook friction (2 entries; docs/state/friction.md)' <<<"$evidence_out" || \
   ! grep -qF '1 open friction entries' <<<"$evidence_out" || \
   ! grep -qF 'add enforcing checks for 1 lessons' <<<"$evidence_out"; then
  printf 'suggest-upgrades did not report friction or lesson evidence.\n' >&2
  failures=$((failures + 1))
fi
if ! grep -qE 'refresh research \(newest note 2020-01-01, [0-9]+ days old\)' <<<"$evidence_out"; then
  printf 'suggest-upgrades did not report stale research.\n' >&2
  failures=$((failures + 1))
fi
if command -v python3 >/dev/null 2>&1; then
  if ! (cd "$evidence_fixture" && ./scripts/project suggest-upgrades --json) | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["signals"] and d["suggestions"] and d["count"]==len(d["suggestions"])'; then
    printf 'suggest-upgrades --json is not valid JSON with signals.\n' >&2
    failures=$((failures + 1))
  fi
fi
if ! (cd "$evidence_fixture" && ./scripts/project retro 2026-11 --html >/dev/null) || \
   ! grep -qF '## Metrics' "$evidence_fixture/docs/retrospectives/2026-11.md" || \
   ! grep -qF 'flaky-hook' "$evidence_fixture/docs/retrospectives/2026-11.md"; then
  printf 'retro did not write the markdown retrospective.\n' >&2
  failures=$((failures + 1))
fi
if (cd "$evidence_fixture" && ./scripts/project retro 2026-11 >/dev/null 2>&1); then
  printf 'retro overwrote an existing retrospective without --force.\n' >&2
  failures=$((failures + 1))
fi
if ! (cd "$evidence_fixture" && ./scripts/project retro 2026-11 --force >/dev/null 2>&1); then
  printf 'retro --force failed.\n' >&2
  failures=$((failures + 1))
fi
retro_html="$evidence_fixture/.lavish/retro-2026-11.html"
if [[ ! -f "$retro_html" ]] || ! grep -qF 'theme.css' "$retro_html" || ! grep -qF 'theme.js' "$retro_html" || \
   ! grep -qF '<a href="#numbers" data-lavish-action>' "$retro_html" || grep -qF '<style' "$retro_html"; then
  printf 'retro --html output does not follow the shared Lavish theme.\n' >&2
  failures=$((failures + 1))
fi

auto_retro_fixture="$fixture_dir/auto-retro-project"
cp -R "$evidence_fixture" "$auto_retro_fixture"
find "$auto_retro_fixture/docs/retrospectives" -type f -delete
retro_year="$(date +%Y)"
retro_month_number="$(date +%m)"
if (( 10#$retro_month_number == 1 )); then
  retro_year=$((10#$retro_year - 1))
  retro_month_number=12
else
  retro_month_number=$((10#$retro_month_number - 1))
fi
retro_previous_month="$(printf '%04d-%02d' "$retro_year" "$retro_month_number")"
printf '# Previous month activity\n' > "$auto_retro_fixture/docs/compactions/$retro_previous_month-task.md"
auto_retro_output="$(cd "$auto_retro_fixture" && PROJECT_SNAPSHOT_ARCHIVE_ROOT='' ./scripts/project finish --summary 'automatic retrospective fixture' --json)"
auto_retro_valid=true
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["retrospective"] == sys.argv[1]' "docs/retrospectives/$retro_previous_month.md" <<<"$auto_retro_output" || auto_retro_valid=false
elif ! grep -qF "\"retrospective\":\"docs/retrospectives/$retro_previous_month.md\"" <<<"$auto_retro_output"; then
  auto_retro_valid=false
fi
if [[ "$auto_retro_valid" != true ]] || [[ ! -f "$auto_retro_fixture/docs/retrospectives/$retro_previous_month.md" ]]; then
  printf 'CLI finish did not create the missing retrospective for a recorded previous month.\n' >&2
  failures=$((failures + 1))
fi
second_auto_retro_output="$(cd "$auto_retro_fixture" && PROJECT_SNAPSHOT_ARCHIVE_ROOT='' ./scripts/project finish --summary 'automatic retrospective idempotence fixture' --json)"
second_retro_valid=true
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; assert json.load(sys.stdin)["retrospective"] is None' <<<"$second_auto_retro_output" || second_retro_valid=false
elif ! grep -qF '"retrospective":null' <<<"$second_auto_retro_output"; then
  second_retro_valid=false
fi
if [[ "$second_retro_valid" != true ]]; then
  printf 'CLI finish did not leave an existing previous-month retrospective untouched.\n' >&2
  failures=$((failures + 1))
fi

auto_retro_failure_fixture="$fixture_dir/auto-retro-failure-project"
cp -R "$evidence_fixture" "$auto_retro_failure_fixture"
find "$auto_retro_failure_fixture/docs/retrospectives" -type f -delete
printf '# Previous month activity\n' > "$auto_retro_failure_fixture/docs/compactions/$retro_previous_month-task.md"
rmdir "$auto_retro_failure_fixture/docs/retrospectives"
printf 'not a directory\n' > "$auto_retro_failure_fixture/docs/retrospectives"
auto_retro_failure_stderr="$fixture_dir/auto-retro-failure-stderr.log"
auto_retro_failure_output="$(cd "$auto_retro_failure_fixture" && PROJECT_SNAPSHOT_ARCHIVE_ROOT='' ./scripts/project finish --summary 'failed retrospective fixture' --json 2>"$auto_retro_failure_stderr")"
auto_retro_failure_valid=true
if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["status"]=="pass" and d["retrospective"] is None' <<<"$auto_retro_failure_output" || auto_retro_failure_valid=false
elif ! grep -qF '"retrospective":null' <<<"$auto_retro_failure_output"; then
  auto_retro_failure_valid=false
fi
if [[ "$auto_retro_failure_valid" != true ]] || ! grep -qF 'could not create retrospective directory' "$auto_retro_failure_stderr"; then
  printf 'CLI finish reported an unwritten retrospective as present.\n' >&2
  failures=$((failures + 1))
fi

if command -v python3 >/dev/null 2>&1; then
  archive_root="$fixture_dir/snapshot-vault"
  archive_stderr="$fixture_dir/archive-stderr.log"
  archive_finish_output="$(PROJECT_SNAPSHOT_ARCHIVE_ROOT="$archive_root" PROJECT_SNAPSHOT_AGENT=codex friction_project finish --summary 'archive json fixture' --json 2>"$archive_stderr")"
  archive_finish_valid=true
  python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["status"]=="pass" and d["snapshotArchive"]=="saved" and d["retrospective"] is None' <<<"$archive_finish_output" || archive_finish_valid=false
  if [[ "$archive_finish_valid" != true ]] || ! grep -qF 'snapshot archived:' "$archive_stderr" || \
     ! find "$archive_root/raw/project-snapshots" -type f -name '*.md' -print -quit | grep -q .; then
    printf 'CLI finish --json did not keep stdout valid while archiving its snapshot.\n' >&2
    failures=$((failures + 1))
  fi
fi

if (( failures > 0 )); then
  printf 'automation check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'automation check passed.\n'
