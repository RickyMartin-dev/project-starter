# Decision: Separate correction and general lesson markers

- Date: 2026-11-25
- Status: accepted
- Owner: Project maintainer

## Context

The `lesson` friction status represented both immediate standing user corrections and general procedures. That made it possible to record a general lesson without evidence from separate tasks or successful verification.

## Decision

- Use `correction` for an explicit standing user correction. It may be recorded immediately, with a written reason when no mechanical check can judge compliance.
- Reserve `lesson` for general procedures. The cause must cite two distinct existing `docs/compactions/*.md` task snapshots and successful verification. The sixth field must name an existing script under `scripts/`, which the CLI runs before recording, or a justified `none: ...` reason when no enforcing check can be added.
- Friction that does not meet either path remains a friction record or an unpromoted proposal.

## Consequences

The CLI and learning gate share the same read-only evidence validator; the CLI runs an enforcing check before writing a general lesson. `correction` and `lesson` entries are excluded from recurring-friction proposal counts. Existing historical entries remain intact.
