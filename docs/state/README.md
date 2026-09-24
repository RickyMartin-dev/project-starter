# Durable agent state

This directory is the repository-backed memory bank for work that should survive an agent session. It is intentionally plain Markdown so Codex, Claude Code, Cursor, and human contributors can all read and review it.

Agents may propose updates, but a human or task owner should review durable changes before they become policy. Never store secrets, access tokens, private customer data, or unreviewed prompt output here.

## Files

- `current-task.md`: the bounded task currently in motion.
- `next-task.md`: the highest-value follow-up that is not yet started.
- `handoff.md`: context needed by the next agent or contributor.
- `risks.md`: open risks, mitigations, and owners.
- `bugs.md`: reproducible defects that should not be lost in chat history.
- `proposals/`: agent-generated learning proposals awaiting reviewer-agent approval.
- `archive/`: completed state snapshots when history is useful.

## Learning loop

1. Record a bounded observation or improvement proposal.
2. Add reproducible evidence, expected benefit, scope, rollback, and trust review.
3. Ask the designated reviewer agent to apply `prompts/promote.md`.
4. Promote only the smallest durable change and append evidence to `docs/verification-log.md`.
