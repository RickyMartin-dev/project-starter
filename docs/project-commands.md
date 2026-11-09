# Project Commands

These commands describe the Project Starter repository. Projects created from it should replace the baseline with their own clean-checkout development and quality commands.

## Environment

- Required tools: Bash, Git, and standard command-line utilities (`awk`, `find`, `grep`, `sed`, `tr`, and `wc`). No application runtime is required.
- Dependency install: none.
- Required local services: none.
- Required environment variables: none.
- Optional shared snapshot archive: set `PROJECT_SNAPSHOT_ARCHIVE_ROOT` to a local vault root. Python 3 is required only when this feature is enabled.

## Development

There is no application server or product build. Use the repository command to inspect the suggested orientation path, or start an agent session:

```bash
./scripts/project context
./scripts/project start --task "Describe the repository task"
./scripts/project finish --summary "Summarize the verified outcome"
```

`start` writes ignored local context and a task checkpoint. It installs `.githooks` only when no custom Git hooks path is configured. `finish` runs the checks, creates a repository snapshot and handoff, and archives a sanitized copy only when the optional archive root is configured.

## Quality gates

```bash
# Required files, adapters, local hardening checks, shell syntax, and tracked whitespace
./scripts/project check

# Full pre-push gate, including tracked and untracked whitespace
./scripts/project release-check

# Machine-readable starter status and project-placeholder warning
./scripts/project doctor --json

# Durable context and improvement workflows
./scripts/project compact <slug> "<handoff title>"
./scripts/project archive-snapshot --summary "<outcome>" [--agent codex|claude]
./scripts/project research <slug> "<research question>"
./scripts/project upgrade <slug> "<upgrade title>"
./scripts/project suggest-upgrades [--json]   # ranked by friction, failures, unchecked lessons, stale research

# Learning loop
./scripts/project friction "<area>" "<symptom>" "<cause>" "<fix>" [--status open|fixed|lesson]
./scripts/project finish --summary "<outcome>" --friction "<area>|<symptom>|<cause>|<fix>"
./scripts/project learn [--json]          # drafts proposals for areas with 2+ entries
./scripts/project retro [YYYY-MM] [--html] [--force] [--json]
./scripts/project specialist <slug> "<role title>"

# Design (Impeccable skill; Claude Code: /impeccable, Codex: $impeccable)
.claude/skills/impeccable/scripts/impeccable detect --json .lavish/
npx impeccable update   # refresh skills and hooks for all providers

# Combined project-guidance and current-practice review
# Claude Code: /update-project-logic
# Codex:       $update-project-logic
```

## Project-specific tooling

- Format: no formatter is configured for this documentation and shell repository.
- Lint: no standalone linter is configured. `./scripts/project check` validates shell syntax and the starter contract.
- Typecheck: not applicable; there is no typed application source.
- Tests: `./scripts/project release-check` runs the local contract and hardening fixtures.
- Build/package: not applicable; this repository has no application package.

## Expected output

Successful starter checks print a passing result and exit with status zero. `doctor --json` reports `placeholderWarnings: false` for this repository. The optional archive command reports that archiving is disabled unless `PROJECT_SNAPSHOT_ARCHIVE_ROOT` is set.

The starter gates do not install dependencies, start services, call hosted scanners, or test an adopting application's behavior. An adopted project must add and document its own application-specific checks.

## Durable operating artifacts

- Compaction snapshots: `docs/compactions/`.
- Optional shared snapshot archive: `PROJECT_SNAPSHOT_ARCHIVE_ROOT`.
- Research comparisons: `docs/research/`.
- Upgrade backlog and proposals: `docs/upgrades/`.
- Specialist role cards: `agents/`.
- Visual review surfaces: `.lavish/`.

These commands create reviewable Markdown and local repository state. They do not send project memory to an external service, train a model, or grant a generated specialist authority.
