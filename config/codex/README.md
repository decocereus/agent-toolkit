# Codex setup

`AGENTS.md` and `pstack-models.md` are linked into `~/.codex` by
`scripts/sync-skills.sh`.

`config.portable.toml` records portable user choices from the live Codex
configuration. It is deliberately not linked over `~/.codex/config.toml`.
Codex stores machine paths, project trust, runtime MCP definitions, hook hashes,
and Desktop state in that file. On a new machine, merge the portable keys after
Codex creates its own configuration.

`plugins.tsv` records the current plugin setup. `enabled` rows are explicit in
the live Codex config. `remote-installed` rows have a Desktop remote-install
manifest on disk. Codex owns their files and versions, so this repository does
not vendor their skills.

Snapshot from 2026-09-02:

- 21 plugins are explicitly enabled in the Codex config.
- 20 remote plugin packages have install manifests.
- Codex plugin packages contribute 261 active unique skill names.
- Codex owns six `.system` skills and one bundled setup skill outside this repository.

The plugin list may change when Codex Desktop updates or a plugin is installed
or removed. Refresh this inventory after either event.
