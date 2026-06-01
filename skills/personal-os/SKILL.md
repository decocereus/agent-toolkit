---
name: personal-os
description: Operate Amartya's personal Obsidian vault as the shared state layer for tasks, decisions, handoffs, and daily context. Use when the user mentions the personal OS, Obsidian vault, open loops, daily notes, XHair/Product lane, thread handoff, or asks a new thread to continue work from the vault.
---

# Personal OS

Use `/Users/amartyasingh/Documents/personal/obsidian/personal` as the shared world state.

## Start protocol

1. `cd /Users/amartyasingh/Documents/personal/obsidian/personal`
2. Read `AGENTS.md`.
3. Run `git pull --ff-only`.
4. Read, in order:
   - `operating-system/TODAY.md`
   - `operating-system/OPEN_LOOPS.md`
   - `operating-system/DECISIONS.md`
   - `operating-system/PRODUCT_SCOREBOARD.md`
   - `operating-system/VAULT_HEALTH.md`
   - any project note named by the user or active open loop
5. State the task you are taking, the relevant active loop, and what will count as done.

## Task selection

If the user asks "what should I do?" or starts a new thread without a specific task:

- prefer the active loop with the clearest next action
- currently default to `XHair product restart` unless the vault says otherwise
- do not reopen parked projects unless the user explicitly redirects
- keep office/live-reliability work bounded to named artifacts

## Writeback protocol

After doing meaningful work, update the vault before final response:

- daily note: what moved, evidence, blockers, next action
- `OPEN_LOOPS.md`: close, update, split, or park loops
- `DECISIONS.md`: record durable choices and superseded choices
- `PRODUCT_SCOREBOARD.md`: update product/revenue signal
- relevant `projects/*.md`: update actual project state
- `VAULT_HEALTH.md`: note system issues only when relevant

Do not create new notes when an existing note should be updated.

## Git protocol

For vault edits:

1. `git status --short`
2. avoid mixing with unrelated dirty changes
3. `git diff --check`
4. commit meaningful updates with a clear message
5. push to `origin/main`

Never force-push. If push/rebase conflicts happen, report the conflict instead of hiding it.

## New thread prompt

The user can start a fresh thread with:

```text
Use the personal-os skill. Read the vault, pick up the active loop/task I name, do the work, then update the vault with what changed.
Task: <specific task>
```

If no task is provided, read `TODAY.md` and `OPEN_LOOPS.md`, then recommend the next best task.
