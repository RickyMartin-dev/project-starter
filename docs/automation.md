# Low-friction automation

The default path is intentionally automatic. A user should be able to focus on the product while the active coding agent keeps orientation, local context, verification, and handoff artifacts current.

## What happens automatically

At the start of a substantive agent session, the agent runs:

```bash
./scripts/project start --task "the user's request"
```

This command is idempotent and local-only. It:

- detects common language, package, build, test, and source signals without installing anything;
- refreshes `.agent-state/session-context.md`, which is ignored machine-local context;
- installs the repository's project-local Git hooks;
- checks the starter contract;
- surfaces deterministic upgrade suggestions;
- searches Git commit subjects and canonical project Markdown for up to five task-related history matches and writes sanitized snippets into local context.

The history search is lexical and deliberately bounded. It does not search raw transcripts, `.agent-state/`, ignored `resources/`, external services, or non-project repositories. Results are historical evidence, not current instructions. Run `./scripts/project recall "<query>" [--limit 1-10]` for an explicit search.

At the end of a meaningful session, the agent runs:

```bash
./scripts/project finish --summary "short outcome"
```

This command:

- records a sanitized learning review in the ignored checkpoint and durable snapshot;
- imports validated pending friction records through the same guarded write path; malformed entries and legacy general lessons stay queued for review;
- groups repeated friction into proposals;
- records an explicitly marked `correction` immediately, or a general `lesson` only after two distinct task snapshots and successful verification; general lessons run their enforcing check before recording;
- creates the missing retrospective for the previous calendar month when that month has project records;
- runs the starter and release checks;
- creates an automatic compaction snapshot under `docs/compactions/`;
- updates `docs/state/automatic-handoff.md`;
- records only sanitized, repository-local facts;
- leaves all policy, credential, permission, and external-side-effect decisions reviewable.

Each start also creates `.agent-state/second-brain-checkpoint.md`, an ignored local note for the active task. Keep it current at meaningful milestones so a compaction hook can preserve the latest project context without reading or copying the agent transcript. Explicit standing user corrections use the `correction` marker and may become lessons immediately. General `lesson` records require two distinct existing task snapshots, cited successful verification, and an enforcing check that passes before recording, or a written reason none can be added. Automatic grouping drafts proposals but does not itself curate lessons. No-op is valid.

Automatic snapshots use the checkpoint's `Open work and next action` entry. If it is missing or still a template placeholder, the snapshot points the next agent to review active plans and upgrade suggestions.

## Optional shared second brain

Projects may mirror snapshots to a user-selected local vault. This feature is opt-in and disabled when `PROJECT_SNAPSHOT_ARCHIVE_ROOT` is unset. When configured, `finish` copies the generated task snapshot to `raw/project-snapshots/<project>/` and adds a catalog entry to `wiki/index.md` and `wiki/log.md` when those files exist. Other vault layouts receive the snapshot files under the same archive folder and can index them with their own conventions.

Manual task snapshot command:

```bash
PROJECT_SNAPSHOT_ARCHIVE_ROOT="/path/to/your/vault" \
  ./scripts/project archive-snapshot --agent codex --summary "short verified outcome"
```

Codex and Claude Code can also use user-level compaction hooks to capture checkpoints. Configure those hooks in the agent's user settings; do not put a personal vault path in a shared project. Claude's post-compaction hook can archive its supplied compact summary. Codex's compaction item is opaque to hooks, so its pre-compaction hook archives the agent-maintained checkpoint instead.

Archive failures are retried once and reported as warnings. They never fail `finish` or block a compaction; the agent should retry at the next safe point. Snapshots contain summaries and repository facts, not raw agent transcripts.

The generated local context is deliberately ignored so routine orientation does not dirty the worktree. Automatic compaction and handoff records are durable Git artifacts because they are part of the project's second brain.

## Agent adapter behavior

`prompts/autopilot.md` is the shared operating instruction. Codex uses `AGENTS.md`; Claude Code and Cursor expose `/autopilot`. The adapters all point to the same contract so switching tools does not fork the workflow.

The agent should not ask the user to manually maintain routine project-management files. It should do the following automatically:

1. orient and detect the repository;
2. plan only when the task is larger than a trivial change;
3. implement the user's requested work;
4. run the documented project checks plus starter checks;
5. capture a compaction snapshot and handoff;
6. surface only decisions that genuinely require owner authority.

## Project logic refresh

Use the repo skill when the user asks for a freshness review, after a meaningful architecture or agent-harness change, or when a workflow failure repeats:

- Claude Code: `/update-project-logic`
- Codex: `$update-project-logic`

When using Claude Code from a linked worktree, verify that the installed version discovers the main checkout's `.claude/skills/`; skill discovery is version-sensitive.

The skill reconciles verified project learning with canonical docs and relevant provider skills/hooks, audits code/process/security improvements, and checks current official AI-development guidance. It records dated research when evidence changes, reports the few highest-value improvements plainly, and leaves application behavior, global configuration, permissions, dependencies, production actions, and protected policy changes behind existing approval gates. The local finish loop records standing corrections and evidence-backed project lessons; it does not train a model or run on a schedule. Invoke the freshness review at those milestones.

## What remains intentionally gated

Automation does not grant an agent hidden credentials, unrestricted network access, production authority, automatic policy promotion, or unbounded specialist spawning. Those actions are high-impact and require explicit project-owner approval. Agents can draft and verify the supporting artifacts automatically.

## Recovery

If an agent forgets the loop, run:

```bash
./scripts/project start
./scripts/project finish --summary "recovered the session workflow"
```

The latest durable resume point is always `docs/state/automatic-handoff.md`, followed by the newest file in `docs/compactions/`.
