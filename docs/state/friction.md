# Friction log

Append-only record of session problems and user corrections. Keep entries sanitized: no secrets, customer data, or transcripts. Add entries with `./scripts/project friction` or `finish --friction`; finish runs the grouping step automatically. Use status `lesson` for an explicit standing correction or a general procedure that meets the evidence and verification criteria in `prompts/learn.md`; lessons are also written to `docs/lessons.md`.

Entry format (one per line, parsed by tools; do not reorder fields):

`- YYYY-MM-DD | <area> | <symptom> | <cause> | <fix> | <status>`

`<area>` is a short kebab-case slug. `<status>` is `open`, `fixed`, or `lesson`. For general lessons, `finish --friction` accepts a sixth field containing the enforcing check; include evidence from two distinct task records and successful verification in the cause. Repeated friction is grouped into proposals, while a lesson requires the evidence and verification rules in `prompts/learn.md`.

## Log

- 2026-11-08 | secret-scan | Impeccable engine binary matched AKIA pattern and failed project check | compiled bytes match credential regex by chance | ignored binaries excluded via hardcoded paths in check-secrets.sh | lesson
- 2026-11-08 | manifest-validator | nested designSkill object rejected with generic "JSON shape is invalid" | validator accepts only flat strings and string arrays but does not say so | flattened keys | lesson
- 2026-11-08 | git-hooks | post-checkout hook failed when switching to an older commit whose checks predate local files | hook runs project start which fails hard | none yet | lesson
- 2026-11-08 | file-gate | GateGuard pre-write hook blocked first-time file creation six times | user-level ECC hook requires stated facts | retry with stated facts | lesson
- 2026-11-08 | lavish-ui | clicks on preview controls opened Lavish annotation instead of acting | decorative non-native controls without data-lavish-action | removed fakes, added data-lavish-action to theme buttons | lesson
- 2026-11-24 | finish-snapshot | snapshot claimed release verification before it ran | finish created and archived the snapshot before running release-check | run both checks before snapshot creation and record their outcomes | fixed
