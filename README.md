# agent-toolkit

Shared scripts, guardrails, and personal agent skills that can be used from
multiple machines.

## Skill layout

```text
agent-toolkit/
├── skills/          -> ~/.codex/skills/<name>
└── agent-skills/    -> ~/.agents/skills/<name>

~/.codex/skills/.system   # Codex-managed; never linked or vendored here
```

The repository owns user-installed skills. Codex still owns `.system`, and
plugins remain in Codex's plugin cache so their update mechanisms keep working.
Each skill is linked individually; the script never replaces the containing
`~/.codex/skills` directory.

## Set up a machine

Clone the repository with its pinned external skill, then run:

```bash
git clone --recurse-submodules git@github.com:decocereus/agent-toolkit.git
cd agent-toolkit
./scripts/sync-skills.sh
./scripts/sync-skills.sh --check
```

For an existing clone, initialize the external skill first:

```bash
git submodule update --init --recursive
```

The linker works on macOS and Linux and refuses to overwrite an existing file
or directory. Restart Codex after the first setup so it reloads the catalog.
`cargo-cult` remains a pinned submodule because its upstream repository does
not grant a redistribution license; this public repository stores only the
upstream URL and commit for that skill.

## Capture newly installed skills

Install skills into their normal user location, then adopt them into the
repository:

```bash
./scripts/sync-skills.sh --import
./scripts/sync-skills.sh --check
git status --short
```

`--import` moves valid skills containing `SKILL.md` into the corresponding
repository directory and links them back. It refuses divergent copies and
nested Git repositories so that it cannot silently discard independent history.
Review, commit, and push the imported files before pulling on another machine.

## Curation boundaries

Keep the collection intentional:

- Keep skills that have been used repeatedly or encode a genuinely unique workflow.
- Prefer installed, maintained plugins over vendored copies of the same capability.
- Remove speculative bundles and skills with no observed use.
- Do not copy plugin or Codex-managed `.system` skills into this repository.

Global user skills are tracked under `agent-skills/` and exposed through
`~/.agents/skills`. Plugin and `.system` skills are installed and updated by
Codex in its managed folders.

The collection was usage-audited on 2026-07-10 against local Codex task history.
Tracked removals remain recoverable from Git history.
