#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/project-starter-hardening.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

failures=0
copy_fixture() {
  mkdir -p "$TEMP_DIR/.github/workflows" "$TEMP_DIR/.agentic/fixtures" "$TEMP_DIR/scripts" "$TEMP_DIR/.cursor/rules" "$TEMP_DIR/.cursor/commands" "$TEMP_DIR/.claude/rules" "$TEMP_DIR/.claude/commands" "$TEMP_DIR/.claude/skills/update-project-logic/references" "$TEMP_DIR/.claude/skills/update-project-logic/evals" "$TEMP_DIR/.agents/skills/update-project-logic/references" "$TEMP_DIR/.agents/skills/update-project-logic/evals" "$TEMP_DIR/prompts" "$TEMP_DIR/docs/state/proposals" "$TEMP_DIR/docs/compactions" "$TEMP_DIR/docs/research" "$TEMP_DIR/docs/upgrades" "$TEMP_DIR/agents/specialists" "$TEMP_DIR/.lavish" "$TEMP_DIR/.githooks"
  cp "$ROOT_DIR/scripts/check-secrets.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-workflows.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-instruction-surfaces.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-manifest.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-snapshot-archive.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-project-logic-skill.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/archive_snapshot.py" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/"
  cp "$ROOT_DIR/.agentic/secret-scan-ignore" "$TEMP_DIR/.agentic/"
  cp "$ROOT_DIR/.agentic/fixtures/untrusted-repo-note.md" "$TEMP_DIR/.agentic/fixtures/"
  cp "$ROOT_DIR/.agents/skills/update-project-logic/SKILL.md" "$TEMP_DIR/.agents/skills/update-project-logic/"
  cp "$ROOT_DIR/.agents/skills/update-project-logic/references/research-method.md" "$TEMP_DIR/.agents/skills/update-project-logic/references/"
  cp "$ROOT_DIR/.agents/skills/update-project-logic/evals/prompts.csv" "$TEMP_DIR/.agents/skills/update-project-logic/evals/"
  cp "$ROOT_DIR/.claude/skills/update-project-logic/SKILL.md" "$TEMP_DIR/.claude/skills/update-project-logic/"
  cp "$ROOT_DIR/.claude/skills/update-project-logic/references/research-method.md" "$TEMP_DIR/.claude/skills/update-project-logic/references/"
  cp "$ROOT_DIR/.claude/skills/update-project-logic/evals/prompts.csv" "$TEMP_DIR/.claude/skills/update-project-logic/evals/"
  cp "$ROOT_DIR/AGENTS.md" "$TEMP_DIR/"
  cp "$ROOT_DIR/CLAUDE.md" "$TEMP_DIR/"
  cp "$ROOT_DIR/.cursor/rules/00-shared-context.mdc" "$TEMP_DIR/.cursor/rules/"
  cp "$ROOT_DIR/.claude/rules/00-shared-context.md" "$TEMP_DIR/.claude/rules/"
  cp "$ROOT_DIR/.cursor/commands/"*.md "$TEMP_DIR/.cursor/commands/"
  cp "$ROOT_DIR/.claude/commands/"*.md "$TEMP_DIR/.claude/commands/"
  cp "$ROOT_DIR/prompts/"*.md "$TEMP_DIR/prompts/"
  cp "$ROOT_DIR/docs/security.md" "$TEMP_DIR/docs/"
  cp "$ROOT_DIR/docs/state/README.md" "$TEMP_DIR/docs/state/"
  cp "$ROOT_DIR/docs/state/proposals/README.md" "$TEMP_DIR/docs/state/proposals/"
  cp "$ROOT_DIR/docs/operating-system.md" "$TEMP_DIR/docs/"
  cp "$ROOT_DIR/docs/automation.md" "$TEMP_DIR/docs/"
  cp "$ROOT_DIR/docs/compactions/README.md" "$TEMP_DIR/docs/compactions/"
  cp "$ROOT_DIR/docs/state/automatic-handoff.md" "$TEMP_DIR/docs/state/"
  cp "$ROOT_DIR/docs/research/README.md" "$TEMP_DIR/docs/research/"
  cp "$ROOT_DIR/docs/upgrades/README.md" "$TEMP_DIR/docs/upgrades/"
  cp "$ROOT_DIR/agents/README.md" "$TEMP_DIR/agents/"
  cp "$ROOT_DIR/docs/presentations/README.md" "$TEMP_DIR/docs/"
  cp "$ROOT_DIR/.lavish/project-starter-operating-system.html" "$TEMP_DIR/.lavish/"
  cp "$ROOT_DIR/.githooks/"* "$TEMP_DIR/.githooks/"
  : > "$TEMP_DIR/agents/specialists/.gitkeep"
  git -C "$TEMP_DIR" init -q
  git -C "$TEMP_DIR" config advice.addEmbeddedRepo false
  git -C "$TEMP_DIR" config user.email fixture@example.invalid
  git -C "$TEMP_DIR" config user.name fixture
  git -C "$TEMP_DIR" add -A
}

