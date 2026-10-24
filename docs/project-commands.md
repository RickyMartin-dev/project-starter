# Project Commands

Replace the placeholders with commands that work from a clean checkout. Agents should use this file instead of guessing how to install, run, lint, typecheck, test, or build the project.

## Environment

- Required runtime/tool versions: `replace-me`
- Dependency install: `replace-me`
- Required local services: `none | replace-me`
- Required environment variables: document names and safe placeholders only; never commit values.
- Optional shared snapshot archive: `PROJECT_SNAPSHOT_ARCHIVE_ROOT` (unset by default; Python 3 is needed only when enabled).

## Development

```bash
# Start the local development loop.
replace-me
```

## Quality gates

```bash
# Starter contract and local hardening checks
./scripts/project check

# Full pre-push gate, including negative-path fixtures and learning proposals
./scripts/project release-check

# Durable context and improvement loop
./scripts/project compact <slug> "<handoff title>"
./scripts/project archive-snapshot --summary "<outcome>" [--agent codex|claude]
./scripts/project research <slug> "<research question>"
./scripts/project upgrade <slug> "<upgrade title>"
./scripts/project suggest-upgrades [--json]
./scripts/project specialist <slug> "<role title>"

# Project logic and AI-practice refresh
# Claude Code: /update-project-logic
# Codex:       $update-project-logic

# Format
replace-me

# Lint
replace-me

# Typecheck
replace-me

# Tests
replace-me

# Build/package
replace-me
```

## Expected output

Document what success looks like and which checks are intentionally unavailable in a local or offline environment.

The starter checks require Bash and standard Git/core shell tools only. Project-specific format, lint, typecheck, test, and build commands remain the responsibility of the adopting repository. The release gate checks staged and unstaged whitespace errors relative to `HEAD` when a commit exists, with a worktree/index fallback for a freshly initialized repository.

## Durable operating artifacts

- Compaction snapshots: `docs/compactions/`.
- Optional shared snapshot archive: set `PROJECT_SNAPSHOT_ARCHIVE_ROOT` to a local vault root. This setting is unset by default.
- Research comparisons: `docs/research/`.
- Upgrade backlog and proposals: `docs/upgrades/`.
- Specialist role cards: `agents/`.
- Visual review surface: `.lavish/project-starter-operating-system.html`.

These commands create reviewable Markdown. They do not install dependencies, send project memory to an external service, train a model, or grant a generated specialist authority.
