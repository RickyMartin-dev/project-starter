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
8. Complete: move the plan to `docs/plans/completed/` and update the changelog when the project uses one.

The detailed contract is in [`docs/agent-workflow.md`](docs/agent-workflow.md). The template is designed for a human to remain the decision-maker while agents handle bounded, reviewable execution.

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
