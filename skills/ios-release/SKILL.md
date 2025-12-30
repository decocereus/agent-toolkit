---
name: ios-release
description: macOS app release workflow with Sparkle auto-updates, notarization, code signing, and GitHub releases. Use when shipping macOS apps outside App Store, creating DMG/ZIP artifacts, configuring Sparkle appcasts, notarizing with Apple, or debugging release issues. Covers full release pipeline from build to publish.
---

# iOS/macOS Release Workflow

Complete release pipeline for macOS apps with Sparkle updates.

## Prerequisites

### Tools Required

```bash
# Check installations
which xcodebuild notarytool sign_update gh

# Sparkle CLI tools
# sign_update comes with Sparkle framework
# Or install: brew install sparkle
```

### Environment Variables

```bash
export APP_STORE_CONNECT_KEY_ID="..."
export APP_STORE_CONNECT_ISSUER_ID="..."
export APP_STORE_CONNECT_API_KEY_P8="/path/to/key.p8"
export SPARKLE_PRIVATE_KEY_FILE="/path/to/sparkle_private_key"
```

### Sparkle Key Setup

```bash
# Generate new Sparkle key pair
generate_keys

# Test key works
echo test > /tmp/test.txt
sign_update -f "$SPARKLE_PRIVATE_KEY_FILE" /tmp/test.txt
rm /tmp/test.txt
```

## Build Pipeline

### 1. Version Bump

Single source of truth (Info.plist or xcconfig):

```bash
# Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.2.0" Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 42" Info.plist

# Or version.xcconfig
MARKETING_VERSION = 1.2.0
CURRENT_PROJECT_VERSION = 42
```

**Rules:**
- Build number MUST increase monotonically
- Sparkle compares `CFBundleVersion`, not marketing string
- Bump BEFORE tagging/publishing

### 2. Build Release

```bash
# Archive
xcodebuild archive \
  -scheme MyApp \
  -configuration Release \
  -archivePath ./build/MyApp.xcarchive

# Export app
xcodebuild -exportArchive \
  -archivePath ./build/MyApp.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

### 3. Code Signing

```bash
# Verify signature
codesign --verify --deep --strict --verbose ./build/MyApp.app

# Check entitlements
codesign -d --entitlements - ./build/MyApp.app
```

## Notarization

### Submit for Notarization

```bash
# Create ZIP for notarization
/usr/bin/ditto -c -k --keepParent ./build/MyApp.app ./build/MyApp.zip

# Submit
xcrun notarytool submit ./build/MyApp.zip \
  --key "$APP_STORE_CONNECT_API_KEY_P8" \
  --key-id "$APP_STORE_CONNECT_KEY_ID" \
  --issuer "$APP_STORE_CONNECT_ISSUER_ID" \
  --wait

# Check status
xcrun notarytool log <submission-id> \
  --key "$APP_STORE_CONNECT_API_KEY_P8" \
  --key-id "$APP_STORE_CONNECT_KEY_ID" \
  --issuer "$APP_STORE_CONNECT_ISSUER_ID"
```

### Staple Notarization

```bash
xcrun stapler staple ./build/MyApp.app

# Verify
xcrun stapler validate ./build/MyApp.app
spctl --assess --type execute --verbose ./build/MyApp.app
```

## Sparkle Updates

### Create Release Artifact

```bash
# Clean metadata that breaks signatures
xattr -cr ./build/MyApp.app
find ./build/MyApp.app -name '._*' -delete

# Create ZIP (no resource forks)
/usr/bin/ditto --norsrc -c -k --keepParent ./build/MyApp.app ./build/MyApp-1.2.0.zip

# Or create DMG
hdiutil create -volname "MyApp" -srcfolder ./build/MyApp.app -ov -format UDZO ./build/MyApp-1.2.0.dmg
```

### Sign with Sparkle

```bash
# Sign and get signature
sign_update -f "$SPARKLE_PRIVATE_KEY_FILE" ./build/MyApp-1.2.0.zip