expect_failure_with_message() {
  local label="$1"
  local expected="$2"
  shift 2
  local output
  if output=$("$@" 2>&1); then
    printf 'hardening fixture unexpectedly passed: %s\n' "$label" >&2
    failures=$((failures + 1))
  elif ! grep -qF "$expected" <<<"$output"; then
    printf 'hardening fixture failed for the wrong reason: %s\n' "$label" >&2
    printf '%s\n' "$output" >&2
    failures=$((failures + 1))
  fi
}

copy_fixture
if ! (
  cd "$TEMP_DIR" &&
  bash scripts/check-secrets.sh &&
  bash scripts/check-workflows.sh &&
  bash scripts/check-instruction-surfaces.sh &&
  bash scripts/check-manifest.sh &&
  bash scripts/check-project-logic-skill.sh
); then
  printf 'hardening fixture baseline unexpectedly failed.\n' >&2
  exit 1
fi

# An empty starter checkout must remain valid on Bash 3.x under nounset; array
# expansions in the scanner cannot assume any ordinary candidate files exist.
empty_scan_fixture="$TEMP_DIR/empty-scan"
mkdir -p "$empty_scan_fixture/scripts" "$empty_scan_fixture/.agentic"
cp "$ROOT_DIR/scripts/check-secrets.sh" "$empty_scan_fixture/scripts/"
cp "$ROOT_DIR/.agentic/secret-scan-ignore" "$empty_scan_fixture/.agentic/"
git -C "$empty_scan_fixture" init -q
if ! (cd "$empty_scan_fixture" && bash scripts/check-secrets.sh >/dev/null 2>&1); then
  printf 'hardening fixture failed: secret scan rejected an empty source tree.\n' >&2
  failures=$((failures + 1))
fi
rm -rf "$empty_scan_fixture"

printf 'AKIA%s\n' '1234567890ABCDEF' > "$TEMP_DIR/fake-leak.txt"
expect_failure_with_message "credential pattern" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -f "$TEMP_DIR/fake-leak.txt"

key_kind='PRIVATE KEY'
printf '%s\n' "-----BEGIN ${key_kind}-----" "fake" "-----END ${key_kind}-----" > "$TEMP_DIR/fake-private-key.txt"
expect_failure_with_message "generic private-key pattern" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -f "$TEMP_DIR/fake-private-key.txt"

printf 'ignored-secret.txt\n' > "$TEMP_DIR/.gitignore"
ignored_prefix='xoxb'
printf '%s\n' "${ignored_prefix}-12345678901234567890" > "$TEMP_DIR/ignored-secret.txt"
expect_failure_with_message "ignored credential pattern" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -f "$TEMP_DIR/ignored-secret.txt" "$TEMP_DIR/.gitignore"

# Secret scan allowlist: ignored files are skipped, tracked or unignored ones fail.
allow_dir=".agents/skills/impeccable/scripts/bin"
mkdir -p "$TEMP_DIR/$allow_dir"
printf 'AKIA%s\n' '1234567890ABCDEF' > "$TEMP_DIR/$allow_dir/engine"
printf '%s/\n' "$allow_dir" > "$TEMP_DIR/.gitignore"
if allowlisted_scan_output="$(cd "$TEMP_DIR" && bash scripts/check-secrets.sh 2>&1)"; then
  :
else
  printf 'hardening fixture failed: allowlisted gitignored file should pass the secret scan.\n' >&2
  printf '%s\n' "$allowlisted_scan_output" >&2
  failures=$((failures + 1))
fi
rm -f "$TEMP_DIR/.gitignore"
expect_failure_with_message "allowlisted but not ignored" "secret scan allowlist violation" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" add -f "$allow_dir/engine"
expect_failure_with_message "allowlisted but tracked" "secret scan allowlist violation" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" rm -q -f --cached "$allow_dir/engine"
rm -f "$TEMP_DIR/$allow_dir/engine"

