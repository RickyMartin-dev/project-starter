# Add Project Starter to an existing repository

Project Starter has no package installer. Its shared contract touches root instructions, local state, Git hooks, provider settings, and GitHub workflows, so merge it with a diff rather than copying over a working repository.

## Safe merge

1. Start with a clean working tree or make a branch that can be reverted.
2. Download or clone Project Starter beside the target repository. Compare the two trees before copying files.
3. Add the shared `scripts/`, `prompts/`, `docs/templates/`, `.agentic/`, and `agents/` content. Add provider skill and command folders only for the agents you use.
4. Merge root `AGENTS.md` and `README.md` with existing content. Keep one shared instruction source and link adapters back to it.
5. Merge `.gitignore`, `.githooks/`, `.claude/settings.json`, `.cursor/`, and `.github/workflows/` by hand. Preserve custom hook paths, existing executable hooks, user-local settings, permissions, and CI jobs. `start` detects native hooks through linked-worktree metadata and avoids changing shared hook configuration there when no hooks are installed.
6. Keep the starter's general templates and indexes. Do not copy its task-specific `docs/compactions/`, active/completed plans, state logs, retrospectives, or verification history into the adopting project's memory; those are records from this repository.
7. Replace `docs/project-brief.md`, `docs/project-commands.md`, and `docs/architecture.md` with the target project's facts and clean-checkout checks.
8. Run `./scripts/project start --task "<first real task>"`, read `.agent-state/session-context.md`, then run `./scripts/project check` and add the application's own checks to its CI.

`start` will not edit or infer product documentation. It only reports common stack signals and bounded local history. The starter's full checks validate this operating system's files and fixtures; they do not test the adopting application's behavior.

## Optional capabilities

- Add `.agents/skills/` for Codex-compatible repo skills.
- Add `.claude/skills/` and `.claude/commands/` for Claude Code; keep shared commands linked to `prompts/`.
- Add `.cursor/skills/` and `.cursor/commands/` for Cursor.
- Add `.claude/settings.json` and `.cursor/hooks.json` only after reviewing their hook behavior. Impeccable's design detector downloads a local binary on first use.
- Lavish review pages can be opened as static HTML. Annotation requires the separate `lavish-axi` tool and local editor service.

There is no automated overlay installer or conflict resolver yet. The steps above are the supported low-risk path; building an installer is a remaining improvement because safe adoption has to preserve project-specific authority and automation.
