# Agent Instructions

## Workflow Rules

1. **Keep CONTEXT.md and doc/ updated** — Whenever you discover new information about the project architecture, APIs, or migration challenges, update the relevant documents in `doc/architecture/`, `doc/migration-plan/`, or `doc/reference/`. Keep CONTEXT.md as the authoritative single-source-of-truth overview.

2. **Commit & push after every task/subtask** — After completing any task or meaningful subtask and after confirmed completed/solved by user:
   ```bash
   git add -A
   git commit -m "descriptive message about what was done"
   git push
   ```
   Always review `git status`, `git diff --staged`, and `git log --oneline -3` before committing. Stage only intended files. Write concise commit messages matching repo style.

3. **Maintain a full task list** — Use the `todowrite` tool to keep a structured task list. One item `in_progress` at a time. Mark completed, cancelled, or blocked items. Add follow-ups discovered during work. The todo list should cover the full migration roadmap.

4. **Keep a complete roadmap** — Track progress across all 6 migration phases. Document blockers, decisions, and rationale. When one phase completes, update the roadmap to reflect the current state and next steps.

5. **Read before editing** — Always read a file before modifying it. Never edit without first understanding its full context.

6. **Follow conventions** — Match the existing code style: no added comments unless needed, use the same patterns as neighboring code, respect the inheritance architecture.

7. **Keep docs in sync with code** — When you rename, refactor, or restructure, update the doc files to match. Stale docs are worse than no docs.

8. **Verify before declaring done** — After any migration work, verify with the Godot 4.7 binary (`/home/velteyn/.local/bin/godot47`) when possible. Run lint/typecheck if available. For test changes, verify the test logic is correct.

## Available Tools

| Tool | Path |
|------|------|
| Godot 4.7 binary | `/home/velteyn/.local/bin/godot47` |
| Godot source (4.8-dev) | `/home/velteyn/projects/godot` |
| Godot 4.7 docs | https://docs.godotengine.org/en/4.7/ |

## Key Reference Files

| File | Purpose |
|------|---------|
| `CONTEXT.md` | Main project analysis, migration context, key decisions |
| `doc/architecture/01-project-overview.md` through `09-testing-infrastructure.md` | Detailed architecture docs |
| `doc/migration-plan/migration-strategy.md` | 6-phase migration plan |
| `doc/migration-plan/godot3-apis-inventory.md` | Catalog of all Godot 3 APIs to migrate |
| `doc/reference/godot-3-vs-4-api-cheatsheet.md` | Side-by-side API conversion reference |
| `doc/reference/godot-4-7-migration-notes.md` | Godot 4.7 specific notes |
