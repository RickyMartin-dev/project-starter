# Current task

## Status

In progress: consolidate the project history and learning changes with the open Dependabot workflow update into one PR, then merge it to `main` after all reviews and CI checks pass.

- Owner: Codex
- Plan: `docs/plans/active/consolidated-project-pr-2026-11-24.md`
- Acceptance: both independent reviews approve; local gates pass; one PR contains this work and Dependabot #1; all PR CI checks pass; merge PR #2 to `main` and close PR #1 as superseded.

## Latest progress

- User chose a narrow scanner fix: preserve existing scan behavior and skip only the exact `resources/hermes-agent` checkout when allowlisted, ignored, and untracked. The same exception works in linked worktrees; unlisted paths retain the baseline behavior. Verification citations normalize a leading `./`, with CLI and learning-gate coverage.
- `check-hardening-fixtures.sh` covers allowlisted, unlisted, tracked, and linked-worktree cases. `check-learning.sh`, `check-automation.sh`, `./scripts/project check`, `release-check`, `doctor --json` (`status: pass`, `placeholderWarnings: false`), shell syntax, and `git diff --check` all pass.
- Astra and Luna xhigh both say MERGE-READY on this corrected candidate. The existing PR #2 consolidates the history/learning work and Dependabot #1's immutable `actions/checkout` pin, but its published head is older; hosted CI has not validated this follow-up. PR #1 remains open.
- The final reviewed follow-up is committed as `b17d753`. The last no-mistakes run completed intent and rebase, then failed at review because Claude had reached its usage limit. It made no branch changes or push; Claude has since reset.
- Both Astra and Luna xhigh approved the candidate, and all local gates pass. The final snapshot and shared archive are saved. Next: rerun the pipeline, publish PR #2's final head, confirm hosted CI green, merge PR #2 to `main`, then close PR #1 as superseded.

## Update protocol

At the start of a substantial task, record the goal, owner, plan link, and acceptance criteria here. Before handoff, record what changed, what was verified, and the next decision. Keep this file short and move completed context to `archive/` when it is no longer active.
