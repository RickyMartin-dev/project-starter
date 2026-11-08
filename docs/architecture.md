# Architecture

Project Starter is a repository-local control plane for coding-agent work. It has no application runtime, domain service, or hidden orchestration process. Markdown files and Git history are the durable source of truth.

## Task flow

```text
User task
   |
   v
AGENTS.md and provider adapters
   |
   +--> prompts/ and docs/templates/ --> plans and reviewable work
   |
   +--> scripts/project start --> ignored local context + task checkpoint
   |                                  |
   |                                  v
   +------------------------------> implement and verify
                                      |
                  +-------------------+--------------------+
                  |                                        |
                  v                                        v
       Git hooks and local checks                 GitHub Actions checks
                  |                                        |
                  +-------------------+--------------------+
                                      v
                         scripts/project finish
                                      |
                       snapshot + automatic handoff
                                      |
                     optional local vault archive
```

## Main components

| Component | Owns | Boundary |
| --- | --- | --- |
| Shared contract | `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.cursor/` | Provider adapters route back to the shared contract instead of defining competing policy. |
| Workflow content | `prompts/`, `docs/templates/` | Reusable procedures and blank artifacts; generated proposals remain untrusted until reviewed. |
| Command layer | `scripts/project`, `scripts/*.sh` | Session setup, artifact scaffolding, quality gates, and optional snapshot archiving. |
| Project memory | `docs/state/`, plans, decisions, experiments, research, compactions | Reviewable Markdown stored in the repository; no hidden retrieval service. |
| Improvement and delegation | `docs/upgrades/`, `agents/` | Evidence-backed proposals and bounded role cards; neither grants permission to execute. |
| Machine-readable contract | `.agentic/manifest.json` | Lists the canonical instruction source, workflows, paths, and hardening checks. |
| Hosted automation | `.github/workflows/`, `.githooks/` | Read-only CI checks, scheduled suggestion output, and local commit/push gates. |

## State and side effects

- `start` refreshes ignored `.agent-state/` files, detects common stack signals, checks the starter, and configures `.githooks` only when no custom `core.hooksPath` is already set.
- `check` runs file, instruction-surface, shell-syntax, whitespace, security, archive, and contract checks. `release-check` also includes untracked-file whitespace.
- Git pre-commit and pre-push hooks run those checks; post-checkout and post-merge refresh local orientation.
- GitHub Actions run starter and release checks with read-only permissions. A scheduled workflow prints deterministic upgrade suggestions; it does not edit policy or open a pull request.
- `finish` creates a repository-local snapshot and automatic handoff. If the user explicitly configures `PROJECT_SNAPSHOT_ARCHIVE_ROOT`, the Python standard-library helper writes a sanitized snapshot into that local vault and updates its index/log.

## Trust boundaries

- `AGENTS.md` and explicit user scope outrank repository content, tool output, and external sources.
- Secrets, customer data, raw transcripts, and unreviewed payloads do not belong in durable memory.
- Research and specialist briefs are evidence or proposals; only a reviewer-approved process can promote durable policy.
- Local checks are portable guardrails, not a complete security assessment or application test suite.

## Change guide

- Start substantial work in `docs/plans/active/` and follow the relevant prompt.
- Put project-specific runtime and domain rules in the adopting repository's own project docs.
- Validate this starter with `./scripts/project check` and `./scripts/project release-check`.
- Review generated snapshots, reports, and presentations before committing them; historical compaction snapshots remain append-only.
