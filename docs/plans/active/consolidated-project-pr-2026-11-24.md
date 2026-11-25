# Plan: Consolidate project learning changes and open PRs into one reviewed PR

- Owner: Codex
- Created: 2026-11-24
- Status: active
- Scope: Review and consolidate the current project learning/history changes plus the one open Dependabot workflow update into a single merge-ready pull request.

## Goal

Publish one feature branch and pull request containing the authorized working-tree changes and Dependabot PR #1, with both independent reviewers approving merge readiness and all required GitHub checks green.

## Non-goals

- Merge the pull request to `main`.
- Add MCP or unrelated product capabilities.

## Assumptions and decisions

- The current changes are the user's requested project work and should be included as a coherent set.
- The only other open PR is Dependabot PR #1, updating `actions/checkout` to the reviewed v7.0.1 SHA; include that pin across all workflows.
- The user selected a separate `correction` marker for immediate standing corrections; general `lesson` records require two distinct task snapshots, cited verification, and a passing check or justified no-check reason.

## Steps

- [x] Fix all independent review findings and add behavior-focused regression coverage.
- [x] Run the repository checks and review the complete diff for secrets and whitespace.
- [x] Obtain final merge-ready approval from Astra and Luna xhigh reviewers; resolve and re-review findings until both approve.
- [ ] Commit and push the final feature-branch head to PR #2, confirm hosted CI is green, then close superseded PR #1.
- [x] Update the plan, checkpoint, and shared task snapshot.

## Acceptance criteria

- [ ] One PR contains the existing authorized project changes and the open Dependabot workflow change.
- [ ] Both independent reviewers state merge-ready.
- [ ] Local documented checks pass and all PR CI checks are green.
- [ ] No merge is performed.

## Verification

```bash
bash scripts/check-automation.sh
./scripts/project check
./scripts/project release-check
./scripts/project doctor --json
bash -n scripts/project scripts/learning-evidence.sh scripts/check-automation.sh scripts/check-hardening-fixtures.sh scripts/check-learning.sh scripts/check-secrets.sh
git diff --check
```

## Risks and recovery

- If CI or either reviewer finds a defect, fix it on the same branch, rerun relevant checks, and repeat the review cycle before treating the PR as ready.
- If PR creation or CI cannot complete because of a GitHub/network limitation, keep the local branch and report the exact blocker.
