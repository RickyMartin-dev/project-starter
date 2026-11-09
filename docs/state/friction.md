# Friction log

Append-only record of session problems and user corrections. Keep entries sanitized: no secrets, customer data, or transcripts. Add entries with `./scripts/project friction`; run `./scripts/project learn` to turn repeated areas into lesson proposals.

Entry format (one per line, parsed by tools; do not reorder fields):

`- YYYY-MM-DD | <area> | <symptom> | <cause> | <fix> | <status>`

`<area>` is a short kebab-case slug. `<status>` is `open`, `fixed`, or `lesson`.

## Log

- 2026-11-08 | secret-scan | Impeccable engine binary matched AKIA pattern and failed project check | compiled bytes match credential regex by chance | ignored binaries excluded via hardcoded paths in check-secrets.sh | lesson
- 2026-11-08 | manifest-validator | nested designSkill object rejected with generic "JSON shape is invalid" | validator accepts only flat strings and string arrays but does not say so | flattened keys | lesson
- 2026-11-08 | git-hooks | post-checkout hook failed when switching to an older commit whose checks predate local files | hook runs project start which fails hard | none yet | lesson
- 2026-11-08 | file-gate | GateGuard pre-write hook blocked first-time file creation six times | user-level ECC hook requires stated facts | retry with stated facts | lesson
- 2026-11-08 | lavish-ui | clicks on preview controls opened Lavish annotation instead of acting | decorative non-native controls without data-lavish-action | removed fakes, added data-lavish-action to theme buttons | lesson
