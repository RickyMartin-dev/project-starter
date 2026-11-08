# Project Brief

This file describes the Project Starter repository. Projects created from it should tailor this brief to their own product.

## Identity

- Project name: Project Starter
- One-sentence outcome: A portable, repository-local operating system for planning, verifying, and preserving work across coding agents.
- Primary users: Software developers and teams using Codex, Claude Code, Cursor, and other repository-based coding agents.
- Current phase: maintenance

## Scope

### In scope

- Shared agent instructions and thin provider adapters.
- Portable Bash commands, reviewable Markdown workflows, project memory, and deterministic starter/security checks.
- Optional local snapshot archiving and bounded specialist role cards.

### Out of scope

- A product application, application framework, or language-specific build system.
- Hidden agent orchestration, remote memory services, automatic policy promotion, or unbounded agent spawning.
- Stack-specific dependency, runtime, and deployment checks for projects that adopt this starter.

## Success signals

- `./scripts/project check` and `./scripts/project release-check` pass from a clean checkout.
- A new agent can find the shared contract, task workflow, and verification path without replaying chat history.
- Adopting projects can replace this repository's baseline context with their product-specific commands and architecture.

## Constraints

- Runtime/platform: Bash, Git, and standard command-line tools; there is no application runtime. Python 3 is needed only for the optional snapshot archive.
- Data/privacy constraints: project memory stays in Git by default. The optional archive is local and opt-in; never store credentials, customer data, or raw transcripts.
- Availability/performance constraints: no application service or uptime target. Local checks should remain deterministic and work without network access.

## Current risks

- Starter checks are guardrails, not a complete application security assessment.
- Adopted projects must supply their own runtime, dependency, deployment, and product-specific quality model.
- Agent/provider instruction formats can change; review adapters and project skills when those tools change.
