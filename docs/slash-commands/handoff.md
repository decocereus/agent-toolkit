---
summary: Session handoff template for agent continuity
read_when:
  - Ending a session that another agent will continue
  - User requests /handoff
  - Context is getting full and work needs to transfer
---

# /handoff

Package current state for next agent/session.

## Template

```markdown
## Handoff: [Project/Task Name]

### Status
- **Done**: [completed items]
- **In Progress**: [current work]
- **Blocked**: [blockers if any]
- **Pending**: [remaining items]

### Working Tree
[output of git status -sb]

### Branch/PR
- Branch: `feature/xyz`
- PR: #123 (if created)
- CI: passing/failing/pending

### Running Processes
[List tmux sessions, dev servers, watchers]
- `tmux attach -t session-name`
- Dev server: localhost:3000
- Tests: running in background

### Tests Run
- [x] Unit tests: passing
- [ ] Integration tests: not run
- [ ] E2E: not run

### Next Steps
1. First priority task
2. Second priority task
3. Third priority task

### Risks/Gotchas
- [Any flaky tests, credentials needed, edge cases]
- [Things that might break]
- [Non-obvious dependencies]
```

## Quick Version

When time is short:

```
Handoff: [task]
Done: [what's done]
Next: [what to do next]
Branch: [branch name]
Risk: [any gotchas]
```

## Commands to Run

Before handoff, gather state:

```bash
git status -sb
git log --oneline -5
tmux list-sessions
```

## Tips

- Include exact commands to resume
- Note any environment variables needed
- Mention files that were being edited
- Link to relevant docs/issues
