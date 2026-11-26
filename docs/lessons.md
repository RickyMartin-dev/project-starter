# Lessons

Keep this list short, specific, and durable. Each entry should help a future human or agent make a better decision.

## Format

`YYYY-MM-DD — area: lesson — apply: change — evidence: task records and verification — source: standing user correction or general lesson — check: <script or "none: reason">`

An explicit, durable user correction is marked `correction` in the friction log and may be recorded immediately. General procedures use the `lesson` marker and require at least two distinct existing task snapshots plus successful relevant verification; cite both records and the result in the evidence. The source field preserves which path produced the entry. If a mechanical check cannot judge a lesson, state why in its `check: none: ...` field.

## Log

- `YYYY-MM-DD — replace this example with the first durable lesson — link to the relevant plan, decision, or issue`
- `2026-11-08 — Skip third-party binaries in the secret scan only through the reviewed allowlist, and only when Git ignores them — engine binary false positive, docs/state/friction.md — check: scripts/check-secrets.sh + scripts/check-hardening-fixtures.sh (allowlist cases)`
- `2026-11-08 — Validator errors must name the offending key and the fix, not just "invalid" — nested designSkill rejected without explanation — check: scripts/check-manifest.sh + scripts/check-hardening-fixtures.sh (nested object case)`
- `2026-11-08 — Hooks that run after checkout or merge are advisory; only pre-commit and pre-push may block — post-checkout failed on an older commit — check: scripts/check-hardening-fixtures.sh (hook stub case)`
- `2026-11-08 — Every Lavish page uses theme.css/theme.js and marks real buttons with data-lavish-action; never ship decorative fake controls — clicks opened annotation instead of acting — check: scripts/check-design.sh`
- `2026-11-08 — When a user-level write gate blocks a new file, state the caller, purpose, and instruction once, then retry; do not work around it — GateGuard blocked six first writes — check: none: hook lives in user config outside this repository`
- 2026-11-26 — agent-efficiency: User wants project workflows to be token-efficient and automated — apply: Automate deterministic project checks and avoid repeating broad validation runs — evidence: A broad live validation agent ran for 30 minutes before direct checks were used — source: standing user correction (docs/state/friction.md) — check: none: standing user correction requires human judgment and is enforced through project guidance
