#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./sync-skills.sh [--check | --import]

  no option  Link repository skills and the global agent instructions.
  --check    Verify that every repository skill is linked correctly and that
             no valid live skill is missing from the repository.
  --import   Move valid, unmanaged live skills into the repository, then link
             them back. Existing divergent content and nested Git repositories
             are left untouched and reported as conflicts.
EOF
}

mode=link
case "${1:-}" in
  '') ;;
  --check) mode=check ;;
  --import) mode=import ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

repo_root=$(CDPATH= cd "$(dirname "$0")" && pwd)
skills_source="$repo_root/skills"
app_links_file="$repo_root/config/app-skill-links.tsv"
external_skills_file="$repo_root/config/external-skills.tsv"
instructions_source="$repo_root/config/AGENTS.md"
codex_home="${CODEX_HOME:-$HOME/.codex}"
codex_target="$codex_home/skills"
agents_target="$HOME/.agents/skills"

errors=0
linked=0
imported=0
verified=0
backup_dir=''
sync_succeeded=false

cleanup() {
  if [ -n "$backup_dir" ] && [ -d "$backup_dir" ]; then
    if [ "$sync_succeeded" = true ]; then
      rm -rf "$backup_dir"
    else
      printf 'Import backup retained at %s\n' "$backup_dir" >&2
    fi
  fi
}
trap cleanup EXIT

report_error() {
  printf 'error: %s\n' "$1" >&2
  errors=$((errors + 1))
}

# Skills installed by their own upstream installer are recorded, not vendored.
is_external_skill() {
  awk -F '\t' -v app="$1" -v name="$2" \
    '$1 == app && $2 == name { found = 1 } END { exit !found }' \
    "$external_skills_file"
}

ensure_source_is_valid() {
  local source_root=$1
  local label=$2
  local source_path

  if [ ! -d "$source_root" ]; then
    report_error "$label source directory is missing: $source_root"
    return
  fi

  for source_path in "$source_root"/*; do
    [ -e "$source_path" ] || continue
    if [ ! -d "$source_path" ] || [ ! -f "$source_path/SKILL.md" ]; then
      report_error "$label source is not a valid skill: $source_path"
    fi
  done
}

import_live_skills() {
  local source_root=$1
  local target_root=$2
  local label=$3
  local app=$4
  local live_path
  local name
  local source_path

  mkdir -p "$source_root" "$target_root"

  for live_path in "$target_root"/*; do
    [ -e "$live_path" ] || [ -L "$live_path" ] || continue
    name=$(basename "$live_path")

    [ "$name" = '.system' ] && continue
    [ -L "$live_path" ] && continue
    [ -f "$live_path/SKILL.md" ] || continue
    is_external_skill "$app" "$name" && continue

    source_path="$source_root/$name"
    if [ -d "$live_path/.git" ]; then
      report_error "$label skill contains a nested Git repository; import it manually: $live_path"
      continue
    fi

    if [ -e "$source_path" ]; then
      if ! diff -qr "$source_path" "$live_path" >/dev/null; then
        report_error "$label skill differs from the repository copy: $live_path"
        continue
      fi

      if [ -z "$backup_dir" ]; then
        backup_dir=$(mktemp -d "${TMPDIR:-/tmp}/agent-toolkit-skills.XXXXXX")
      fi
      mv "$live_path" "$backup_dir/$label-$name"
    else
      mv "$live_path" "$source_path"
      imported=$((imported + 1))
      printf 'imported %s: %s\n' "$label" "$name"
    fi

    ln -s "$source_path" "$live_path"
    linked=$((linked + 1))
  done
}

link_skills() {
  local source_root=$1
  local target_root=$2
  local label=$3
  local source_path
  local name
  local live_path
  local actual_target

  if [ "$mode" != check ]; then
    mkdir -p "$target_root"
  elif [ ! -d "$target_root" ]; then
    report_error "$label target directory is missing: $target_root"
    return
  fi

  for source_path in "$source_root"/*; do
    [ -d "$source_path" ] || continue
    [ -f "$source_path/SKILL.md" ] || continue
    name=$(basename "$source_path")
    live_path="$target_root/$name"

    if [ -L "$live_path" ]; then
      actual_target=$(readlink "$live_path")
      if [ "$actual_target" = "$source_path" ]; then
        verified=$((verified + 1))
      else
        report_error "$label skill points elsewhere: $live_path -> $actual_target"
      fi
    elif [ -e "$live_path" ]; then
      report_error "$label skill already exists and was not overwritten: $live_path"
    elif [ "$mode" = check ]; then
      report_error "$label skill link is missing: $live_path"
    else
      ln -s "$source_path" "$live_path"
      linked=$((linked + 1))
      printf 'linked %s: %s\n' "$label" "$name"
    fi
  done
}

check_for_unmanaged_skills() {
  local source_root=$1
  local target_root=$2
  local label=$3
  local app=$4
  local live_path
  local name

  [ -d "$target_root" ] || return
  for live_path in "$target_root"/*; do
    [ -e "$live_path" ] || [ -L "$live_path" ] || continue
    name=$(basename "$live_path")
    [ "$name" = '.system' ] && continue
    [ -f "$live_path/SKILL.md" ] || continue
    is_external_skill "$app" "$name" && continue
    # A link into another repository is owned and versioned there.
    if [ -L "$live_path" ]; then
      case "$(CDPATH= cd "$live_path" && pwd -P)" in
        "$repo_root"/*) ;;
        *) continue ;;
      esac
    fi
    if [ ! -f "$source_root/$name/SKILL.md" ]; then
      report_error "$label skill is not in the repository: $live_path"
    fi
  done
}

link_app_skills() {
  local target_relative
  local name
  local source_path
  local target_root
  local live_path
  local actual_target

  if [ ! -f "$app_links_file" ]; then
    report_error "portable app skill manifest is missing: $app_links_file"
    return
  fi

  while IFS=$'\t' read -r target_relative name; do
    case "$target_relative" in
      ''|'#'*) continue ;;
      /*|*../*|*/..|..) report_error "invalid app skill target: $target_relative"; continue ;;
    esac

    source_path="$skills_source/$name"
    target_root="$HOME/$target_relative"
    live_path="$target_root/$name"

    if [ ! -f "$source_path/SKILL.md" ]; then
      report_error "portable app skill source is missing: $source_path"
    elif [ -L "$live_path" ]; then
      actual_target=$(readlink "$live_path")
      if [ "$actual_target" = "$source_path" ]; then
        verified=$((verified + 1))
      else
        report_error "portable app skill points elsewhere: $live_path -> $actual_target"
      fi
    elif [ -e "$live_path" ]; then
      report_error "portable app skill already exists and was not overwritten: $live_path"
    elif [ "$mode" = check ]; then
      report_error "portable app skill link is missing: $live_path"
    else
      mkdir -p "$target_root"
      ln -s "$source_path" "$live_path"
      linked=$((linked + 1))
      printf 'linked portable app skill: %s\n' "$live_path"
    fi
  done < "$app_links_file"
}

