# Hermes setup

`config.portable.yaml` records portable choices from `~/.hermes/config.yaml`.
Merge it into a new Hermes installation after Hermes creates its own config.
Do not copy authentication files, state databases, memories, logs, runtime files,
generated toolset catalogs, or `.env` files into this repository.

`skills.tsv` records the 83 live Hermes skills found on 2026-09-02. Hermes
bundles 58 of them and 24 are extra installs. The repository documents these
skills but does not vendor them. Hermes remains responsible for updates and its
skill curator.