# The ignored Hermes reference checkout is excluded from filename and content
# scans only while Git confirms every file is ignored and untracked.
resource_dir="resources/hermes-agent"
mkdir -p "$TEMP_DIR/$resource_dir/agent"
resource_key_kind='PRIVATE KEY'
printf '%s\n' "-----BEGIN ${resource_key_kind}-----" fixture > "$TEMP_DIR/$resource_dir/agent/secret_manager.py"
git -C "$TEMP_DIR/$resource_dir" init -q
git -C "$TEMP_DIR/$resource_dir" config user.email fixture@example.invalid
git -C "$TEMP_DIR/$resource_dir" config user.name fixture
git -C "$TEMP_DIR/$resource_dir" add agent/secret_manager.py
git -C "$TEMP_DIR/$resource_dir" commit -qm 'reference fixture'
printf 'resources/\n' > "$TEMP_DIR/.gitignore"
if reference_scan_output="$(cd "$TEMP_DIR" && bash scripts/check-secrets.sh 2>&1)"; then
  :
else
  printf 'hardening fixture failed: ignored nested Hermes checkout files should be skipped by the secret scan.\n' >&2
  printf '%s\n' "$reference_scan_output" >&2
  failures=$((failures + 1))
fi
rm -f "$TEMP_DIR/.gitignore"
expect_failure_with_message "reference checkout allowlisted but not ignored" "secret scan allowlist violation" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
printf 'resources/\n' > "$TEMP_DIR/.gitignore"
git -C "$TEMP_DIR" add -f "$resource_dir" 2>/dev/null
expect_failure_with_message "reference checkout tracked as a gitlink" "secret scan allowlist violation" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" rm -q -f --cached -- "$resource_dir"
rm -rf "$TEMP_DIR/$resource_dir/.git"
git -C "$TEMP_DIR" add -f "$resource_dir/agent/secret_manager.py"
expect_failure_with_message "reference checkout allowlisted but tracked" "secret scan allowlist violation" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" rm -q -f --cached "$resource_dir/agent/secret_manager.py"
rm -rf "$TEMP_DIR/$resource_dir" "$TEMP_DIR/.gitignore"

# Only a real directory at the Hermes path is the reference checkout; an ignored
# regular file there keeps the baseline content scan.
mkdir -p "$TEMP_DIR/resources"
printf '%s\n' "-----BEGIN ${resource_key_kind}-----" fixture > "$TEMP_DIR/$resource_dir"
printf 'resources/\n' > "$TEMP_DIR/.gitignore"
expect_failure_with_message "ignored regular file at reference checkout path" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -rf "$TEMP_DIR/resources" "$TEMP_DIR/.gitignore"

# An ignored Hermes-like directory without the reviewed allowlist entry keeps
# the original scanner behavior instead of failing solely because it exists.
unlisted_resource_fixture="$TEMP_DIR/unlisted-resource-scan"
mkdir -p "$unlisted_resource_fixture/scripts" "$unlisted_resource_fixture/.agentic" "$unlisted_resource_fixture/resources/hermes-agent"
cp "$ROOT_DIR/scripts/check-secrets.sh" "$unlisted_resource_fixture/scripts/"
sed '/^resources\/hermes-agent/d' "$ROOT_DIR/.agentic/secret-scan-ignore" > "$unlisted_resource_fixture/.agentic/secret-scan-ignore"
printf '/resources/\n' > "$unlisted_resource_fixture/.gitignore"
printf 'Reference README\n' > "$unlisted_resource_fixture/resources/hermes-agent/README.md"
git -C "$unlisted_resource_fixture" init -q
if ! (cd "$unlisted_resource_fixture" && bash scripts/check-secrets.sh >/dev/null 2>&1); then
  printf 'hardening fixture failed: an unlisted ignored reference directory failed without a finding.\n' >&2
  failures=$((failures + 1))
fi
printf 'fixture\n' > "$unlisted_resource_fixture/resources/hermes-agent/credentials.json"
expect_failure_with_message "unlisted ignored reference sensitive filename remains scanned" "sensitive-looking file found" bash -c "cd '$unlisted_resource_fixture' && bash scripts/check-secrets.sh"

