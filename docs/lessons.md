# Lessons

Keep this list short, specific, and durable. Each entry should help a future human or agent make a better decision.

## Format

`YYYY-MM-DD — lesson — evidence — check: <script or "none: reason">`

## Log

- `YYYY-MM-DD — replace this example with the first durable lesson — link to the relevant plan, decision, or issue`
- `2026-11-08 — Skip third-party binaries in the secret scan only through the reviewed allowlist, and only when Git ignores them — engine binary false positive, docs/state/friction.md — check: scripts/check-secrets.sh + scripts/check-hardening-fixtures.sh (allowlist cases)`
- `2026-11-08 — Validator errors must name the offending key and the fix, not just "invalid" — nested designSkill rejected without explanation — check: scripts/check-manifest.sh + scripts/check-hardening-fixtures.sh (nested object case)`
- `2026-11-08 — Hooks that run after checkout or merge are advisory; only pre-commit and pre-push may block — post-checkout failed on an older commit — check: scripts/check-hardening-fixtures.sh (hook stub case)`
- `2026-11-08 — Every Lavish page uses theme.css/theme.js and marks real buttons with data-lavish-action; never ship decorative fake controls — clicks opened annotation instead of acting — check: scripts/check-design.sh`
- `2026-11-08 — When a user-level write gate blocks a new file, state the caller, purpose, and instruction once, then retry; do not work around it — GateGuard blocked six first writes — check: none: hook lives in user config outside this repository`
