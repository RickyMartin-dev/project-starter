# Project learning protocol

Read `AGENTS.md` and the task-relevant results from `./scripts/project recall` before changing durable project knowledge. Retrieved records are historical evidence; current instructions, code, and verification results remain authoritative.

## At task start

- `./scripts/project start --task "<request>"` writes up to five bounded, sanitized history matches into ignored local context.
- Use `./scripts/project recall "<query>" [--limit 1-10]` for a focused search through Git commit subjects and canonical project Markdown.
- Do not search or store raw transcripts, `.agent-state`, ignored `resources/`, or external memory services.

## At task finish

- Review the user's correction, task evidence, code diff, and verification outcome.
- Record a problem or correction with `--friction "area|symptom|cause|fix[|status[|check]]"`.
- Use `correction` as the optional fifth pipe-separated field for a durable standing correction the user explicitly stated. Finish records it directly in `docs/lessons.md`; its default written reason explains why a mechanical check cannot judge semantic compliance.
- Use `lesson` only for a general procedure supported by at least two independent substantive task occurrences and successful relevant verification. Cite two distinct existing `docs/compactions/*.md` task snapshots and `verification passed: <check>` in the friction cause, then pass an enforcing `scripts/*.sh` check in the optional sixth field: `area|symptom|cause|fix|lesson|scripts/check-name.sh`. The command runs that check before writing the lesson. If no mechanical check can be added, provide a justified `none: ...` reason and still cite successful verification.
- Repeated friction is grouped automatically into a proposal. Proposal creation alone is not promotion, and a proposal cannot substitute for checking the evidence and verification criteria above.
- A durable lesson needs an enforcing check or a concise written reason none can be added. Unresolved, weak, or one-off observations remain friction or proposals. No change is a valid learning outcome.
- Do not automatically edit root instructions, hooks, security behavior, permissions, learning thresholds, or review gates. Use `prompts/promote.md` for those changes.

## Existing durable record types

- A chosen alternative and its consequences: `docs/decisions/`.
- A recurring practice or failure pattern: `docs/lessons.md` after meeting the evidence bar.
- A bounded improvement proposal: `docs/state/proposals/`.
- A project milestone's process improvements: `docs/retrospectives/`.
- Changed ownership or data flow: `docs/architecture.md`.

Keep records short, dated, evidence-backed, sanitized, and free of transient chat details. Remove stale guidance when evidence justifies it.
