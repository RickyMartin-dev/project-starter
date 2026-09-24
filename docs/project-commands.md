# Project Commands

Replace the placeholders with commands that work from a clean checkout. Agents should use this file instead of guessing how to install, run, lint, typecheck, test, or build the project.

## Environment

- Required runtime/tool versions: `replace-me`
- Dependency install: `replace-me`
- Required local services: `none | replace-me`
- Required environment variables: document names and safe placeholders only; never commit values.

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
