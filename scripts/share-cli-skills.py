#!/usr/bin/env python3
"""Link portable toolkit skills to both CLIs; preserve healthy local variants."""
import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    toolkit = Path(__file__).resolve().parents[1]
    sources = {}
    for collection in ("skills", "agent-skills"):
        for source in sorted((toolkit / collection).iterdir()):
            if source.name.startswith(".") or not (source / "SKILL.md").is_file():
                continue
            if source.name in sources:
                raise SystemExit(f"Duplicate toolkit skill: {source.name}")
            sources[source.name] = (source.resolve(), collection)
    report = {"portable_skills": len(sources), "linked": [], "available": [],
              "preserved_variants": [], "repaired_links": [], "broken_legacy_links": []}
    for target in (Path.home() / ".codex/skills", Path.home() / ".claude/skills"):
        if args.apply:
            target.mkdir(parents=True, exist_ok=True)
        for name, (source, collection) in sources.items():
            # Codex already discovers agent-skills through ~/.agents/skills.
            if target == Path.home() / ".codex/skills" and collection == "agent-skills":
                shared = Path.home() / ".agents/skills" / name
                if not (shared / "SKILL.md").is_file():
                    raise SystemExit(f"Shared Codex skill is missing: {shared}")
                report["available"].append(str(shared))
                continue
            link = target / name
            if (link / "SKILL.md").is_file():
                key = "available" if link.resolve() == source else "preserved_variants"
                report[key].append(str(link))
            elif link.is_symlink() and not link.exists():
                report["repaired_links"].append({"path": str(link), "old": str(link.readlink())})
                if args.apply:
                    link.unlink()
                    link.symlink_to(source, target_is_directory=True)
            elif link.exists() or link.is_symlink():
                raise SystemExit(f"Existing non-skill path was preserved: {link}")
            else:
                report["linked"].append(str(link))
                if args.apply:
                    link.symlink_to(source, target_is_directory=True)
        if target.is_dir():
            for link in target.iterdir():
                if link.is_symlink() and not link.exists():
                    report["broken_legacy_links"].append(str(link))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
