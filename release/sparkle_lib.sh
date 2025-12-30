#!/usr/bin/env bash
# Shared Sparkle/release helpers for macOS app releases.
# Source this file in release scripts.
#
# Expected env:
#   SPARKLE_PRIVATE_KEY_FILE : path to ed25519 private key
#   Optional: SPARKLE_ACCOUNT for multi-app key management

set -euo pipefail

require_bin() {
  for b in "$@"; do
    command -v "$b" >/dev/null 2>&1 || { echo "Missing required tool: $b" >&2; exit 1; }
  done
}

# Ensures git working tree is clean before release.
require_clean_worktree() {
  require_bin git
  if [[ -n $(git status --porcelain) ]]; then
    echo "Working tree is not clean; commit or stash first." >&2
    exit 1
  fi
}

# Quick sanity check that the Sparkle key can sign content.
probe_sparkle_key() {
  local keyfile=${1:?"key file required"}
  require_bin sign_update
  local tmp
  tmp=$(mktemp /tmp/sparkle-key-probe.XXXX)
  echo test >"$tmp"
  sign_update --ed-key-file "$keyfile" -p "$tmp" >/dev/null
  rm -f "$tmp"
  echo "Sparkle key verified: $keyfile"
}

# Verify an enclosure by downloading, checking length, and verifying signature.
verify_enclosure() {
  local url=$1 sig=$2 keyfile=$3 expected_len=$4
  require_bin curl sign_update
  local tmp
  tmp=$(mktemp /tmp/sparkle-enclosure.XXXX)
  trap 'rm -f "$tmp"' RETURN
  curl -L -o "$tmp" "$url"
  local len
  len=$(stat -f%z "$tmp")
  if [[ "$len" != "$expected_len" ]]; then
    echo "Length mismatch for $url (expected $expected_len, got $len)" >&2
    exit 1
  fi
  sign_update --verify "$tmp" "$sig" --ed-key-file "$keyfile"
  echo "Enclosure verified: $url"
}

# Removes AppleDouble/extended attributes that break codesign after zipping.
clean_macos_metadata() {
  local path=${1:?"path required"}
  xattr -cr "$path" 2>/dev/null || true
  find "$path" -name '._*' -delete 2>/dev/null || true
}

# Zips a bundle without resource-fork baggage.
safe_zip() {
  local source=${1:?"source bundle/app required"}
  local dest=${2:?"destination zip required"}
  clean_macos_metadata "$source"
  /usr/bin/ditto --norsrc -c -k --keepParent "$source" "$dest"
  echo "Created: $dest"
}

# Download enclosure, extract, verify codesign/spctl.
verify_codesign_from_enclosure() {
  local url=${1:?"enclosure URL required"}
  require_bin curl ditto codesign spctl

  local tmp_dir tmp_zip
  tmp_dir=$(mktemp -d /tmp/sparkle-verify.XXXX)
  tmp_zip="$tmp_dir/enclosure.zip"
  
  trap 'rm -rf "$tmp_dir"' RETURN
  
  curl -L -o "$tmp_zip" "$url"

  # Extract without resource forks
  /usr/bin/ditto -x -k --norsrc "$tmp_zip" "$tmp_dir"

  local app
  app=$(find "$tmp_dir" -maxdepth 2 -name "*.app" | head -n 1)
  if [[ -z "$app" ]]; then
    echo "No .app found in enclosure $url" >&2
    return 1
  fi

  if ! codesign --verify --deep --strict --verbose "$app"; then
    echo "codesign verification failed for $app" >&2
    return 1
  fi
  if ! spctl --assess --type execute --verbose "$app"; then
    echo "spctl assessment failed for $app" >&2
    return 1
  fi
  if command -v stapler >/dev/null 2>&1; then
    stapler validate "$app" >/dev/null || true
  fi
  echo "Codesign/spctl verification OK: $(basename "$app")"
}

