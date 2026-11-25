# Current task

## Status

In progress: consolidate the project history and learning changes with the open Dependabot workflow update into one merge-ready PR.

- Owner: Codex
- Plan: `docs/plans/active/consolidated-project-pr-2026-11-24.md`
- Acceptance: both independent reviews approve; local gates pass; one PR contains this work and Dependabot #1; all PR CI checks pass; do not merge.

## Latest progress

- PR #2 consolidates the history/learning work and Dependabot #1's immutable `actions/checkout` pin; the final candidate is ready to publish, and PR #1 remains open until the updated PR #2 head is green.
- The working tree guards friction and pending-queue destinations, preserves unreadable or unsupported queued records, imports corrections into both memory records, deduplicates next-day retries, and prevents evidence text from imitating source/check metadata.
- The expanded automation suite, `./scripts/project check`, `release-check`, `doctor --json`, shell syntax, learning gate, and `git diff --check` pass on the candidate.
- Astra and Luna xhigh both state MERGE-READY on the reviewed working tree. The candidate is not yet pushed, so hosted CI must run on the published PR #2 head before readiness is final.
- Do not merge. Push the reviewed candidate, confirm all PR checks green, then close superseded PR #1.

## Update protocol

At the start of a substantial task, record the goal, owner, plan link, and acceptance criteria here. Before handoff, record what changed, what was verified, and the next decision. Keep this file short and move completed context to `archive/` when it is no longer active.
