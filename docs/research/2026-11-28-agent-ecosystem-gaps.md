# Research report: Compare this repository's low-setup, repository-local learning and improvement workflow against current official coding-agent repository guidance; identify adoption gaps, token/setup friction, and safe capability gaps that could limit portable learning across agents.

- Checked: 2026-11-28
- Researcher: Codex (with an independent cold-read review)
- Status: reviewed
- Recheck trigger: a material change to provider skill/instruction discovery, a new adoption workflow, or a project evaluation baseline

## Question and scope

Whether the repo's current structure is aligned with low-context, portable coding-agent workflows, and which local improvements should be prioritized without adding hidden authority or hosted dependencies. Sources were checked against official vendor or standards-project documentation; they inform the review but do not override repo policy.

## Sources

- [Rethinking skills and prompts for GPT-6 Astra](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) — checked 2026-11-28; recommends revisiting always-loaded repository instructions and placing detailed, task-specific procedures in skills.
- [Using skills to accelerate OSS maintenance](https://developers.openai.com/blog/skills-agents-sdk) — checked 2026-11-28; describes short `AGENTS.md` policy with repo-local skills and progressive disclosure for repeatable workflows.
- [Testing Agent Skills Systematically with Evals](https://developers.openai.com/blog/eval-skills) — checked 2026-11-28; recommends small end-to-end task sets scored for activation, process, outcome, cleanliness, and efficiency including token usage.
- [Agent Skills donated to the Agentic AI Foundation](https://www.anthropic.com/news/donating-agent-skills-to-the-agentic-ai-foundation) — checked 2026-11-28; confirms the folder-based skill format is an open, vendor-neutral standard stewarded by AAIF.
- [Agent Skills specification and documentation](https://github.com/agentskills/agentskills) — checked 2026-11-28; describes discovery/activation/execution through progressive disclosure.
- [GitHub Actions workflow commands](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands) — checked 2026-11-28; documents `GITHUB_STEP_SUMMARY` as the run summary surface for Markdown output.

## Comparison

| Criterion | Current repo | Official practice | Project implication |
| --- | --- | --- | --- |
| Always-loaded context | One shared `AGENTS.md` (73 lines) points into task-specific docs, prompts, and skills. | Keep recurring policy concise; avoid loading a full repo map for trivial tasks. | Direction is sound; explicitly open generated start context and keep routine setup fast. |
| Reusable skills | Codex, Claude Code, and Cursor contain Impeccable; project-logic refresh is copied for Codex and Claude Code. | Skills package procedural guidance and optional resources; common format supports reuse, while invocation remains client-specific. | File layout is portable, but provider discovery and behavior are not proven by shell checks alone. |
| Memory | Sanitized lexical recall over a bounded set of Git subjects and canonical Markdown; durable notes remain local and reviewable. | Repository-local context can preserve decisions and institutional knowledge without a remote service. | Good low-infrastructure fit. Retrieval is not model training and does not guarantee a better result. |
| Improvement loop | Friction, lessons, research, upgrades, and weekly deterministic suggestions; protected changes require review. | Repeatable workflows benefit from task-grounded evaluation, not intuition alone. | Governance is mature; quality, time, setup effort, and token cost are not yet measured in real agent runs. |
| Adoption | README says “copy or merge”; no installer or conflict resolver exists. | Keep setup scoped to the user's target repo, and keep specialized procedures opt-in. | Manual merge is safe but leaves meaningful setup burden; document conflicts and preserve project history. |
| Periodic review | Weekly Action previously printed JSON only to the log. | A job summary can surface concise results on the run page. | This pass now writes a visible `GITHUB_STEP_SUMMARY`, without adding write permissions. |

## Recommendation

Keep the local, reviewable memory model and evidence gates. Keep the shared instruction map short and load detailed procedures only for matching tasks. Improve the session boundary by making agents read the generated context, separating fast `start` checks from full hardening checks, preserving user-owned Git hooks, and showing evidence-backed suggestions in the weekly workflow summary. Do not add remote memory, automatic policy changes, or model-training claims.

Defer a one-command installer until it can safely handle existing instruction files, CI, hooks, provider settings, and project history. Define a small real-task baseline first so any installer or learning change can be scored for time, context tokens, verified outcomes, and regressions.

## Risks and trust review

- Secrets or credentials introduced: no
- Untrusted text treated as policy: no
- Authority, permissions, or network expanded: no

## Follow-up evidence

- `./scripts/project check` — validates the starter contract and local hardening fixtures.
- `./scripts/project release-check` — runs the full pre-push gate, including untracked whitespace.
- For a future adoption/effectiveness study: apply the starter to one non-empty test repo with pre-existing `AGENTS.md`, Git hooks, and CI; record preserved files, setup time, per-task context tokens, and verified outcomes over a small matched task set.

## Research limits

- Official guidance describes supported formats and recommended workflows; it does not independently validate this repository's behavior on every current agent version.
- No production or external agent sessions were run. The comparison is based on this repository's source and current official docs.
- Quantifying learning benefit requires a baseline and real task runs; this pass cannot infer it from the presence of logs, skills, or checks.
