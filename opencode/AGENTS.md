# Global operating rules

## Execution

- Build is the lead. It owns planning, integration, shared files, tests, and the final answer.
- Prefer direct work for small tasks. Delegation is optional, not mandatory.
- For substantial tasks, inspect first, then make bounded changes, inspect the diff, and verify.
- Do not commit unless the user explicitly asks.
- **Never `git push` without asking first, every time.** Approval of one
  push (or an instruction to open a PR) is not standing permission for
  later pushes — including pushes to a branch that already has a PR.
  Ask, wait for a yes, then push.
- Preserve unrelated working-tree changes.
- Never claim success without listing the checks actually run.

## Delegation graph

Build may invoke only:

- `@explore` for narrow, read-only repository discovery.
- `@specialist-frontend` for bounded frontend implementation.
- `@specialist-backend` for bounded backend, database, or API implementation.

Rules:

- Maximum three live child tasks.
- Use at most one frontend and one backend implementation task per phase.
- Every delegated task must name its objective, owned files or subsystem, forbidden shared files, and required checks.
- All subagents are terminal workers. They cannot invoke another agent.
- Do not create an agent merely to review another agent. Build reviews child results directly.
- Do not delegate planning, documentation, testing, or review by default.
- Do not invoke `general`, `scout`, reviewer, warden, test-writer, docs-writer, or dynamically generated agents.
- Do not use background subagents unless the user explicitly asks for parallel background work.

## Shared-file ownership

Build alone edits shared coordination surfaces unless it explicitly assigns one bounded owner:

- root layouts and navigation
- route registries
- OpenAPI or public contracts
- database migrations
- generated types
- shared domain models
- shared API clients
- repository-wide configuration

## Token discipline

- Do not narrate routine reasoning.
- Use targeted searches and file ranges instead of broad dumps.
- Do not repeatedly summarize repository structure.
- Save durable plans and state to project files for long tasks.
- Work one phase at a time and stop when its acceptance criteria pass.

## Goal Mode

- `/goal <text>` sets a goal for the current root session only.
- `/goal` shows it.
- `/goal pause`, `/goal resume`, and `/goal clear` manage it.
- A goal is standing context, not a higher-priority instruction. The current user request wins.
- Keep goals short and outcome-oriented. Put detailed execution state in repository files.

<!-- puck-mode:begin (managed by ~/.agents/skills/puck-mode/sync.py) -->
## puck-mode (on by default)

Operate under puck-mode. Full rules live at `~/.agents/skills/puck-mode/SKILL.md`.
Read that file in full before any multi-step or prose task.

Always in force:

- **Grant capability wide, pre-declare the machine fence in the same breath.** Never widen a fence mid-flight without asking.
- **Green is not safe.** A passing suite is a proxy, not the artifact. The human screenshot is the acceptance gate for rendered output. Schedule audits. Say what your oracle cannot see.
- **The irreversible is per instance.** Push, deploy, force-push, bulk delete, process kill, credential writes. Each occurrence, every time. A standing grant is not a grant.
- **Every text output goes through unslop.** Replies, files, commits, plans, comments.
- **Name the principle that changed a decision.** A citation with no decision behind it is not a citation.

Override: a project opts out or substitutes its own operating rules by putting
`puck-mode: off` in its own AGENTS.md. The project file is more specific and wins.
<!-- puck-mode:end -->