link_config_file() {
  local source_path=$1
  local live_path=$2
  local label=$3
  local actual_target

  if [ -L "$live_path" ]; then
    actual_target=$(readlink "$live_path")
    if [ "$actual_target" = "$source_path" ]; then
      verified=$((verified + 1))
    else
      report_error "$label points elsewhere: $live_path -> $actual_target"
    fi
  elif [ -e "$live_path" ]; then
    if ! cmp -s "$source_path" "$live_path"; then
      report_error "$label differs from the repository copy: $live_path"
    elif [ "$mode" = check ]; then
      report_error "$label is byte-identical but is not linked: $live_path"
    else
      if [ -z "$backup_dir" ]; then
        backup_dir=$(mktemp -d "${TMPDIR:-/tmp}/agent-toolkit-skills.XXXXXX")
      fi
      mv "$live_path" "$backup_dir/config-$(basename "$live_path")"
      ln -s "$source_path" "$live_path"
      linked=$((linked + 1))
      printf 'linked %s: %s\n' "$label" "$live_path"
    fi
  elif [ "$mode" = check ]; then
    report_error "$label link is missing: $live_path"
  else
    ln -s "$source_path" "$live_path"
    linked=$((linked + 1))
    printf 'linked %s: %s\n' "$label" "$live_path"
  fi
}

ensure_source_is_valid "$skills_source" repository
if [ ! -f "$instructions_source" ]; then
  report_error "global instructions are missing: $instructions_source"
fi

if [ "$errors" -ne 0 ]; then
  printf 'Skill sync failed with %d source error(s).\n' "$errors" >&2
  exit 1
fi

if [ "$mode" = import ]; then
  import_live_skills "$skills_source" "$codex_target" Codex Codex
fi

link_skills "$skills_source" "$codex_target" Codex
link_app_skills
check_for_unmanaged_skills "$skills_source" "$codex_target" Codex Codex
check_for_unmanaged_skills "$skills_source" "$agents_target" agent Agents

if [ "$mode" != check ]; then
  mkdir -p "$codex_home" "$HOME/.claude"
fi
link_config_file "$instructions_source" "$codex_home/AGENTS.md" "Codex global instructions"
link_config_file "$instructions_source" "$HOME/.claude/CLAUDE.md" "Claude global instructions"

if [ "$errors" -ne 0 ]; then
  printf 'Skill sync failed with %d conflict(s).\n' "$errors" >&2
  exit 1
fi

sync_succeeded=true
printf 'Skill sync OK: %d imported, %d linked, %d already verified.\n' \
  "$imported" "$linked" "$verified"
