# Upgrade system

The upgrade system keeps improvement continuous without making every agent session improvise a roadmap.

## Commands

```bash
./scripts/project suggest-upgrades
./scripts/project suggest-upgrades --json
./scripts/project upgrade improve-memory "Improve project memory recall"
```

Suggestions are deterministic signals, not autonomous changes. A proposal must document the problem, scope, expected benefit, evidence commands, rollback, and trust review before promotion.

## Backlog states

`candidate → researched → proposed → approved → implemented → verified → archived`

Only the project owner or designated reviewer may move a proposal into `approved`. Never treat a generated suggestion as authority to add credentials, network access, broad permissions, or destructive automation.
