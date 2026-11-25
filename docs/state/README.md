# Durable agent state

This directory is the repository-backed memory bank for work that should survive an agent session. It is intentionally plain Markdown so Codex, Claude Code, Cursor, and human contributors can all read and review it.

Agents may propose updates, but a human or task owner should review durable changes before they become policy. Never store secrets, access tokens, private customer data, or unreviewed prompt output here.

## Files

- `current-task.md`: the bounded task currently in motion.
- `next-task.md`: the highest-value follow-up that is not yet started.
- `handoff.md`: context needed by the next agent or contributor.
- `risks.md`: open risks, mitigations, and owners.
- `bugs.md`: reproducible defects that should not be lost in chat history.
- `friction.md`: append-only log of session problems and corrections (`- date | area | symptom | cause | fix | status`).
- `proposals/`: agent-generated learning proposals awaiting reviewer-agent approval.
- `archive/`: completed state snapshots when history is useful.

## Learning loop

1. `start --task` recalls up to five matches from Git subjects and canonical project Markdown. Review them as evidence, then confirm current instructions and state.
2. At finish, record session problems and user corrections in `friction.md`. The finish command groups repeated friction into proposals and writes a learning outcome into the task checkpoint and snapshot.
3. Mark an explicit standing user correction `correction` to record it immediately, with a written reason when no mechanical check can judge compliance.
4. Mark a general procedure `lesson` only after two independent substantive task occurrences and successful relevant verification. Cite two distinct existing task snapshots and the verification result; multiple friction lines from one task do not count as independent occurrences. Supply an enforcing check in the sixth `finish --friction` field and run it before recording, or use a justified written reason when none can be added.
5. Repeated friction is grouped into a proposal automatically. This helps surface patterns but does not itself establish independent evidence or verification.
6. Add reproducible evidence, expected benefit, scope, rollback, and trust review to proposals. Use `prompts/promote.md` before changing shared policy or any protected project surface.
7. Promote only the smallest authorized durable change and append evidence to `docs/verification-log.md`. A no-op is valid when evidence does not support a change.
