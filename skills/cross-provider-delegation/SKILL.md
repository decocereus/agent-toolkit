---
name: cross-provider-delegation
description: Delegate a task between subscription-authenticated Codex and Claude Code through their local CLIs, including user-selected models, computer use, copywriting, and design.
---

# Cross-provider delegation

Keep T3 Code as the conversation with the user. Call the other provider through
its signed-in CLI and bring the result back into the parent conversation.

## Model choice

- Opus 5.5 is the user's daily driver and a general model, including coding.
- Honor the user's model choice for each task. Avoid fixed research/coding roles.
- Claude delegates computer use to Codex. Codex delegates copywriting and design
  to Claude. Explicit task instructions override these defaults.
- Sol 6.1 is available for research, debugging, and coding. Luna suits small tasks;
  choose an explicit model for larger tasks instead of relying on a small default.
- Exact IDs: `claude-opus-5-5`, `claude-sonnet-5-5`, `gpt-6.1-sol`,
  `gpt-6-astra`, `gpt-6-luna`. Do not silently substitute an older model.

## Handoff

Give the child the task, relevant context, working directory, desired output,
required skills, and allowed file or UI changes. For browser/UI work, identify
the target app or URL and whether an authenticated session is required. The child
must report a missing login or unavailable surface rather than inventing success.
Include this line in its prompt:

> You are a delegated child. Complete this task yourself; do not delegate again
> unless the parent explicitly asks you to. Return your result and verification.

Feed a prompt file on stdin instead of interpolating user text into shell code.
The parent owns integration and verification. Use disjoint file ownership or a
separate worktree when parent and child both edit code.

## Codex to Claude

For a context-only consultation or copywriting task:

```bash
env -u ANTHROPIC_API_KEY -u ANTHROPIC_AUTH_TOKEN -u CLAUDE_CODE_OAUTH_TOKEN \
  -u ANTHROPIC_BASE_URL -u CLAUDE_CODE_USE_BEDROCK -u CLAUDE_CODE_USE_VERTEX \
  -u CLAUDE_CODE_USE_FOUNDRY -u CLAUDECODE \
  ENABLE_CLAUDEAI_MCP_SERVERS=false \
  claude -p --model claude-opus-5-5 --effort high \
  --no-session-persistence --output-format json --tools '' \
  --strict-mcp-config --mcp-config '{"mcpServers":{}}' < task.md > result.json
```

Run in the task's working directory. For work requiring tools, omit `--tools ''`
and the empty MCP overrides; use `--permission-mode dontAsk` with task-scoped
`--allowedTools` for the required reads, edits, or commands. Headless permission
denials are failures to report, not permission to bypass the parent's limits.
Never use `--bare` for subscription calls: it skips subscription authentication.
Check `claude auth status` and any `apiKeyHelper` or provider env settings if the
authentication route is uncertain. The JSON result exposes model usage and errors.

## Claude to Codex

For research or a repository consultation:

```bash
env -u OPENAI_API_KEY -u OPENAI_BASE_URL \
  codex -a never exec --model gpt-6.1-sol \
  -c 'forced_login_method="chatgpt"' -c 'model_provider="openai"' \
  --ephemeral --skip-git-repo-check --sandbox read-only \
  -C /absolute/task/directory -o result.md - < task.md
```

Choose `workspace-write` when the task authorizes repository edits. Computer use
needs the child's existing computer-use MCP/plugin configuration and permissions;
do not use `--ignore-user-config` or disable its tools for that task. Request the
specific UI action and have the child report what it observed or changed. If its
tools cannot drive the requested surface, report that limitation.

## Shared skills and session boundaries

Use `machine-skills` to find skill instructions from either provider's installed
directories and plugin caches. Read the chosen `SKILL.md` and its relative
resources from their original location. Instructions can be shared; plugin tools
and app connections still need to be available in the executing provider.

CLI children do not inherit the parent transcript, T3 browser handles, or its
MCP connections. They are separate CLI sessions, so summarize their results in T3.
Set an appropriate command timeout and retain result files for long tasks. On
rate limits, failed authentication, or unavailable models, report the failure
and let the parent finish what it can; do not retry indefinitely.