# Ensure changelog top section matches version and is finalized.
ensure_changelog_finalized() {
  local version=${1:?"version required"}
  require_bin python3
  python3 - "$version" <<'PY'
import sys, pathlib, re
version = sys.argv[1]
p = pathlib.Path("CHANGELOG.md")
if not p.exists():
    sys.exit("CHANGELOG.md not found")
text = p.read_text()
first = re.search(r"^##\s+(.+)$", text, re.M)
if not first:
    sys.exit("No changelog sections found")
header = first.group(1)
if "Unreleased" in header:
    sys.exit("Top changelog section still marked Unreleased")
if not header.startswith(f"{version} ") and not header.startswith(f"{version} —"):
    sys.exit(f"Top changelog section '{header}' does not match version {version}")
print(f"Changelog finalized for {version}")
PY
}

# Extract release notes for VERSION from CHANGELOG.md.
extract_notes_from_changelog() {
  local version=${1:?"version required"}
  local dest=${2:?"dest path required"}
  require_bin python3
  python3 - "$version" "$dest" <<'PY'
import sys, pathlib, re
version, dest = sys.argv[1], pathlib.Path(sys.argv[2])
text = pathlib.Path("CHANGELOG.md").read_text()
pattern = re.compile(rf"^##\s+{re.escape(version)}\s+.*$", re.M)
m = pattern.search(text)
if not m:
    sys.exit(f"Section not found for version {version}")
start = m.end()
next_header = text.find("\n## ", start)
chunk = text[start: next_header if next_header != -1 else len(text)]
lines = [ln for ln in chunk.strip().splitlines() if ln.strip()]
dest.write_text("\n".join(lines) + "\n")
print(f"Extracted notes to {dest}")
PY
}

# Get latest appcast entry version and build.
appcast_head_version_build() {
  local appcast=${1:-appcast.xml}
  require_bin python3
  python3 - "$appcast" <<'PY'
import sys, xml.etree.ElementTree as ET
appcast = sys.argv[1]
root = ET.parse(appcast).getroot()
channel = root.find('channel')
if channel is None:
    sys.exit(1)
item = channel.find('item')
if item is None:
    sys.exit(1)
ns = {'sparkle': 'http://www.andymatuschak.org/xml-namespaces/sparkle'}
ver = item.findtext('sparkle:shortVersionString', default='', namespaces=ns)
build = item.findtext('sparkle:version', default='', namespaces=ns)
print(ver)
print(build)
PY
}

# Ensures version/build advance beyond current appcast head.
ensure_appcast_monotonic() {
  local appcast=${1:-appcast.xml}
  local version=${2:?"version required"}
  local build=${3:?"build required"}
  
  local current
  current=$(appcast_head_version_build "$appcast" 2>/dev/null || true)
  local cur_ver cur_build
  cur_ver=$(printf "%s\n" "$current" | sed -n '1p')
  cur_build=$(printf "%s\n" "$current" | sed -n '2p')
  
  if [[ -n "$cur_ver" && "$cur_ver" == "$version" ]]; then
    echo "Appcast already has version $version; bump version first." >&2
    exit 1
  fi
  if [[ -n "$cur_build" && "$build" -le "$cur_build" ]]; then
    echo "Build $build must be > latest appcast build $cur_build." >&2
    exit 1
  fi
  echo "Version $version build $build OK (advances appcast)"
}

# Check GitHub release has required assets.
check_release_assets() {
  local tag=${1:?"tag required"}
  local prefix=${2:?"artifact prefix required"}
  require_bin gh
  
  local repo
  repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
  local assets
  assets=$(gh release view "$tag" --repo "$repo" --json assets --jq '.assets[].name')
  
  local zip dsym
  zip=$(printf "%s\n" "$assets" | grep -E "^${prefix}[0-9]+(\\.[0-9]+)*\\.zip$" || true)
  dsym=$(printf "%s\n" "$assets" | grep -E "^${prefix}[0-9]+(\\.[0-9]+)*\\.dSYM\\.zip$" || true)
  
  [[ -z "$zip" ]] && { echo "ERROR: app zip missing on release $tag" >&2; exit 1; }
  [[ -z "$dsym" ]] && { echo "WARNING: dSYM zip missing on release $tag" >&2; }
  
  echo "Release $tag has required assets"
}

# Clear Sparkle caches for testing.
clear_sparkle_caches() {
  local bundle_id=${1:?"bundle ID required"}
  rm -rf ~/Library/Caches/"$bundle_id" ~/Library/Caches/org.sparkle-project.Sparkle 2>/dev/null || true
  echo "Cleared Sparkle caches for $bundle_id"
}
