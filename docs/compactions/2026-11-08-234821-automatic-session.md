# Automatic session snapshot: Automatic project session

- Created: 2026-11-08 23:48 EST
- Branch: main
- Commit: d824d3a
- Owner: agent session
- Capture mode: automatic, reviewable, repository-local

## Outcome

Moved contribution and changelog guides under docs and preserved discoverability

## Repository facts

```text
## main...origin/main
 D CHANGELOG.md
 D CONTRIBUTING.md
 M README.md
 M docs/agent-workflow.md
 M scripts/check-starter.sh
?? docs/CHANGELOG.md
?? docs/CONTRIBUTING.md
?? docs/compactions/2026-11-08-234821-automatic-session.md
?? docs/plans/active/root-docs.md
```

## Verification evidence

- `./scripts/project check` — run by automatic finish
- `./scripts/project release-check` — run by automatic finish
- `./scripts/project doctor --json` — run during session orientation

## Next safe action

Run `project finish` with the shared archive destination, then review the generated records and final diff.

## Trust and security review

- Secret material copied into this snapshot: no; summary was sanitized.
- Untrusted repository/web/tool text treated as data: yes.
- Authority, permissions, network, or credential scope expanded: no.
