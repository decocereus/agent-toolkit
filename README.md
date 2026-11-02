# agent-toolkit

Personal agent skills and global agent instructions, shared across machines.

```text
agent-toolkit/
├── skills/                     every skill this repo owns, one folder each
├── config/
│   ├── AGENTS.md               global instructions, used by Claude and Codex
│   ├── app-skill-links.tsv     which skills link into Claude, OpenCode, Cursor, Gemini
│   ├── skill-sources.tsv       where each skill came from
│   ├── external-skills.tsv     skills installed by their own installers, not stored here
│   └── codex/                  a snapshot of the Codex plugin list, not read by any script
└── sync-skills.sh              creates the links from this repo into each app
```

Each skill has one copy, in `skills/`. Every skill links into `~/.codex/skills`.
The rows in `config/app-skill-links.tsv` link skills into the other apps.
`config/AGENTS.md` links to `~/.codex/AGENTS.md` and `~/.claude/CLAUDE.md`.

## Set up a machine

Install Codex and Claude Code first, then run:

```bash
git clone git@github.com:decocereus/agent-toolkit.git
cd agent-toolkit
./sync-skills.sh
npx -y github:chhoumann/t3-pstack install
./sync-skills.sh --check
```

The script works on macOS and Linux. It refuses to overwrite a file or folder
that differs from the repository. Restart Codex afterwards so it reloads its
skills and instructions.

## Add a skill

Create `skills/<name>/SKILL.md` and run `./sync-skills.sh`. To share it beyond
Codex, add a row to `config/app-skill-links.tsv` first. Record its origin in
`config/skill-sources.tsv`.

To adopt a skill already installed in `~/.codex/skills`, run:

```bash
./sync-skills.sh --import
./sync-skills.sh --check
```

`--import` moves it into `skills/` and links it back. It refuses divergent copies
and nested Git repositories.

## What does not belong here

- Plugin skills. Their plugins install and update them.
- Codex's `.system` skills. Codex manages them.
- Skills with their own installer, such as Clerk and Tesseract. List these in
  `config/external-skills.tsv`.

`skills/unslop` is the exception. It is a copy from t3-pstack with
`disable-model-invocation` removed, so agents can load it themselves. Upstream
changes to `unslop` have to be copied over by hand.

pstack comes from [chhoumann/t3-pstack](https://github.com/chhoumann/t3-pstack).
Its marketplaces auto-update. Check it with
`npx -y github:chhoumann/t3-pstack doctor`, and set the model sheet with
`/t3-pstack:setup-pstack` in a T3 thread.
