# Changelog

All notable changes to this starter are recorded here.

## 2026-11-24

- Added bounded project-local history recall at task start and a focused `project recall` command over Git subjects and canonical Markdown.
- Automated finish learning reviews, friction proposal grouping, evidence-backed lesson curation, and idempotent prior-month retrospectives. Raw transcripts and ignored `resources/` stay outside history search.
- Hardened filename and content scanning around ignored Hermes reference checkouts and generated trees, tightened lesson evidence validation, and fixed recall results for frontmatter and large histories.
- Capped recall work at 50 skill notes, 450 Markdown history records, and 500 Git subjects while always including core orientation files.
- Made finish JSON accurately report archive and retrospective state, removed unrun checks from snapshots, fixed month-independent retrospective coverage, and corrected linked-worktree whitespace checks.
- Updated all repository workflows to the verified `actions/checkout` v7.0.1 commit used by the Dependabot PR.
- Separated immediate standing corrections from general lessons; general lessons now require two distinct existing task snapshots, cited successful verification, and a passing enforcing script or justified no-check reason.

## 2026-11-08

- Added a learning loop: `docs/state/friction.md` with `project friction` and `finish --friction`; `project learn` drafts proposals for repeated problems; a gate requires real lessons once snapshots accumulate; lessons carry an enforcing check.
- `suggest-upgrades` now ranks evidence (recurring friction, failing checks, unchecked lessons, waiting proposals, stale research); `project retro` writes a monthly retrospective and Lavish page.
- Turned the day's lessons into checks: reviewed secret-scan allowlist (`.agentic/secret-scan-ignore`), key-specific manifest errors, advisory post-checkout/post-merge hooks, and a Lavish theme check. Migrated `repo-walkthrough.html` to the shared theme.
- Adopted the Impeccable design skill for Claude Code, Codex, and Cursor, with design hooks, review subagents, `PRODUCT.md`, `DESIGN.md`, and `scripts/check-design.sh`. Engine binaries stay gitignored. Decision: `docs/decisions/2026-11-08-impeccable-design-skill.md`.
- Added the shared Lavish theme (`.lavish/theme.css`, `.lavish/theme.js`) and a light/dark sign-off preview.

## 2026-10-24

- Added the cross-agent `update-project-logic` skill for Codex and Claude Code, with fresh-source research, project learning refresh, concise improvement/security reporting, and provider-copy drift checks.
- Updated the starter manifest and agent workflow to make the skill discoverable at architecture, harness, and repeated-failure milestones.
- Hardened the freshness workflow to compare installed agent CLI versions and release channels, verify Claude project-skill discovery in linked worktrees, and keep skill metadata concise.

## 2026-09-24

- Added compaction snapshots, a second-brain index, fresh research comparison, deterministic upgrade suggestions, and a scheduled upgrade-review workflow.
- Added portable specialist role cards and a guarded specialist factory for UI, UX, Python, trading, and future domain-specific roles.
- Added three independent Luna xhigh research reports and a Lavish operating-system presentation.
- Expanded local checks for memory, research, upgrades, specialist boundaries, presentation integrity, and cross-agent adapter surfaces.

## 2026-09-23

- Initial agentic project starter created with shared instructions, tool adapters, workflow docs, reusable prompts, checks, and CI.
- Added local hardening, supply-chain checks, project-local learning proposals, reviewer-agent promotion guidance, and release evidence gates.
