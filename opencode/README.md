# Lean OpenCode configuration

Use this as the only global configuration tree at `~/.config/opencode`.

## Workflow

```text
Build
├── Explore (read-only)
├── specialist-frontend (terminal worker)
└── specialist-backend (terminal worker)
```

There is no router, general worker, reviewer chain, warden, test-writer, docs-writer, or recursive delegation.

## Install

1. Back up the existing global and project-local OpenCode configuration.
2. Remove or rename project `.opencode` directories that define overlapping agents or plugins.
3. Copy this directory to `~/.config/opencode`.
4. Run `npm install` inside `~/.config/opencode`.
5. Run `npm run check`.
6. Fully restart OpenCode so old agent definitions are not cached.
7. Select MiMo V2.5 Pro with `/models`. The exact provider/model ID can vary, so it is intentionally not hard-coded. Frontend and backend specialists inherit the lead model.

## Goal Mode

- `/goal Refactor Ackd without breaking stage history`
- `/goal`
- `/goal pause`
- `/goal resume`
- `/goal clear`

Goals are stored per session under `~/.config/opencode/goal-state/`. They are injected into that session only and are preserved during compaction.

## Review

Use `/review` or switch to Plan. Review runs in the current session; it does not spawn a reviewer child.

## Notes

- `general` and `scout` are disabled to keep the Task tool's visible choices small.
- Build can invoke only Explore, frontend, and backend.
- Every child has `task: deny`, so recursion is mechanically blocked.
- Avoid per-project `.opencode` agent definitions unless you intentionally want them merged with this global config.
