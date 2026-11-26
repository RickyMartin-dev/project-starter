# Friction log

Append-only record of session problems and user corrections. Keep entries sanitized: no secrets, customer data, or transcripts. Add entries with `./scripts/project friction` or `finish --friction`; finish runs the grouping step automatically. Use status `correction` for an explicit standing correction, or `lesson` for a general procedure that meets the evidence and verification criteria in `prompts/learn.md`; either marker also writes a durable entry to `docs/lessons.md`.

Entry format (one per line, parsed by tools; do not reorder fields):

`- YYYY-MM-DD | <area> | <symptom> | <cause> | <fix> | <status>`

`<area>` is a short kebab-case slug. `<status>` is `open`, `fixed`, `correction`, or `lesson`. A `correction` is an explicit standing user correction and may be recorded immediately. A general `lesson` requires two distinct existing task snapshots, a successful verification citation in its cause, and an enforcing `scripts/*.sh` check or justified `none: ...` reason. Repeated friction is grouped into proposals and does not qualify as a lesson by itself.

## Log

- 2026-11-08 | secret-scan | Impeccable engine binary matched AKIA pattern and failed project check | compiled bytes match credential regex by chance | ignored binaries excluded via hardcoded paths in check-secrets.sh | lesson
- 2026-11-08 | manifest-validator | nested designSkill object rejected with generic "JSON shape is invalid" | validator accepts only flat strings and string arrays but does not say so | flattened keys | lesson
- 2026-11-08 | git-hooks | post-checkout hook failed when switching to an older commit whose checks predate local files | hook runs project start which fails hard | none yet | lesson
- 2026-11-08 | file-gate | GateGuard pre-write hook blocked first-time file creation six times | user-level ECC hook requires stated facts | retry with stated facts | lesson
- 2026-11-08 | lavish-ui | clicks on preview controls opened Lavish annotation instead of acting | decorative non-native controls without data-lavish-action | removed fakes, added data-lavish-action to theme buttons | lesson
- 2026-11-24 | finish-snapshot | snapshot claimed release verification before it ran | finish created and archived the snapshot before running release-check | run both checks before snapshot creation and record their outcomes | fixed
- 2026-11-25 | pr-readiness | review exposed unsafe pending queue writes and duplicate correction retries | pending imports bypassed destination/read checks and keyed lessons to the current date | preflight and validate queue reads, retain unsupported entries, and deduplicate corrections by source date | fixed
- 2026-11-25 | no-mistakes-agent | fix agent stopped at the review gate | configured Claude agent reached its five-hour usage limit | applied the approved scanner and citation fixes locally and reran checks | fixed
- 2026-11-26 | test-agent-timeout | Test agent reached its 30-minute invocation limit before completing live scenarios | Pipeline had no configured test command and delegated broad validation to an agent | Evaluate a deterministic repository test command and keep live agent validation targeted | open
- 2026-11-26 | agent-efficiency | User wants project workflows to be token-efficient and automated | A broad live validation agent ran for 30 minutes before direct checks were used | Automate deterministic project checks and avoid repeating broad validation runs | correction
