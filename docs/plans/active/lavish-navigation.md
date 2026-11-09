# Plan: Restore walkthrough section jumps and verify Lavish annotations

- Owner: Codex
- Created: 2026-11-08
- Status: complete
- Scope: Restore functional section links in Lavish review surfaces and confirm annotation remains available.

## Goal

Lavish section links navigate to their target sections instead of opening the annotation composer, while body text remains annotatable in the review overlay.

## Non-goals

- Replacing Lavish's review overlay or changing annotation workflow behavior.

## Assumptions and decisions needed

- Add Lavish's `data-lavish-action` marker to real section links so the overlay lets their native hash navigation through.
- Apply the contract to existing static review pages and generated retrospectives.

## Steps

- [x] Mark all section-nav anchors as Lavish actions; update generated retrospectives.
- [x] Extend design checks and fixtures to catch unmarked nav links.
- [x] Verify hash/scroll navigation and body-text annotation in the open Lavish session.
- [x] Run the release gate, finish the task, and push to `origin/main`.

## Acceptance criteria

- [x] Each section link jumps to its target in Lavish; ordinary content still opens annotation; checks pass and changes are pushed to `origin/main`.

## Verification

```bash
./scripts/project release-check
./scripts/project finish --summary "Fixed Lavish section navigation and verified annotations"
git diff --check HEAD --
```

## Results

- Added `data-lavish-action` to the five section links in each existing Lavish surface and in generated retrospectives.
- Added hardening fixtures so the design check rejects unmarked section links and automation confirms the generated output.
- Live Lavish checks: Flow, Map, Checks, Findings, and Status each changed to the matching hash and scrolled to the target. Clicking a content heading opened the annotation composer; the test draft was canceled without queueing.
- `./scripts/project release-check` passed.

## Risks and recovery

- If a future static Lavish surface adds section links, the design check now fails until those links carry `data-lavish-action`; generated retrospectives are covered by the automation fixture.
