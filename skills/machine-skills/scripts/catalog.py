#!/usr/bin/env python3
"""Read-only catalog of installed skill instructions; no credentials are read."""
import argparse
import json
import os
from pathlib import Path
import re
import tomllib


def metadata(path):
    text = path.read_text(errors="replace")
    match = re.match(r"^---\s*\n(.*?)\n---", text, re.S)
    header = match.group(1) if match else ""
    def field(key):
        found = re.search(rf"^{key}:\s*(.+)$", header, re.M)
        return found.group(1).strip().strip("\"'") if found else ""
    return field("name") or path.parent.name, field("description")


def catalog():
    home = Path.home()
    toolkit = Path(__file__).resolve().parents[3]
    config = home / ".codex/config.toml"
    plugins = tomllib.loads(config.read_text()).get("plugins", {}) if config.is_file() else {}
    roots = [home / ".codex/skills", home / ".agents/skills",
             home / ".claude/skills", home / "skills",
             home / ".hermes/skills", home / ".config/opencode/skills",
             home / ".cursor/skills", home / ".gemini/skills",
             toolkit / "skills", toolkit / "agent-skills",
             home / ".codex/plugins/cache", home / ".claude/plugins/cache"]
    entries = {}
    for root in roots:
        if not root.is_dir():
            continue
        visited = set()
        for directory, children, files in os.walk(root, followlinks=True):
            real_directory = Path(directory).resolve()
            if real_directory in visited:
                children[:] = []
                continue
            visited.add(real_directory)
            children[:] = [name for name in children if name not in
                           {".git", ".trash", "node_modules", "__pycache__"}
                           and not name.startswith(".remote-plugin")]
            if "SKILL.md" not in files:
                continue
            path = (Path(directory) / "SKILL.md").resolve()
            if path in entries:
                continue
            name, description = metadata(path)
            kind = "plugin-cache" if "/plugins/cache/" in str(path) else "installed"
            entry = {"name": name, "description": description,
                             "path": str(path),
                             "kind": kind}
            if kind == "plugin-cache":
                cache_root = home / ".codex/plugins/cache"
                if path.is_relative_to(cache_root):
                    relative = path.relative_to(cache_root).parts
                    key = relative[1] + "@" + relative[0]
                    state = plugins.get(key, {}).get("enabled")
                    entry.update({"plugin": key, "version": relative[2],
                                  "codex_config_state": "enabled" if state is True else
                                      "disabled" if state is False else "not-recorded"})
            entries[path] = entry
    return sorted(entries.values(), key=lambda entry: (entry["name"], entry["path"]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("query", nargs="?", default="")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--summary", action="store_true")
    args = parser.parse_args()
    entries = catalog()
    if args.summary:
        print(json.dumps({"readable_skill_files": len(entries),
                          "installed": sum(e["kind"] == "installed" for e in entries),
                          "plugin_cache": sum(e["kind"] == "plugin-cache" for e in entries)},
                         indent=2))
        return
    if args.query:
        query = args.query.casefold()
        entries = [e for e in entries if query in
                   " ".join((e["name"], e["description"], e["path"])).casefold()]
    if args.json:
        print(json.dumps(entries, indent=2))
    else:
        for entry in entries:
            state = entry.get("codex_config_state", "")
            print(f"{entry['name']} [{entry['kind']} {state}]\n  {entry['description']}\n  {entry['path']}")


if __name__ == "__main__":
    main()