# Output: edSignature="..." length="..."
```

### Update Appcast

```xml
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>MyApp Changelog</title>
    <item>
      <title>Version 1.2.0</title>
      <sparkle:version>42</sparkle:version>
      <sparkle:shortVersionString>1.2.0</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>14.0</sparkle:minimumSystemVersion>
      <pubDate>Mon, 30 Dec 2024 12:00:00 +0000</pubDate>
      <enclosure 
        url="https://github.com/user/repo/releases/download/v1.2.0/MyApp-1.2.0.zip"
        sparkle:edSignature="YOUR_SIGNATURE_HERE"
        length="12345678"
        type="application/octet-stream"/>
      <description><![CDATA[
        <h2>What's New</h2>
        <ul>
          <li>New feature X</li>
          <li>Bug fix Y</li>
        </ul>
      ]]></description>
    </item>
  </channel>
</rss>
```

**Critical fields:**
- `sparkle:version` = build number (must be unique, increasing)
- `sparkle:shortVersionString` = marketing version
- `sparkle:edSignature` = from sign_update output
- `length` = exact file size in bytes

### Verify Appcast

```bash
# Check signature matches
sign_update -p ./build/MyApp-1.2.0.zip

# Verify URL is accessible
curl -I "https://github.com/user/repo/releases/download/v1.2.0/MyApp-1.2.0.zip"
```

## GitHub Release

### Create Release

```bash
# Tag
git tag v1.2.0
git push origin v1.2.0

# Create release
gh release create v1.2.0 \
  --title "MyApp 1.2.0" \
  --notes-file RELEASE_NOTES.md \
  ./build/MyApp-1.2.0.zip \
  ./build/MyApp-1.2.0.dSYM.zip
```

### Verify Release

```bash
# Check assets uploaded
gh release view v1.2.0

# Download and verify
curl -LO "https://github.com/user/repo/releases/download/v1.2.0/MyApp-1.2.0.zip"
/usr/bin/ditto -x -k MyApp-1.2.0.zip ./verify/
codesign --verify --deep --strict ./verify/MyApp.app
spctl --assess --type execute --verbose ./verify/MyApp.app
```

## Verification Checklist

### Before Release

- [ ] Version and build number updated
- [ ] Changelog written
- [ ] Tests passing
- [ ] Sparkle key verified

### After Build

- [ ] `codesign --verify` passes
- [ ] `spctl --assess` passes
- [ ] `stapler validate` passes
- [ ] No `._*` files in ZIP

### After Publish

- [ ] Download artifact from GitHub
- [ ] Extract with `ditto` (not unzip)
- [ ] Verify codesign on extracted app
- [ ] Verify Sparkle signature matches appcast
- [ ] Test update from previous version
- [ ] Appcast URL returns 200

## Common Issues

### "The signature is invalid"

- Wrong Sparkle key used
- File modified after signing
- AppleDouble files in ZIP (use `ditto --norsrc`)

### Notarization Failed

```bash
# Get detailed log
xcrun notarytool log <id> --key ... --key-id ... --issuer ...

# Common: hardened runtime missing
# Fix: Enable "Hardened Runtime" in Xcode
```

### "App is damaged"

- Not notarized or stapled
- Downloaded via browser and quarantined
- Fix: `xattr -d com.apple.quarantine MyApp.app`

### Sparkle Not Finding Update

- Appcast URL wrong in app
- Build number not higher
- Cache: clear `~/Library/Caches/com.example.myapp`

## Shared Helpers

See `release/sparkle_lib.sh` for reusable bash functions:
- `require_clean_worktree` - fail if git dirty
- `probe_sparkle_key` - verify key works
- `safe_zip` - create clean ZIP
- `verify_codesign_from_enclosure` - download + verify
- `ensure_changelog_finalized` - block if Unreleased
- `ensure_appcast_monotonic` - block if version exists
