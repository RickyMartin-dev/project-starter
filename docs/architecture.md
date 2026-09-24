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

The starter has no application runtime or hidden orchestration service. The repository is the system of record; proposals are untrusted until the reviewer protocol promotes them.

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
| Replace me | Replace me | Replace me |

## Data flow

Describe the important inputs, transformations, side effects, and failure paths.

## Change guide

- Where new features usually start: `replace-me`
- Where validation belongs: `replace-me`
- Where integration boundaries are tested: `replace-me`
- Generated or derived files: `replace-me`

## Invariants

- `replace-me`
