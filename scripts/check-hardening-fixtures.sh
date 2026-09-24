#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/project-starter-hardening.XXXXXX")"
trap 'rm -rf "$TEMP_DIR"' EXIT

failures=0
copy_fixture() {
  mkdir -p "$TEMP_DIR/.github/workflows" "$TEMP_DIR/.agentic/fixtures" "$TEMP_DIR/scripts" "$TEMP_DIR/.cursor/rules" "$TEMP_DIR/.cursor/commands" "$TEMP_DIR/.claude/rules" "$TEMP_DIR/.claude/commands" "$TEMP_DIR/prompts" "$TEMP_DIR/docs/state/proposals"
  cp "$ROOT_DIR/scripts/check-secrets.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-workflows.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-instruction-surfaces.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/scripts/check-manifest.sh" "$TEMP_DIR/scripts/"
  cp "$ROOT_DIR/.agentic/manifest.json" "$TEMP_DIR/.agentic/"
  cp "$ROOT_DIR/.agentic/fixtures/untrusted-repo-note.md" "$TEMP_DIR/.agentic/fixtures/"
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
  bash scripts/check-manifest.sh
); then
  printf 'hardening fixture baseline unexpectedly failed.\n' >&2
  exit 1
fi

printf 'AKIA%s\n' '1234567890ABCDEF' > "$TEMP_DIR/fake-leak.txt"
expect_failure_with_message "credential pattern" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -f "$TEMP_DIR/fake-leak.txt"

key_kind='PRIVATE KEY'
printf '%s\n' "-----BEGIN ${key_kind}-----" "fake" "-----END ${key_kind}-----" > "$TEMP_DIR/fake-private-key.txt"
expect_failure_with_message "generic private-key pattern" "possible credential material" bash -c "cd '$TEMP_DIR' && bash scripts/check-secrets.sh"
rm -f "$TEMP_DIR/fake-private-key.txt"

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

if (( failures > 0 )); then
  printf 'hardening fixture check failed with %s issue(s).\n' "$failures" >&2
  exit 1
fi

printf 'hardening fixture check passed: all negative cases were rejected.\n'
