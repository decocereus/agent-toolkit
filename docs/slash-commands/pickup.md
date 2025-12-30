---
summary: Session pickup checklist for resuming work
read_when:
  - Starting work on a project mid-stream
  - User requests /pickup
  - Resuming from another agent's handoff
---

# /pickup

Resume work from a handoff or fresh start.

## Checklist

### 1. Read Context

```bash
# Check for handoff notes
cat HANDOFF.md 2>/dev/null || echo "No handoff file"

# Read project docs
cat AGENTS.md README.md 2>/dev/null | head -100
```

### 2. Check Git State

```bash
git status -sb
git log --oneline -5
git diff --stat HEAD~3
```

Questions:
- What branch am I on?
- Are there uncommitted changes?
- What was recently changed?

### 3. Check CI/PR

```bash
# If PR exists
gh pr status
gh pr checks

# Recent CI runs
gh run list --limit 5
```

### 4. Check Running Processes

```bash
# tmux sessions
tmux list-sessions

# Running servers
lsof -i :3000 -i :8080 2>/dev/null
```

### 5. Understand Current State

From handoff or by exploration:
- What's done?
- What's in progress?
- What's blocked?
- What's the next priority?

### 6. Plan Actions

Before coding:
1. List 2-3 immediate tasks
2. Identify any blockers
3. Note questions for user

## Quick Pickup

When there's no handoff:

```bash
# Fast orientation
git log --oneline -10
git diff --name-only HEAD~5
ls -la
cat README.md | head -50
```

## Questions to Answer

- [ ] What is this project?
- [ ] What was the last thing done?
- [ ] What should I do next?
- [ ] Are there failing tests/builds?
- [ ] Any running processes I need to know about?

## Template Response

After pickup:

```markdown
Picked up [project].

**Current state:**
- Branch: `feature/xyz`
- Last commit: "feat: add login"
- No uncommitted changes

**Plan:**
1. [Next task]
2. [Following task]

Ready to continue?
```
