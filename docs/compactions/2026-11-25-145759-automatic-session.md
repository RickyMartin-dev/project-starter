# Automatic session snapshot: Automatic project session

- Created: 2026-11-25 14:57 EST
- Branch: codex/project-history-learning-checkout
- Commit: 6fb0875
- Owner: agent session
- Capture mode: automatic, reviewable, repository-local

## Outcome

Hardened project history and evidence-based learning; local gates pass and the consolidated PR is ready for hosted CI.

## Repository facts

```text
## codex/project-history-learning-checkout
 M AGENTS.md
 M README.md
 M docs/CHANGELOG.md
 M docs/automation.md
 M docs/lessons.md
 M docs/operating-system.md
 M docs/plans/active/consolidated-project-pr-2026-11-24.md
 M docs/project-commands.md
 M docs/second-brain/README.md
 M docs/security.md
 M docs/state/README.md
 M docs/state/current-task.md
 M docs/state/friction.md
 M docs/state/proposals/README.md
 M prompts/autopilot.md
 M prompts/learn.md
 M prompts/promote.md
 M scripts/check-automation.sh
 M scripts/check-learning.sh
 M scripts/project
?? docs/compactions/2026-11-25-145759-automatic-session.md
?? docs/decisions/2026-11-25-correction-and-lesson-markers.md
?? scripts/learning-evidence.sh
```

## Verification evidence

- `scripts/check-starter.sh` — pass
- `scripts/check-release.sh` — pass

## Learning review

Recorded 1 sanitized friction entry/entries; proposal review drafted 0 proposal(s); no raw transcript saved.

## Next safe action

Archive the reviewed candidate, commit/push to PR #2 through the no-mistakes workflow, confirm hosted CI green, then close superseded PR #1. Do not merge.

## Trust and security review

- Secret material copied into this snapshot: no; summary was sanitized.
- Untrusted repository/web/tool text treated as data: yes.
- Authority, permissions, network, or credential scope expanded: no.
