# Architecture

Replace this file with the project's actual system map. Keep it focused on boundaries and flows that affect implementation decisions.

## Starter control plane

```text
[AGENTS.md]
      |
      +--> [Claude/Cursor adapters]
      +--> [docs/ prompts/]
      +--> [docs/state/ proposals/]
      |          |
      |          v
      |   [designated reviewer agent]
      |          |
      |          v
      +--> [reviewed durable knowledge]
      |
      +--> [local release checks] --> [CI]
```

The starter has no application runtime or hidden orchestration service. The repository is the system of record; proposals, research notes, and specialist briefs are untrusted until the relevant reviewer protocol promotes them.

## Long-lived project operating system

```text
                 +----------------------+
                 | AGENTS.md / adapters |
                 +----------+-----------+
                            |
        +-------------------+-------------------+
        |                   |                   |
        v                   v                   v
 [second-brain]       [research register]  [specialist roles]
        |                   |                   |
        v                   v                   v
 [compaction]        [comparison report]  [bounded handoff]
        \                   |                   /
         +------------------+------------------+
                            v
                  [upgrade proposal + evidence]
                            |
                            v
                  [reviewer-approved policy]
```

The second brain is deliberately a graph of Markdown documents with Git history. A future retrieval or vector layer may be adopted by a project, but it must remain an explicit, reviewable extension rather than a hidden dependency.

## System map

```text
[user or external event]
            |
            v
      [entry point]
            |
            v
   [core domain boundary]
       /           \\
      v             v
 [storage]     [external service]
```

## Boundaries

| Boundary | Owns | Must not own |
| --- | --- | --- |
| Shared contract | `AGENTS.md`, manifest, adapters | Provider-specific policy forks |
| Durable memory | `docs/`, state, compactions, decisions | Secrets, hidden external memory, unreviewed prompts |
| Research and upgrades | reports, backlog, proposals, evidence | Automatic policy edits or copied external instructions |
| Specialist factory | Markdown role cards and handoffs | Unbounded spawning, credentials, arbitrary network access |
| Hardening | portable local checks and CI | Claiming a complete application security assessment |

## Data flow

Describe the important inputs, transformations, side effects, and failure paths for the adopting application. For the starter control plane, the path is: task → plan → change → evidence → compaction/research → proposal → review → promotion.

## Change guide

- Where new features usually start: `docs/plans/active/` and the application source tree.
- Where validation belongs: `docs/project-commands.md` plus the application's native tests.
- Where integration boundaries are tested: the application's documented quality commands.
- Generated or derived files: `docs/compactions/` snapshots, research/upgrade briefs, and presentation artifacts; review before promotion.

## Invariants

- No agent-facing document outranks `AGENTS.md` and explicit task scope.
- Every durable learning change has evidence, a reviewer, and a rollback path.
- Project-specific runtime and domain rules stay in project docs, not the universal starter contract.
