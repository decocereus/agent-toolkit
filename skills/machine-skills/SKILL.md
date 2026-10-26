---
name: machine-skills
description: Find and read skills installed on this machine across Codex, Claude Code, the shared agent toolkit, and installed plugin caches when a skill is missing from the current agent's native list.
---

# Machine skills

Both Codex and Claude can read installed skill instructions from disk. Portable
toolkit skills are linked into both user skill directories. For skills absent
from the current agent's native list, search the live catalog:

```bash
python3 ~/Documents/projects/agent-toolkit/skills/machine-skills/scripts/catalog.py design
python3 ~/Documents/projects/agent-toolkit/skills/machine-skills/scripts/catalog.py --summary
```

The optional search matches names, descriptions, and paths. `--json` returns
structured entries. The catalog resolves duplicate symlinks, excludes archived
skills, and includes installed plugin caches and Claude account-synced skills.
Cache entries can include older versions or disabled plugins; prefer the version
listed by the current host's skill catalog when available. `codex_config_state`
reports enabled, disabled, or not-recorded in the local Codex config; not-recorded
does not establish runtime status. A path proves readable
instructions, not that a plugin is enabled or its tools are connected.

Read the selected `SKILL.md` using its absolute path, and resolve its scripts,
references, and assets relative to that directory. Preserve the skill's invocation
conditions and the user's current instructions. If a required tool is absent,
use cross-provider delegation to the host that has it, or explain the limitation.

Refresh portable links after adding toolkit skills:

```bash
python3 ~/Documents/projects/agent-toolkit/scripts/share-cli-skills.py --apply
```

This preserves existing valid skills and reports any same-name variants.
