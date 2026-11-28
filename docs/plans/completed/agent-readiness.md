# Plan: Low-friction agent operating system: repo understanding, gap fixes, and readiness report

- Owner: Codex
- Created: 2026-11-28
- Status: complete
- Scope: Trace the starter's onboarding, memory, learning, skills, and improvement paths; fix actionable friction without replacing user files or expanding agent authority; publish a browser-ready report under `resources/`.

## Goal

Give the repository owner an evidence-backed read on whether this project behaves like a low-token, low-setup, low-stress agent learning layer, fix concrete gaps found in its own workflows, and summarize remaining limitations in an HTML report.

## Non-goals

- Add model training, a hosted memory service, autonomous policy promotion, or broader agent permissions.
- Replace or rewrite a user's existing Git hooks.
- Claim measurable agent-quality improvement without project-specific evaluation data.

## Assumptions and decisions needed

- Preserve all existing user files and hook paths by default.
- Keep first-run work local and dependency-free; reserve the full hardening suite for explicit checks and finish.
- Treat generated history as evidence that an agent must read and reassess, never as instructions.
- Keep the HTML report tracked in the requested `resources/` location while leaving unrelated local resources ignored.

## Steps

- [x] Trace repo contract, commands, adapters, skills, memory, learning, CI, and design resources; get a separate cold-read audit.
- [x] Start a dated research brief and compare current official agent guidance.
- [x] Make session context explicit in the root agent contract.
- [x] Make `start` fast and preserve pre-existing native Git hooks in normal and linked worktrees.
- [x] Remove unsupported generic upgrade noise and show weekly findings in GitHub Actions summaries.
- [x] Clarify the safe existing-repo adoption path and list every skill/capability honestly.
- [x] Write the researched readiness report in `resources/` and append remaining gaps at the end.
- [x] Run documented quality gates, review the diff, finish the task, and archive a sanitized snapshot.

## Acceptance criteria

- First-run `start` avoids release-only fixture work and leaves user hooks untouched.
- Agents are directed to read the bounded generated context; suggestions appear only when supported by evidence.
- Weekly suggestions are visible in the Actions run summary.
- Existing-repo instructions explain conflicts and distinguish bundled skills from external tools.
- The HTML report explains purpose, architecture, efficient usage, skills, verification limits, completed fixes, and open gaps with source links.
- Full starter and release checks pass; local browser review confirms section navigation and light/dark rendering. The available full-width browser window prevented a narrow-viewport visual check.

## Verification

```bash
./scripts/project check
./scripts/project release-check
git diff --check
```

## Risks and recovery

- A faster `start` could hide a broken deep invariant; keep the complete starter and release gates unchanged and run them at finish.
- Changing suggestion defaults can affect scripts that expect optional setup reminders; update and run the contract fixtures.
- Never change a configured or active native hook path automatically; report that starter hooks remain available for explicit review.
- Linked worktrees use shared Git hook storage. The CLI now checks Git's resolved hook path and leaves shared hook configuration untouched when no hook path is configured there.
