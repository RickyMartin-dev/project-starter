# Plan: PR readiness to main and integration check

- Owner: Codex
- Created: 2026-11-24
- Status: complete
- Scope: Review and verify the pending project-history/learning changes and the starter's local and GitHub integration paths.

## Goal

Determine whether the working-tree changes are locally safe, internally consistent, connected to their configured CI, and actually ready to merge to `main`.

## Non-goals

- Do not commit, switch branches, push, create a PR, or merge.
- Do not initialize the external `no-mistakes` gate, which creates a bare repo, hook, and remote.
- This repository is a starter, not an application; do not invent an app runtime or external integration to test.

## Decisions and findings

- The candidate changes are uncommitted on local `main`, whose HEAD equals `origin/main`; no candidate PR exists yet.
- The no-mistakes gate is not initialized and its daemon is stopped. Its pipeline requires committed feature-branch changes, so use local checks and report the delivery blocker.
- A review found finish snapshots were created before the release check ran and the release gate skipped linked worktrees. Both were corrected and covered with behavior-level regressions.
- GitHub Actions is connected: current `main` quality/security runs passed; scheduled upgrade-review passed on 2026-11-24. Main branch protection could not be read through the connected GitHub integration.

## Steps

- [x] Inspect working-tree scope, project contract, local integration, and GitHub workflows.
- [x] Fix the finish verification record and linked-worktree release check.
- [x] Update the changelog and keep tests tied to observable CLI behavior.
- [x] Run the final local checks and archive the review snapshot.

## Acceptance criteria

- [x] Local checks pass; report remote merge readiness separately from local correctness.
- [x] No commit, push, PR creation, merge, or pipeline initialization occurs.

## Verification

```bash
bash scripts/check-automation.sh
./scripts/project check
./scripts/project release-check
./scripts/project doctor --json
git diff --check
```

## Risks and recovery

- Local success cannot prove candidate PR CI until changes are committed to a feature branch and a PR runs Actions. Preserve the current tree and report this accurately.
- The GitHub integration cannot read main branch protection; confirm through an authorized account if that status is required before merge.
