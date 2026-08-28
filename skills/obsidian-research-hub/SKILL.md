---
name: obsidian-research-hub
description: Use the personal Obsidian vault as the default shared hub for Codex plans, research, decisions, and task handoffs. Use for non-trivial planning, research, investigation, architecture work, product thinking, or when the user asks to record work in Writer or Obsidian.
---

# Obsidian research hub

Use this skill to keep Codex planning and research visible in Writer and Obsidian.

## Paths

Set the vault path once for the current shell instructions. Override it on a
machine whose vault is cloned elsewhere:

```bash
vault_path=${OBSIDIAN_VAULT_PATH:-"$HOME/Documents/personal/obsidian/personal"}
```

Obsidian also knows this link:

```text
$HOME/obsidian/personal
```

Writer command:

```bash
writer "$vault_path"
```

## Required first step

Read the vault `AGENTS.md` file completely before you read or write vault notes.

Check the vault Git state:

```bash
git -C "$vault_path" status --short --branch
```

When the worktree is clean and the task will write to the vault, update it with:

```bash
git -C "$vault_path" fetch origin
git -C "$vault_path" pull --ff-only origin main
```

If the worktree has changes, do not pull, reset, clean, or overwrite them. Read the relevant files and make a new edit only when it does not conflict. Report the state when it blocks a safe write.

## Select the note

Search before you create a file:

```bash
rg -n -i "subject terms" "$vault_path/codex" "$vault_path/projects" "$vault_path/knowledge"
```

- Update an existing useful note when it still has the same subject and purpose.
- Put a new task plan in `codex/plans/YYYY-MM-DD-short-topic.md`.
- Put a new research summary in `codex/research/YYYY-MM-DD-short-topic.md`.
- Put raw captured material in `sources/capture/`.
- Distill durable results into `knowledge/` or the correct `projects/` note when useful.
- Use a separate task file. Do not make one shared hot file for all active tasks.

## Required content

A plan must state:

- the outcome
- scope and limits
- decisions
- steps and status
- proof of completion
- open questions or the next action

A research note must state:

- the question
- a short answer
- evidence and sources
- assumptions or uncertainty
- decisions or recommendations
- the next action, when one exists

Use YAML frontmatter with `title`, `type`, `status`, `created`, `updated`, and `tags` for a new note.

## Repository boundary

Follow repository instructions first. When a repository requires a plan, ADR, research file, or other document, keep that file in the repository as the main source.

Add a short vault note that gives:

- the absolute repository path
- the document path
- a short result
- the decision or next action

Do not maintain two full copies of the same document.

## Safety and Git

- Never store secrets, access tokens, private keys, passwords, private environment values, or full sensitive logs in the vault.
- Preserve user changes and unrelated files.
- Use `apply_patch` for note edits.
- Do not commit or push vault changes unless the user asks for Git synchronization, or the active task explicitly includes it.
- The Obsidian Git plugin does the regular automatic backup. Do not compete with it during an active Git operation.

## Finish

Before the final response:

1. Read the changed note.
2. Check `git status --short` for the vault.
3. Confirm that the note is valid Markdown and has no secrets.
4. Give the user a clickable link to the note.
5. State whether the change is only local or is also committed and pushed.

Open Writer only when the user asks to view the note or when the current task is the initial Writer setup. Writer watches the same files, so no copy or export step is required.