# A linked worktree stores .git as a file, so the scanner's filesystem fallback
# must apply the same verified Hermes exclusion to its content scan.
linked_resource_repo="$TEMP_DIR/linked-resource-repo"
linked_resource_worktree="$TEMP_DIR/linked-resource-worktree"
mkdir -p "$linked_resource_repo/scripts" "$linked_resource_repo/.agentic"
cp "$ROOT_DIR/scripts/check-secrets.sh" "$linked_resource_repo/scripts/"
cp "$ROOT_DIR/.agentic/secret-scan-ignore" "$linked_resource_repo/.agentic/"
printf '/resources/\n' > "$linked_resource_repo/.gitignore"
git -C "$linked_resource_repo" init -q
git -C "$linked_resource_repo" config user.email fixture@example.invalid
git -C "$linked_resource_repo" config user.name fixture
git -C "$linked_resource_repo" add -A
git -C "$linked_resource_repo" commit -qm 'linked resource scanner fixture'
git -C "$linked_resource_repo" worktree add --detach "$linked_resource_worktree" HEAD >/dev/null
mkdir -p "$linked_resource_worktree/resources/hermes-agent/agent"
resource_key_kind='PRIVATE KEY'
printf '%s\n' "-----BEGIN ${resource_key_kind}-----" fixture > "$linked_resource_worktree/resources/hermes-agent/agent/secret_manager.py"
git -C "$linked_resource_worktree/resources/hermes-agent" init -q
git -C "$linked_resource_worktree/resources/hermes-agent" config user.email fixture@example.invalid
git -C "$linked_resource_worktree/resources/hermes-agent" config user.name fixture
git -C "$linked_resource_worktree/resources/hermes-agent" add agent/secret_manager.py
git -C "$linked_resource_worktree/resources/hermes-agent" commit -qm 'reference fixture'
if [[ ! -f "$linked_resource_worktree/.git" || -d "$linked_resource_worktree/.git" ]]; then
  printf 'hardening fixture did not create a linked worktree for secret scanning.\n' >&2
  failures=$((failures + 1))
elif ! (cd "$linked_resource_worktree" && bash scripts/check-secrets.sh >/dev/null 2>&1); then
  printf 'hardening fixture failed: linked-worktree scan did not skip the verified ignored Hermes checkout.\n' >&2
  failures=$((failures + 1))
fi

# Filename scanning remains active for paths whose content scan is excluded.
mkdir -p "$TEMP_DIR/.codex"
printf 'fixture\n' > "$TEMP_DIR/.codex/credentials.json"
git -C "$TEMP_DIR" add -f .codex/credentials.json
expect_failure_with_message "sensitive filename in excluded content directory" "sensitive-looking file found" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" rm -q -f --cached .codex/credentials.json
rm -rf "$TEMP_DIR/.codex"

# Credential-named files remain visible to the existing filename check even in
# generated output when they are tracked.
mkdir -p "$TEMP_DIR/dist"
printf 'fixture\n' > "$TEMP_DIR/dist/credentials.json"
git -C "$TEMP_DIR" add -f dist/credentials.json
expect_failure_with_message "sensitive tracked filename in generated output" "sensitive-looking file found" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
git -C "$TEMP_DIR" rm -q -f --cached dist/credentials.json
rm -rf "$TEMP_DIR/dist"

cat > "$TEMP_DIR/.github/workflows/unpinned.yml" <<'EOF'
name: bad
on: pull_request
permissions:
  contents: read
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - name: Unpinned named action
        uses: actions/checkout@v4
      - name: Unpinned reusable workflow
        uses: example/repo/.github/workflows/reusable.yml@v1
EOF
expect_failure_with_message "unpinned action" "unpinned action reference" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/unpinned.yml"

cat > "$TEMP_DIR/.github/workflows/job-only-permission.yml" <<'EOF'
name: job-only permission
on: pull_request
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
EOF
expect_failure_with_message "top-level workflow permission" "read-only contents permissions" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/job-only-permission.yml"

cat > "$TEMP_DIR/.github/workflows/checkout.yml" <<'EOF'
name: incomplete checkout hardening
on: pull_request
permissions:
  contents: read
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
      - name: Unrelated input with the same key
        uses: actions/upload-artifact@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
EOF
expect_failure_with_message "checkout credential persistence" "every checkout step" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/checkout.yml"

