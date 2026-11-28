# Agent capabilities in a fresh checkout

This inventory describes files present in a fresh repository checkout. Invocation details can vary by agent version; the shared source of truth remains `AGENTS.md`, `docs/`, and `prompts/`.

## Repository skills

| Capability | Codex | Claude Code | Cursor | What it does |
| --- | --- | --- | --- | --- |
| Project logic refresh | `.agents/skills/update-project-logic/` → `$update-project-logic` | `.claude/skills/update-project-logic/` → `/update-project-logic` | No dedicated project-logic skill copy | Refreshes verified project context, reviews workflow/security improvements, and researches current agent practice. |
| Impeccable | `.agents/skills/impeccable/` → `$impeccable` | `.claude/skills/impeccable/` → `/impeccable` | `.cursor/skills/impeccable/` → `/impeccable` | UI/design direction, audits, polish, accessibility, responsive design, and optional edit hooks. |

The Impeccable skill is bundled in all three provider directories. Its detector binary is downloaded on first use and is gitignored; core Project Starter commands do not need that binary. Claude and Cursor settings configure the design hook, so review the provider-specific hook settings before adopting them in a repository with custom settings.

## Shared workflow commands

Claude Code and Cursor ship command adapters for:

`/autopilot` · `/compact` · `/learn` · `/plan` · `/present` · `/promote` · `/research` · `/review` · `/specialist` · `/upgrade` · `/verify`

Each adapter points to the shared prompt under `prompts/`. Codex users can open those prompt files or use the matching CLI command. Other coding agents can follow `AGENTS.md` and the same Markdown workflows without installing a plugin.

## Role cards and visual tools

- `agents/roles/` contains bounded UI, UX, Python, and trading role cards; `prompts/factory.md` and `./scripts/project specialist` help draft a project-specific role for review. These are briefs for an agent harness, not automatic permission to spawn an agent.
- `.lavish/` contains local HTML examples and a reusable theme. The `lavish-axi` CLI, annotation UI, and editor service are external and are not installed by a fresh checkout.
- `impeccable` is bundled as a repository skill; its first detector run may download a platform binary. It is separate from Lavish.

## Context and setup cost

The core operating system needs Bash, Git, and common shell tools; it installs no application runtime or service. `./scripts/project start` creates ignored local state and performs the fast file/syntax/whitespace check. `./scripts/project check` and `./scripts/project release-check` run the deeper local hardening fixtures. Python is needed only for the optional shared snapshot archive.

Task memory is repository Markdown and Git history retrieved lexically with a fixed result bound. The system does not train or modify the coding model. It makes project evidence easier to recover and review.
