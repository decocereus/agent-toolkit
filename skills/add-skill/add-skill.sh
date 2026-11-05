#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  add-skill.sh install <skill-dir> <source-type> <source>
      Copy a reviewed skill into this checkout and register it for Claude Code,
      Codex, and OpenCode. Source type is upstream, adapted, or local.
  add-skill.sh verify <name>
      Check that this machine's links point at this checkout and that each
      app's own loader lists the skill. Exits non-zero on any failure.
EOF
}

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

repo_root=$(cd -P "$(dirname "$0")" && cd ../.. && pwd)
failures=0

frontmatter_field() {
  awk -v key="$2:" '
    NR == 1 && $0 != "---" { exit }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && index($0, key) == 1 { sub(key " *", ""); print; exit }
  ' "$1"
}

append_row() {
  local file=$1 row=$2
  grep -qxF "$row" "$file" && return
  # A file without a final newline would merge the new row into its last line.
  [ -z "$(tail -c1 "$file")" ] || printf '\n' >> "$file"
  printf '%s\n' "$row" >> "$file"
}

install_skill() {
  local source_dir=$1 source_type=$2 source=$3 name dest

  case "$source_type" in
    upstream|adapted|local) ;;
    *) die "source type must be upstream, adapted, or local: $source_type" ;;
  esac
  [ -f "$source_dir/SKILL.md" ] || die "no SKILL.md in $source_dir"

  name=$(frontmatter_field "$source_dir/SKILL.md" name)
  printf '%s\n' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$' \
    || die "frontmatter name must be lowercase words joined by hyphens: '$name'"
  [ -n "$(frontmatter_field "$source_dir/SKILL.md" description)" ] \
    || die "frontmatter has no description"
  [ -z "$(find "$source_dir" -type l -print -quit)" ] \
    || die "skill contains symlinks, which could point outside the skill"

  dest="$repo_root/skills/$name"
  [ ! -e "$dest" ] || die "skill already exists: $dest"

  cp -R "$source_dir" "$dest"
  rm -rf "$dest/.git"

  append_row "$repo_root/config/app-skill-links.tsv" "$(printf '.claude/skills\t%s' "$name")"
  append_row "$repo_root/config/app-skill-links.tsv" "$(printf '.config/opencode/skills\t%s' "$name")"
  append_row "$repo_root/config/skill-sources.tsv" "$(printf '%s\t%s\t%s' "$name" "$source_type" "$source")"

  printf 'installed %s into %s\n' "$name" "$repo_root"
}

report() {
  local status=$1 app=$2 detail=$3
  printf '%-4s %-8s %s\n' "$status" "$app" "$detail"
  [ "$status" = ok ] || failures=$((failures + 1))
}

check_link() {
  local app=$1 link=$2 expected=$3 actual
  actual=$(readlink "$link" 2>/dev/null || true)
  if [ "$actual" = "$expected" ]; then
    report ok "$app" "link $link"
  else
    report FAIL "$app" "link $link -> '${actual:-missing}', expected $expected"
  fi
}

# Each loader's output goes into a variable first. Under pipefail, grep -q closing
# the pipe early would turn a match into a failure.
claude_lists() {
  local init
  init=$( (cd "$repo_root" && claude -p --output-format stream-json --verbose --max-turns 1 --model haiku 'reply ok' </dev/null 2>/dev/null) \
    | grep -m1 '"subtype":"init"' || true)
  grep -qF "\"$1\"" <<<"$init"
}

codex_lists() {
  local prompt
  prompt=$(codex debug prompt-input </dev/null 2>/dev/null || true)
  grep -qF -- "- $1:" <<<"$prompt"
}

opencode_lists() {
  local name=$1 password port pid body='' attempt
  password=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
  port=$((40000 + RANDOM % 20000))
  (cd "$repo_root" && OPENCODE_SERVER_PASSWORD=$password exec opencode serve --hostname 127.0.0.1 --port "$port") >/dev/null 2>&1 </dev/null &
  pid=$!
  # The server answers with an empty list until it has finished scanning skills.
  for attempt in $(seq 1 120); do
    body=$(curl -sf -u "opencode:$password" "http://127.0.0.1:$port/api/skill" 2>/dev/null || true)
    case "$body" in
      *'"name"'*) break ;;
    esac
    sleep 0.25
  done
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  grep -qE "\"name\": *\"$name\"" <<<"$body"
}

check_loader() {
  local app=$1 command=$2 name=$3
  if ! command -v "$command" >/dev/null; then
    report FAIL "$app" "loader check skipped, $command is not installed"
  elif "${command}_lists" "$name"; then
    report ok "$app" "loader lists $name"
  else
    report FAIL "$app" "loader does not list $name"
  fi
}

verify_skill() {
  local name=$1
  local expected="$repo_root/skills/$name"

  [ -f "$expected/SKILL.md" ] || die "not in this checkout: $expected"

  check_link claude "$HOME/.claude/skills/$name" "$expected"
  check_link codex "${CODEX_HOME:-$HOME/.codex}/skills/$name" "$expected"
  check_link opencode "$HOME/.config/opencode/skills/$name" "$expected"

  check_loader claude claude "$name"
  check_loader codex codex "$name"
  check_loader opencode opencode "$name"

  [ "$failures" -eq 0 ] || die "$failures check(s) failed for $name"
  printf '%s is available in Claude Code, Codex, and OpenCode\n' "$name"
}

case "${1:-}" in
  install) [ "$#" -eq 4 ] || { usage >&2; exit 2; }; install_skill "$2" "$3" "$4" ;;
  verify) [ "$#" -eq 2 ] || { usage >&2; exit 2; }; verify_skill "$2" ;;
  -h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
