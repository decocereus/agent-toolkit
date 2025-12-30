---
name: xcode-project
description: Xcode project management, builds, and simulator control. Use when building iOS/macOS apps, managing simulators, running tests, generating projects with xcodegen, troubleshooting build issues, or working with code signing. Covers xcodebuild, xcrun simctl, xcodegen, and common configurations.
---

# Xcode Project Management

## xcodebuild Commands

### Build

```bash
# Build for simulator
xcodebuild \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Build for device (requires signing)
xcodebuild \
  -scheme MyApp \
  -destination 'generic/platform=iOS' \
  build

# Build with configuration
xcodebuild \
  -scheme MyApp \
  -configuration Release \
  build

# Build workspace (CocoaPods, SPM)
xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  build
```

### Test

```bash
# Run unit tests
xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run specific test
xcodebuild test \
  -scheme MyApp \
  -only-testing:MyAppTests/UserTests/testCreation \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Parallel testing
xcodebuild test \
  -scheme MyApp \
  -parallel-testing-enabled YES \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# With code coverage
xcodebuild test \
  -scheme MyApp \
  -enableCodeCoverage YES \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Archive & Export

```bash
# Create archive
xcodebuild archive \
  -scheme MyApp \
  -archivePath ./build/MyApp.xcarchive \
  -destination 'generic/platform=iOS'

# Export IPA (Ad Hoc)
xcodebuild -exportArchive \
  -archivePath ./build/MyApp.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

**ExportOptions.plist:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

### Clean

```bash
xcodebuild clean -scheme MyApp
```

### Pretty Output

```bash
# Install xcbeautify
brew install xcbeautify

# Use with xcodebuild
xcodebuild build -scheme MyApp 2>&1 | xcbeautify
```

## Simulator Management (xcrun simctl)

### List Devices

```bash
# All devices
xcrun simctl list devices

# Available only
xcrun simctl list devices available

# JSON format
xcrun simctl list devices -j
```

### Boot & Shutdown

```bash
# Boot by name
xcrun simctl boot "iPhone 16 Pro"

# Boot by UDID
xcrun simctl boot 420A314B-093F-4B14-9D4C-FDA9775D0882

# Shutdown
xcrun simctl shutdown booted

# Shutdown all
xcrun simctl shutdown all
```

### Install & Launch Apps

```bash
# Install
xcrun simctl install booted /path/to/App.app

# Launch
xcrun simctl launch booted com.example.myapp

# Launch with arguments
xcrun simctl launch booted com.example.myapp --argument1 value1

# Terminate
xcrun simctl terminate booted com.example.myapp

# Uninstall
xcrun simctl uninstall booted com.example.myapp
```

### Screenshots & Video

```bash
# Screenshot
xcrun simctl io booted screenshot screenshot.png

# Record video
xcrun simctl io booted recordVideo video.mp4
# Press Ctrl+C to stop

# Open URL
xcrun simctl openurl booted "https://example.com"
```

### Device Management

```bash
# Create new simulator
xcrun simctl create "My iPhone" "iPhone 16 Pro" iOS18.4

# Delete simulator
xcrun simctl delete "My iPhone"

# Erase (reset to clean state)
xcrun simctl erase booted

# Clone
xcrun simctl clone "iPhone 16 Pro" "iPhone 16 Pro Clone"
```

### Privacy & Permissions

```bash
# Grant permission
xcrun simctl privacy booted grant photos com.example.myapp
xcrun simctl privacy booted grant camera com.example.myapp
xcrun simctl privacy booted grant location com.example.myapp

# Revoke
xcrun simctl privacy booted revoke all com.example.myapp

# Reset all
xcrun simctl privacy booted reset all
```

### Push Notifications

```bash
# Send push notification
xcrun simctl push booted com.example.myapp payload.json
```

**payload.json:**
```json
{
  "aps": {
    "alert": {
      "title": "Test",
      "body": "Hello from simulator"
    }
  }
}
```

## xcodegen

Generate Xcode projects from YAML spec.

### Install

```bash
brew install xcodegen
```

### Basic project.yml

```yaml
name: MyApp
options:
  bundleIdPrefix: com.example
  deploymentTarget:
    iOS: "17.0"

targets:
  MyApp:
    type: application
    platform: iOS
    sources:
      - MyApp
    settings:
      PRODUCT_BUNDLE_IDENTIFIER: com.example.myapp
      INFOPLIST_FILE: MyApp/Info.plist
      DEVELOPMENT_TEAM: YOUR_TEAM_ID
    dependencies:
      - package: Alamofire
      - target: MyAppKit

  MyAppKit:
    type: framework
    platform: iOS
    sources:
      - MyAppKit

  MyAppTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - MyAppTests
    dependencies:
      - target: MyApp

packages:
  Alamofire:
    url: https://github.com/Alamofire/Alamofire
    from: "5.0.0"

schemes:
  MyApp:
    build:
      targets:
        MyApp: all
    run:
      config: Debug
    test:
      config: Debug
      targets:
        - MyAppTests
```

### Generate

```bash
xcodegen generate
```

## Code Signing

### Automatic Signing

In Xcode or xcodebuild:
```bash
xcodebuild \
  -scheme MyApp \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
  build
```

### Manual Signing

```bash
xcodebuild \
  -scheme MyApp \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  PROVISIONING_PROFILE_SPECIFIER="MyApp Distribution" \
  build
```

### List Certificates

```bash
security find-identity -v -p codesigning
```

### List Provisioning Profiles

```bash
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

## Build Settings

### Common Settings

| Setting | Description |
|---------|-------------|
| `PRODUCT_BUNDLE_IDENTIFIER` | Bundle ID |
| `MARKETING_VERSION` | Version (1.0.0) |
| `CURRENT_PROJECT_VERSION` | Build number |
| `DEVELOPMENT_TEAM` | Team ID |
| `CODE_SIGN_IDENTITY` | Certificate name |
| `SWIFT_VERSION` | Swift version |
| `IPHONEOS_DEPLOYMENT_TARGET` | Min iOS version |

### Override via CLI

```bash
xcodebuild \
  -scheme MyApp \
  MARKETING_VERSION=1.2.0 \
  CURRENT_PROJECT_VERSION=42 \
  build
```

### Query Settings

```bash
xcodebuild -scheme MyApp -showBuildSettings | grep PRODUCT_BUNDLE_IDENTIFIER
```

## Troubleshooting

### Clean Build Folder

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

### Reset Simulators

```bash
xcrun simctl erase all
```

### Clear Xcode Caches

```bash
rm -rf ~/Library/Caches/com.apple.dt.Xcode
```

### Check SDK

```bash
xcodebuild -showsdks
```

### Find Scheme Names

```bash
xcodebuild -list
```

### Verbose Build

```bash
xcodebuild -scheme MyApp build -verbose
```
