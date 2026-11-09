# Product

Project Starter is a portable, repository-local operating system for planning, verifying, and preserving work across coding agents. Projects created from this starter should rewrite this file for their own product (`/impeccable init`).

## Platform

web (static HTML review surfaces under `.lavish/`, opened with `lavish-axi`)

## Stack

Markdown, Bash, and plain HTML/CSS. No application framework or build step. Lavish pages share `.lavish/theme.css` and `.lavish/theme.js`.

## Users

Software developers and teams using Codex, Claude Code, Cursor, and other repository-based coding agents. They read Lavish reports at a desk, often beside an editor, to review plans, walkthroughs, and findings before deciding what to do next.

## Product Purpose

Make agent work recoverable and reviewable: a shared contract, durable project memory, repeatable task commands, and portable quality checks. Visual reports explain that work; they never replace the repository as the source of truth.

## Positioning

A calm, trustworthy workbench, not a dashboard of agent theatrics. Reports should read like a well-made product page from a company that sweats details.

## Operating Context

Reports are opened locally in a browser, in light or dark system appearance, at laptop and desktop widths, sometimes on a phone. Readers scan for decisions, risks, and next actions, then return to the code.

## Capabilities and Constraints

- Pages must render without a server or network: local assets only, no CDN runtime.
- Every claim links back to a repository file; presentations are a communication layer.
- `scripts/check-presentation.sh` requires specific phrases in each report; keep them when editing.

## Brand Commitments

Owner brief (2026-11-08): polished and pristine like an Apple product. Light mode is white and blue with a slight pink gradient; dark mode is black with blue accents and a slight pink gradient. Clean above all.

## Evidence on Hand

No logo or imagery. Content comes from `AGENTS.md`, `docs/`, `scripts/`, and `.agentic/manifest.json`.

## Product Principles

- Restraint over decoration: one accent, generous space, hairline structure.
- Evidence over claims: show the flow, the file, the check.
- Both appearances are first-class; neither is an afterthought.

## Accessibility & Inclusion

WCAG 2.2 AA contrast in both appearances, visible keyboard focus, semantic headings and tables, labelled SVG diagrams, and `prefers-reduced-motion` respected.
