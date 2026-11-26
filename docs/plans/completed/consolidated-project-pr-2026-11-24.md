# Plan: Consolidate project learning changes and open PRs into one reviewed PR and merge it

- Owner: Codex
- Created: 2026-11-24
- Status: complete
- Scope: Consolidate the project history/learning work and the open Dependabot workflow update into one reviewed PR, then merge it to main.

## Goal

Publish one feature branch and pull request containing the authorized project changes and Dependabot PR #1. Merge PR #2 to main after both independent reviewers approve and required GitHub checks pass; close PR #1 as superseded.

## Decisions

- Keep history and learning project-local; do not add MCP, external memory, raw transcript search, or storage.
- Use correction for immediate standing user corrections. General lessons need two distinct snapshots, successful verification evidence, and a passing check or justified no-check reason.
- Keep automatic retrospective creation enabled.
- Restrict the Hermes scanner exception to the allowlisted, ignored, untracked checkout directory and preserve normal scan behavior elsewhere.
- The user authorized merging PR #2 after reviews and CI pass, superseding the earlier no-merge instruction.

## Outcome

- PR #2 merged to main at 0b269bfdea4485ec411d394d57ab81ca07446489. Its final reviewed head was 77e7c822c774cb275fc5f73a74d6f8006e23d67c.
- PR #1, the actions/checkout v7.0.1 update, was closed as superseded; its pin is included across workflows.
- Both independent final reviewers marked the exact final head merge-ready.
- Starter security and Starter quality workflows passed on the exact final head.
- Direct project check, release-check, and doctor --json passed on a clean snapshot of submitted feature commit 01f91dc; doctor reported status pass and no placeholder warnings.
- The no-mistakes Test agent exceeded its 30-minute budget before completing live scenarios. The timeout gate was approved after direct checks, and the pipeline completed with passed-with-override.
- Lint syntax checks passed with bash -n. ShellCheck was unavailable; this repository documents no standalone linter.
- The full merge diff passed git diff --check. resources/hermes-agent/README.md is ignored, and no resources paths are tracked.
- The follow-up timeout friction and the user's token-efficiency preference were recorded for future learning.

## Verification

- ./scripts/project check — passed on a clean snapshot of the submitted feature commit.
- ./scripts/project release-check — passed on the same snapshot.
- ./scripts/project doctor --json — status pass; placeholderWarnings false.
- Starter security and Starter quality — passed on final PR head 77e7c822c774cb275fc5f73a74d6f8006e23d67c.
- git diff --check — passed from the previous main head to the merged main.
- resources/hermes-agent/README.md — confirmed ignored; git ls-files resources returned no paths.

## Follow-up

The test-agent timeout exposed that the pipeline had no configured test command and used a long broad live-validation run. Consider a deterministic repository test command in a future reviewed improvement.
