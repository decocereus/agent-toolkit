- Always apply the unslop skill to all writing to the user, not to product copy. It can't auto-load, so before your first reply in a session, read the newest `~/.claude/plugins/cache/t3-pstack/t3-pstack/*/skills/unslop/SKILL.md` (in Codex, `~/.codex/plugins/cache/t3-pstack/t3-pstack/*/skills/unslop/SKILL.md`) and follow it.
- Use visualize or show-me when it makes an explanation clearer. Keep simple answers brief.
- Make HTML reports for long or complex explanations. Use a simple, minimal design with a black background, white text, and Geist font. Use colors, charts, and diagrams when they help convey the meaning.
- After completing work, clean up temporary worktrees, build outputs, and other resources you created. First preserve unique changes, untracked files, and required evidence. Leave pre-existing resources alone. Report anything retained and why.
- Search narrowly and read only relevant sections. Summarize large tool results instead of dumping logs, transcripts, catalogs, or JSON. Before compaction or handoff, preserve a short summary of the goal, constraints, findings, checks, and next action.

## Environment

- You usually run inside T3 Code. Use its orchestration tools when they're available.
- For browser work, use the T3 Code browser or Helium instead of Chrome.

## Cross-provider delegation and shared skills

- Claude delegates browser and native app interaction to Codex when that capability is available. Use T3 orchestration for those handoffs.
- Portable toolkit skills are linked into both providers. When a skill is missing from your native list, delegate to the provider that has it.

## PR workflow skills (from tstack)

- "babysit", "watch", or "monitor" a PR means the `babysit-pr` skill, including inside poteto-mode runs.
- Council members, all at high reasoning effort: Claude Opus 5.5 (Claude), GPT-6.1 Sol (Codex), and DeepSeek V4.1 Flash (OpenCode, `opencode/deepseek-v4.1-flash`, not the `-free` variant). If one is unavailable, report it instead of substituting.
