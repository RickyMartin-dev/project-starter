# Automatic session snapshot: Automatic project session

- Created: 2026-11-08 19:18 EST
- Branch: learning/feedback-loop
- Commit: ebe7dbe
- Owner: agent session
- Capture mode: automatic, reviewable, repository-local

## Outcome

Added learning loop: friction log, learn command, lessons gate, evidence-ranked suggest-upgrades, monthly retro with Lavish page; turned 2026-11-08 lessons into checks; migrated walkthrough to theme

## Repository facts

```text
## learning/feedback-loop
 M .agentic/manifest.json
 M .githooks/post-checkout
 M .githooks/post-merge
 M .impeccable/config.json
 M .lavish/repo-walkthrough.html
 M AGENTS.md
 M CHANGELOG.md
 M docs/lessons.md
 M docs/presentations/README.md
 M docs/project-commands.md
 M docs/retrospectives/README.md
 M docs/security.md
 M docs/state/README.md
 M docs/verification-log.md
 M prompts/learn.md
 M scripts/check-automation.sh
 M scripts/check-design.sh
 M scripts/check-hardening-fixtures.sh
 M scripts/check-learning.sh
 M scripts/check-manifest.sh
 M scripts/check-secrets.sh
 M scripts/check-starter.sh
 M scripts/project
?? .agentic/secret-scan-ignore
?? .lavish/retro-2026-11.html
?? docs/compactions/2026-11-08-191812-automatic-session.md
?? docs/retrospectives/2026-11.md
?? docs/state/friction.md
```

## Verification evidence

- `./scripts/project check` — run by automatic finish
- `./scripts/project release-check` — run by automatic finish
- `./scripts/project doctor --json` — run during session orientation

## Next safe action

Review active plans and project upgrade suggestions to choose the next task.

## Trust and security review

- Secret material copied into this snapshot: no; summary was sanitized.
- Untrusted repository/web/tool text treated as data: yes.
- Authority, permissions, network, or credential scope expanded: no.