cat > "$TEMP_DIR/.github/workflows/timeout.yml" <<'EOF'
name: incomplete timeout hardening
on: pull_request
permissions:
  contents: read
jobs:
  first:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - run: true
  second:
    runs-on: ubuntu-latest
    steps:
      - run: true
EOF
expect_failure_with_message "job timeout coverage" "every job" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/timeout.yml"

cat > "$TEMP_DIR/.github/workflows/injection.yml" <<'EOF'
name: unsafe interpolation
on: pull_request
permissions:
  contents: read
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
      - name: Untrusted input
        run: |
          printf '%s\n' "${{ github.event.pull_request.title }}"
EOF
expect_failure_with_message "workflow injection and job permission" "direct untrusted event interpolation" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/injection.yml"

cat > "$TEMP_DIR/.github/workflows/event-context.yml" <<'EOF'
name: unsafe event context
on: pull_request
permissions:
  contents: read
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
      - run: printf '%s\n' "${{ github.event }}"
EOF
expect_failure_with_message "generic event context interpolation" "direct untrusted event interpolation" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/event-context.yml"

cat > "$TEMP_DIR/.github/workflows/job-permission.yml" <<'EOF'
name: unsafe job permission
on: pull_request
permissions:
  contents: read
jobs:
  bad:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
        with:
          persist-credentials: false
EOF
expect_failure_with_message "job-level permission" "workflow permission" bash -c "cd '$TEMP_DIR' && bash scripts/check-workflows.sh"
rm -f "$TEMP_DIR/.github/workflows/job-permission.yml"

printf '\nrm -rf /\n' >> "$TEMP_DIR/prompts/verify.md"
expect_failure_with_message "unsafe instruction" "high-risk command pattern" bash -c "cd '$TEMP_DIR' && bash scripts/check-instruction-surfaces.sh"
rm -f "$TEMP_DIR/prompts/verify.md"

printf '{\n  "sourceOfTruth": "wrong"\n}\n' > "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "invalid manifest contract" "sourceOfTruth must remain AGENTS.md" bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"

cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"
awk '{gsub(/scripts\/check-learning\.sh/, "scripts/check-does-not-exist.sh"); print}' "$TEMP_DIR/.agentic/manifest.json" > "$TEMP_DIR/.agentic/manifest.modified.json"
mv "$TEMP_DIR/.agentic/manifest.modified.json" "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "manifest check drift" "manifest hardeningChecks is missing" bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"

cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"
awk '{if ($0 ~ /^[[:space:]]*}[[:space:]]*$/) print "  not-json"; print}' "$TEMP_DIR/.agentic/manifest.json" > "$TEMP_DIR/.agentic/manifest.modified.json"
mv "$TEMP_DIR/.agentic/manifest.modified.json" "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "malformed manifest shape" "manifest JSON shape is invalid" bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"

cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"
sed 's/"schemaVersion": 1,/"schemaVersion": 1/' "$TEMP_DIR/.agentic/manifest.json" > "$TEMP_DIR/.agentic/manifest.modified.json"
mv "$TEMP_DIR/.agentic/manifest.modified.json" "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "missing manifest comma" "manifest JSON shape is invalid" bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"

cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"
sed 's/^  "upgradePolicy": \(.*\)$/  "upgradePolicy": \1,/' "$TEMP_DIR/.agentic/manifest.json" > "$TEMP_DIR/.agentic/manifest.modified.json"
mv "$TEMP_DIR/.agentic/manifest.modified.json" "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "trailing manifest comma" "manifest JSON shape is invalid" bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"

cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"
sed 's/^  "upgradePolicy": \(.*\)$/  "designSkill": {\n    "name": "impeccable"\n  },\n  "upgradePolicy": \1/' "$TEMP_DIR/.agentic/manifest.json" > "$TEMP_DIR/.agentic/manifest.modified.json"
mv "$TEMP_DIR/.agentic/manifest.modified.json" "$TEMP_DIR/.agentic/manifest.json"
expect_failure_with_message "nested manifest object" 'manifest key "designSkill" must be a string or an array of strings' bash -c "cd '$TEMP_DIR' && bash scripts/check-manifest.sh"
cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/manifest.json"

