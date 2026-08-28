#!/usr/bin/env bash

set -euo pipefail

marketplace_name=open-pstack
plugin_id=pstack@open-pstack
repository=decocereus/open-pstack-openai
expected_source=https://github.com/decocereus/open-pstack-openai.git
revision=8b893f30d68378e14680aec0a56761d0c68aff69
replace=false

case "${1:-}" in
  '') ;;
  --replace) replace=true ;;
  -h|--help)
    printf '%s\n' \
      'Usage: scripts/install-pstack.sh [--replace]' \
      '' \
      'Install the private OpenAI-only Pstack fork at its pinned commit.' \
      '--replace removes an existing open-pstack marketplace when it points elsewhere.'
    exit 0
    ;;
  *)
    printf 'error: unknown option: %s\n' "$1" >&2
    exit 2
    ;;
esac

if [ "$#" -gt 1 ]; then
  printf 'error: expected at most one option\n' >&2
  exit 2
fi

for command_name in codex git python3; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'error: required command is missing: %s\n' "$command_name" >&2
    exit 1
  fi
done

codex_home=${CODEX_HOME:-$HOME/.codex}
mkdir -p "$codex_home"

marketplaces=$(codex plugin marketplace list --json)
existing_source=$(printf '%s' "$marketplaces" | python3 -c '
import json, sys
data = json.load(sys.stdin)
match = next((item for item in data["marketplaces"] if item["name"] == "open-pstack"), None)
print("" if match is None else match.get("marketplaceSource", {}).get("source", ""))
')

if [ -n "$existing_source" ] && [ "$existing_source" != "$expected_source" ]; then
  if [ "$replace" != true ]; then
    printf 'error: open-pstack already points to %s\n' "$existing_source" >&2
    printf 'Re-run with --replace after reviewing that marketplace.\n' >&2
    exit 1
  fi

  installed=$(codex plugin list --json)
  if printf '%s' "$installed" | python3 -c '
import json, sys
data = json.load(sys.stdin)
raise SystemExit(0 if any(item["pluginId"] == "pstack@open-pstack" for item in data["installed"]) else 1)
'; then
    codex plugin remove "$plugin_id" --json
  fi
  codex plugin marketplace remove "$marketplace_name" --json
fi

codex plugin marketplace add "$repository" --ref "$revision" --json
codex plugin add "$plugin_id" --json

marketplaces=$(codex plugin marketplace list --json)
marketplace_root=$(printf '%s' "$marketplaces" | python3 -c '
import json, sys
data = json.load(sys.stdin)
match = next(item for item in data["marketplaces"] if item["name"] == "open-pstack")
if match.get("marketplaceSource", {}).get("source") != "https://github.com/decocereus/open-pstack-openai.git":
    raise SystemExit("open-pstack source verification failed")
print(match["root"])
')

installed_revision=$(git -C "$marketplace_root" rev-parse HEAD)
if [ "$installed_revision" != "$revision" ]; then
  printf 'error: expected Pstack revision %s, got %s\n' "$revision" "$installed_revision" >&2
  exit 1
fi

codex plugin list --json | python3 -c '
import json, sys
data = json.load(sys.stdin)
match = next((item for item in data["installed"] if item["pluginId"] == "pstack@open-pstack"), None)
if match is None or not match["installed"] or not match["enabled"]:
    raise SystemExit("pstack installation verification failed")
'

printf 'Pstack install OK: %s at %s\n' "$plugin_id" "$revision"
