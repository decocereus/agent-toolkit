# agent-toolkit

Shared scripts, guardrails, and personal agent skills that can be used from
multiple machines.

## Skill layout

```text
agent-toolkit/
├── skills/                 -> ~/.codex/skills/<name>
├── agent-skills/           -> ~/.agents/skills/<name>
├── config/skill-sources.tsv
│                             -> provenance for every repository-owned skill
├── config/external-skills.tsv
│                             -> standalone packages documented, not vendored
├── config/app-skill-links.tsv
│                             -> selected Claude, OpenCode, Cursor, and Gemini links
├── config/codex/           -> global instructions, portable config, plugin inventory
└── config/hermes/          -> portable config and skill inventory

~/.codex/skills/.system   # Codex-managed; never linked or vendored here
```

The repository owns user-installed skills. Codex still owns `.system`, and
plugins remain in Codex's plugin cache so their update mechanisms keep working.
Each skill is linked individually; the script never replaces the containing
`~/.codex/skills` directory.

`config/app-skill-links.tsv` lists the repository skills shared with other
agent apps. The same source directory is linked into each selected app, so a
skill has one maintained copy without replacing app-managed skill folders.

## Audited inventory

The full-machine audit on 2026-09-02 found **410 active unique skill names**.
The filesystem still has 1,221 physical `SKILL.md` files, including caches and
duplicate copies. That is not a count of distinct capabilities.

| Ownership | Unique names | Repository policy |
| --- | ---: | --- |
| `agent-toolkit` | 39 | Version the skill contents here |
| Hermes | 83 | Record in `config/hermes/skills.tsv`; do not vendor |
| Standalone upstream packages | 24 | Record in `config/external-skills.tsv`; do not vendor |
| Codex plugin packages | 261 | Record packages in `config/codex/plugins.tsv`; do not vendor |
| Codex `.system` | 6 | Codex-managed; do not vendor |
| Residual bundled setup skill | 1 | App-managed; do not vendor |

Those rows total 413 because `teach`, `github`, and `pdf` each appear in two
ownership categories. Their union is 410. See `config/skill-sources.tsv` for
the provenance of every repository-owned skill.

Codex setup is documented in `config/codex/README.md`. Hermes setup is
documented in `config/hermes/README.md`. The portable config files are merge
references, not complete replacements for app-generated config files.

## Set up a machine

Clone the repository, then run:

```bash
git clone git@github.com:decocereus/agent-toolkit.git
cd agent-toolkit
./scripts/sync-skills.sh
./scripts/install-pstack.sh
./scripts/sync-skills.sh --check
```

The linker works on macOS and Linux. It replaces a global configuration file
only when its bytes already match the repository and refuses every divergent
file or directory. Restart Codex after the first setup so it reloads the
catalog and global instructions.

On a new machine, install Codex and Hermes first, clone this repository, run
the linker and Pstack installer, install the packages listed in the inventories,
then merge the portable Codex and Hermes settings. Finish with
`./scripts/sync-skills.sh --check`.

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

Open Pstack is the exception to using its upstream marketplace directly. This
setup relies on a private OpenAI-only routing fork; install it with the pinned
installer after cloning this repository. The GitHub account on the machine must
have access to `decocereus/open-pstack-openai`. If `open-pstack` is already
configured from another source, inspect it and then run
`./scripts/install-pstack.sh --replace`.

The collection was usage-audited on 2026-07-10 against local Codex task history.
Tracked removals remain recoverable from Git history.