# Git hooks after checkout/merge are advisory: a failing project start must not block.
mkdir -p "$TEMP_DIR/scripts"
printf '#!/usr/bin/env bash\nexit 1\n' > "$TEMP_DIR/scripts/project"
chmod +x "$TEMP_DIR/scripts/project"
for hook in post-checkout post-merge; do
  if ! hook_output=$(cd "$TEMP_DIR" && bash ".githooks/$hook" 2>&1); then
    printf 'hardening fixture failed: %s must exit 0 when project start fails.\n' "$hook" >&2
    failures=$((failures + 1))
  elif ! grep -qF 'project start reported problems after checkout; run ./scripts/project check for details.' <<<"$hook_output"; then
    printf 'hardening fixture failed: %s did not print the advisory line.\n' "$hook" >&2
    failures=$((failures + 1))
  fi
done
rm -f "$TEMP_DIR/scripts/project"

# Lavish pages must use the shared theme and keep buttons clickable under the review overlay.
DESIGN_DIR="$TEMP_DIR/design-fixture"
mkdir -p "$DESIGN_DIR/scripts" "$DESIGN_DIR/.lavish" "$DESIGN_DIR/prompts" "$DESIGN_DIR/.claude/agents" "$DESIGN_DIR/.cursor/agents" "$DESIGN_DIR/.codex"
cp "$ROOT_DIR/scripts/check-design.sh" "$DESIGN_DIR/scripts/"
for file in PRODUCT.md DESIGN.md .lavish/theme.css .lavish/theme.js .claude/agents/impeccable-finish-reviewer.md .cursor/agents/impeccable-finish-reviewer.md; do
  : > "$DESIGN_DIR/$file"
done
for provider in .agents .claude .cursor; do
  mkdir -p "$DESIGN_DIR/$provider/skills/impeccable/scripts/bin"
  : > "$DESIGN_DIR/$provider/skills/impeccable/SKILL.md"
  printf '%s/skills/impeccable/scripts/bin/\n' "$provider" >> "$DESIGN_DIR/.gitignore"
done
for hook in .claude/settings.json .cursor/hooks.json .codex/hooks.json; do
  mkdir -p "$DESIGN_DIR/$(dirname "$hook")"
  printf 'skills/impeccable/scripts/impeccable\n' > "$DESIGN_DIR/$hook"
done
printf 'impeccable\n' > "$DESIGN_DIR/prompts/present.md"
printf 'DESIGN.md\n' > "$DESIGN_DIR/AGENTS.md"
git -C "$DESIGN_DIR" init -q
good_page='<!doctype html><link rel="stylesheet" href="theme.css"><script src="theme.js"></script><nav class="lv-links"><a href="#one" data-lavish-action>One</a></nav><button data-lavish-action="next">Next</button>'
printf '%s\n' "$good_page" > "$DESIGN_DIR/.lavish/page.html"
if ! (cd "$DESIGN_DIR" && bash scripts/check-design.sh >/dev/null 2>&1); then
  printf 'hardening fixture failed: compliant Lavish page should pass the design check.\n' >&2
  failures=$((failures + 1))
fi
printf '<!doctype html><script src="theme.js"></script>\n' > "$DESIGN_DIR/.lavish/page.html"
expect_failure_with_message "lavish page without theme.css" "Lavish page must link theme.css" bash -c "cd '$DESIGN_DIR' && bash scripts/check-design.sh"
printf '%s\n<script src="https://cdn.tailwindcss.com"></script>\n' "$good_page" > "$DESIGN_DIR/.lavish/page.html"
expect_failure_with_message "lavish page with tailwind cdn" "must not load Tailwind" bash -c "cd '$DESIGN_DIR' && bash scripts/check-design.sh"
printf '%s\n<button class="btn"\n  type="button">Bad</button>\n' "$good_page" > "$DESIGN_DIR/.lavish/page.html"
expect_failure_with_message "lavish button without data-lavish-action" "missing data-lavish-action" bash -c "cd '$DESIGN_DIR' && bash scripts/check-design.sh"
printf '<!doctype html><link rel="stylesheet" href="theme.css"><script src="theme.js"></script><nav class="lv-links"><a href="#one">One</a></nav>\n' > "$DESIGN_DIR/.lavish/page.html"
expect_failure_with_message "lavish nav link without data-lavish-action" "Lavish section nav link is missing data-lavish-action" bash -c "cd '$DESIGN_DIR' && bash scripts/check-design.sh"

if (( failures > 0 )); then
  printf 'hardening fixture check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'hardening fixture check passed: all negative cases were rejected.\n'
