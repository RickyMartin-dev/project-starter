# Plan: Move secondary project guides out of the repository root

- Owner: Codex
- Created: 2026-11-08
- Status: complete
- Scope: Move the changelog and contribution guide under `docs/` while keeping links and GitHub contribution discovery intact.

## Goal

Reduce root-level files without moving agent, security, license, design, or Git entrypoints.

## Non-goals

- Moving any other root files or feature directories.

## Assumptions and decisions needed

- Move `CONTRIBUTING.md` and `CHANGELOG.md` to `docs/`; link both from the root README.
- GitHub recognizes `docs/CONTRIBUTING.md`; no in-repository automation depends on root `CHANGELOG.md`.

## Steps

- [x] Move both guides and update README and workflow references.
- [x] Extend the starter check to enforce new paths and README links.
- [x] Run project checks, finish with an archived snapshot, and review the final diff.

## Acceptance criteria

- [x] Root contains two fewer tracked files; both guides remain linked; required checks pass.

## Verification

```bash
./scripts/project check
./scripts/project release-check
git diff --check
```

## Risks and recovery

- The root changelog path changes; preserve discoverability with README and workflow links, and update all local references.

## Verification so far

- `./scripts/project check` passed with 148 required files.
- `./scripts/project release-check` passed before and after finish.
- `git diff --check HEAD --` passed; live root listing shows 9 tracked root files (down from 11).
- `./scripts/project finish` saved the sanitized task snapshot and updated the repository handoff.
