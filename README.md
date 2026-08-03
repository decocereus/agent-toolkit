# agent-toolkit

Shared scripts, guardrails, and a deliberately small set of personal agent skills.

## Skill curation

`skills/` is the source of truth for the custom skills exposed through
`~/.codex/skills`. Keep this collection small:

- Keep skills that have been used repeatedly or encode a genuinely unique workflow.
- Prefer installed, maintained plugins over vendored copies of the same capability.
- Remove speculative bundles and skills with no observed use.
- Do not copy global, plugin, or Codex-managed `.system` skills into this repository.

Global user skills live in `~/.agents/skills`. Plugin and `.system` skills are
installed and updated by Codex in its managed folders. This repository is not a
complete history of every skill that was installed on this Mac.

The collection was usage-audited on 2026-07-10 against local Codex task history.
Tracked removals remain recoverable from Git history.
