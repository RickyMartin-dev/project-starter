# Plan: Automate project-local history and evidence-based learning

- Owner: Codex
- Created: 2026-11-24
- Status: complete
- Scope: Make project history discoverable at task start and curate durable learning automatically at task finish.

## Goal

Add bounded retrieval from Git and canonical Markdown records, then use verified corrections and recurring evidence to improve project-local lessons and scoped procedures without raw transcript storage or external services.

## Non-goals

- MCP, external memory providers, databases, schedulers, global memory, and raw session transcript search.
- Runtime automatic changes to root instructions, hooks, security boundaries, or learning gates.
- Editing the ignored `resources/hermes-agent/` reference checkout.

## Assumptions and decisions

- `start --task` retrieves the top five lexical matches; explicit `recall` accepts a limit from 1–10.
- Explicit standing corrections can be curated immediately; general procedures require two independent task occurrences, successful verification, cited evidence, and an enforcing check or written no-check reason.
- A lesson needs an enforcing check or a written reason one cannot be added. Unresolved issues remain friction/proposals; no-op is valid.
- `finish` runs proposal grouping and creates a missing retrospective for the previous month when that month has project records.
- The ignored Hermes source tree is an intentional, reviewed secret-scan exclusion only while Git confirms it remains ignored and untracked.

## Steps

- [x] Make secret scanning honor the reviewed ignored-source allowlist for both filenames and contents; add regression fixtures.
- [x] Add bounded Markdown/Git history recall and include it in generated task context.
- [x] Add a checkpoint learning outcome, automatic proposal grouping, and idempotent previous-month retrospective generation.
- [x] Update agent instructions, learning protocol, command docs, and manifest.
- [x] Add fixtures for recall, no-op/threshold behavior, finish automation, and trust boundaries.

## Acceptance criteria

- `start --task` succeeds with the ignored Hermes checkout present and embeds at most five sanitized, linked project records.
- `recall` returns bounded, sanitized matches and never searches resources, local state, or transcripts.
- Finish records the learning outcome, groups repeated friction, and generates at most one retrospective per completed month.
- Finish supports an evidence-backed general lesson with a sixth friction field for its enforcing check while preserving four- and five-field inputs.
- Existing four-field `--friction` inputs remain compatible; explicit status can be supplied for a curated lesson.
- Review rules allow evidence-backed project-local lessons through the two defined paths and retain approval for core policy, hooks, security, and gate changes.

## Verification

```bash
./scripts/project check
./scripts/project release-check
git diff --check
```

## Risks and recovery

- A broad ignored-tree exception could hide local material inside that tree; it is accepted only while the path is Git-ignored and untracked. Removing the allowlist entry restores scanning.
- Lesson selection is semantic; retrieval, validation, grouping, and state recording are deterministic, while criteria require independent evidence and successful verification.
- All durable changes remain ordinary Git diffs and can be reviewed or reverted.
