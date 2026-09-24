# Project Starter

An opinionated, language-agnostic foundation for building software with Codex, Claude Code, Cursor, and other agentic coding tools in the same repository.

The starter keeps the shared contract small, puts durable project knowledge in predictable documents, and makes planning, verification, review, and learning repeatable. It is intentionally not an application framework: bring your own language, runtime, and product idea.

## What this gives you

- A short `AGENTS.md` map that works as the shared starting point for agent sessions.
- A portable `CLAUDE.md` adapter and scoped `.cursor/rules/` and `.cursor/commands/` adapters.
- A durable documentation system for architecture, plans, decisions, quality, security, and lessons.
- Reusable prompts and task templates for plan → implement → verify → review → learn loops.
- A dependency-free `scripts/project` command for orientation, plan creation, and starter checks.
- Local hardening checks for secrets, workflow supply chain, instruction drift, prompt injection, manifest integrity, and learning proposals.
- A project-local memory and upgrade loop that lets a reviewer agent promote evidence-backed improvements without global memory or hidden orchestration.
- Compaction snapshots and a second-brain index so full project context survives long sessions and model switches.
- Fresh research comparisons, deterministic upgrade suggestions, and bounded specialist role cards for UI, UX, Python, trading, and any project-specific domain.
- A committed Lavish presentation that makes the operating system easy to review visually.

## Quick start

```bash
git clone https://github.com/RickyMartin-dev/project-starter.git my-project
cd my-project

# Make the shared project identity yours.
$EDITOR docs/project-brief.md
$EDITOR AGENTS.md

# Confirm the starter is internally consistent.
./scripts/project check

# Run the full local pre-push gate.
./scripts/project release-check

# Capture durable context before a long session or compaction.
./scripts/project compact first-handoff "First project handoff"

# Research, propose, and route improvements without hidden authority.
./scripts/project research first-comparison "What should this project borrow from current practice?"
./scripts/project suggest-upgrades
./scripts/project specialist domain-role "Project domain specialist"

# Start the first piece of real work.
./scripts/project plan first-feature "First feature"
```

For an existing clean repository, copy or merge this starter into the repository and then customize `docs/project-brief.md`, `AGENTS.md`, and the commands under `docs/project-commands.md`.

## The operating loop

1. Orient: read `AGENTS.md`, `docs/project-brief.md`, the relevant architecture docs, and the active plan.
2. Plan: write a small, testable plan under `docs/plans/active/`.
3. Implement: make the smallest coherent change and keep the plan current.
4. Verify: run the repository's checks plus `./scripts/project check`.
5. Review: inspect the diff for correctness, security, regressions, and unnecessary complexity.
6. Learn: record durable decisions and lessons so the next agent starts smarter.
7. Promote: have the designated reviewer agent validate a learning proposal before changing shared policy.
8. Compact: snapshot facts, decisions, evidence, risks, and next actions before context compaction or handoff.
9. Research: compare fresh external practice and record what to adopt, defer, or reject.
10. Upgrade: create a bounded proposal, verify it, and promote only the smallest safe improvement.
11. Complete: move the plan to `docs/plans/completed/` and update the changelog when the project uses one.

The detailed contract is in [`docs/agent-workflow.md`](docs/agent-workflow.md). The template is designed for a human to remain the decision-maker while agents handle bounded, reviewable execution.

The long-lived operating system is described in [`docs/operating-system.md`](docs/operating-system.md). The second-brain index is [`docs/second-brain/README.md`](docs/second-brain/README.md), and compaction snapshots live in `docs/compactions/`.

Use [`docs/learning-path.md`](docs/learning-path.md) to grow autonomy in stages: baseline → continuity → evidence → research → specialists → governed learning → measured autonomy.

## Using different agents in one repository

| Tool | Shared entry point | Native extras in this starter |
| --- | --- | --- |
| Codex | `AGENTS.md` | Nested `AGENTS.md` files may scope local conventions. |
| Claude Code | `CLAUDE.md` → `@AGENTS.md` | `.claude/commands/` mirrors reusable workflows. |
| Cursor | `AGENTS.md` plus `.cursor/rules/` | `.cursor/commands/` exposes slash commands. |
| Other agents | `README.md`, `docs/`, and `prompts/` | Use the same plan and verification contract. |

Keep the shared source of truth in `AGENTS.md` and `docs/`. Native adapter files should point to that source, not fork it into competing rulebooks.

## Project-local learning

Each project keeps its own durable state under `docs/state/`. Agents may propose lessons, experiments, risks, and upgrade ideas under `docs/state/proposals/`. The designated reviewer agent uses `prompts/promote.md` to check evidence, scope, rollback, secrets, and trust boundaries before applying a promotion. This is repository-local learning, not automatic model retraining or a shared external memory service.

## Research, upgrades, and specialist agents

Use [`docs/research/README.md`](docs/research/README.md) to create dated comparisons and [`docs/upgrades/README.md`](docs/upgrades/README.md) to turn evidence into a bounded backlog. `./scripts/project suggest-upgrades --json` provides repeatable signals; it never edits policy by itself.

Specialists are portable Markdown role cards under [`agents/`](agents/). The factory prompt can draft a UI, UX, Python, trading, or domain-specific role, but a reviewer must approve scope and evidence before delegation. This keeps “agents that create agents” safe and portable across runtimes rather than hiding a provider-specific supervisor in the starter.

For a visual walkthrough, open [`docs/presentations/README.md`](docs/presentations/README.md) and launch the committed Lavish artifact.

## First customization pass

1. Replace the placeholders in [`docs/project-brief.md`](docs/project-brief.md).
2. Add the real stack commands to [`docs/project-commands.md`](docs/project-commands.md).
3. Describe the actual modules and boundaries in [`docs/architecture.md`](docs/architecture.md).
4. Add project-specific rules in the nearest directory instead of expanding the root map indefinitely.
5. Replace or extend the generic CI check in `.github/workflows/quality.yml` with the project's real build, lint, typecheck, and test commands.

## Design principles

- Small context beats a giant instruction manual.
- Plans and decisions are artifacts, not chat history.
- Every agent change has a verification path.
- Parallel work requires isolation and explicit ownership.
- Generated knowledge must be labeled and reviewed before it becomes durable.
- Tool-specific conveniences are adapters; the repository contract stays portable.
- Durable memory is project-specific, evidence-backed, and explicitly promoted.

## Research behind the structure

See [`docs/research/agentic-starter-repos.md`](docs/research/agentic-starter-repos.md) for the repository patterns that informed this template, including firstmate, Karpathy's autoresearch, Codex's repository guidance, and Cursor's rules and commands model.

## License

MIT. See [`LICENSE`](LICENSE).
