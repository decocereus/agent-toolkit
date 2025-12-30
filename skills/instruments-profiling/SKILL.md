---
name: instruments-profiling
description: Native macOS/iOS app performance profiling via xctrace/Time Profiler and CLI-only analysis. Use when profiling apps, attaching to processes, recording traces, finding hotspots, or analyzing Instruments .trace files without opening the Instruments UI.
---

# Instruments Profiling (CLI)

Profile native macOS/iOS apps using `xctrace` without opening Instruments UI.

## Quick Start

### List Available Templates

```bash
xcrun xctrace list templates
```

Common templates:
- `Time Profiler` - CPU sampling
- `Allocations` - Memory allocations
- `Leaks` - Memory leaks
- `System Trace` - Low-level system events
- `Network` - Network activity

### Record Time Profiler

**Launch and record:**
```bash
xcrun xctrace record \
  --template 'Time Profiler' \
  --time-limit 60s \
  --output /tmp/App.trace \
  --launch -- /path/to/App.app/Contents/MacOS/App
```

**Attach to running process:**
```bash
# Get PID first
pgrep -x "AppName"

# Attach
xcrun xctrace record \
  --template 'Time Profiler' \
  --time-limit 60s \
  --output /tmp/App.trace \
  --attach <pid>
```

### Open in Instruments

```bash
open -a Instruments /tmp/App.trace
```

## Picking the Correct Binary (Critical)

**Gotcha:** Instruments may profile wrong app if multiple versions exist.

### Rules

1. **Prefer direct binary path:**
   ```bash
   --launch -- /path/App.app/Contents/MacOS/App
   ```

2. **Verify process after launch:**
   ```bash
   ps -p <pid> -o comm= -o command=
   ```

3. **If both /Applications and local build exist:**
   - Explicitly target local build path
   - Or kill /Applications version first

4. **For app bundles:**
   ```bash
   open -n /path/App.app  # Force new instance
   ```

## xctrace Command Reference

### Record Options

```bash
xcrun xctrace record \
  --template 'Time Profiler' \    # Template name
  --time-limit 60s \              # Duration (s/m/h)
  --output /tmp/trace.trace \     # Output path
  --launch -- <cmd>               # Launch command
  # OR
  --attach <pid|name>             # Attach to process
  --device <name|UDID>            # iOS device (required for device)
  --target-stdout -               # Stream stdout to terminal
```

### Export Data

```bash
# List available tables
xcrun xctrace export --input /tmp/App.trace --toc

# Export time-profile samples
xcrun xctrace export \
  --input /tmp/App.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="time-profile"]' \
  --output /tmp/time-profile.xml
```

### Help

```bash
xcrun xctrace help record
xcrun xctrace help export
```

Note: `xcrun xctrace --help` is NOT valid. Use `xcrun xctrace help <subcommand>`.

## iOS Device Profiling

### List Devices

```bash
xcrun xctrace list devices
```

### Record on Device

```bash
xcrun xctrace record \
  --template 'Time Profiler' \
  --device "iPhone 16 Pro" \
  --time-limit 60s \
  --output /tmp/App.trace \
  --attach "MyApp"
```

### Via Xcode

1. Build & run in Xcode (debug symbols)
2. Get PID from Xcode or `instruments -s devices`
3. Attach with xctrace

## Simulator Profiling

```bash
# Boot simulator
xcrun simctl boot "iPhone 16 Pro"

# Install app
xcrun simctl install booted /path/to/App.app

# Launch and get PID
xcrun simctl launch booted com.example.app

# Attach
xcrun xctrace record \
  --template 'Time Profiler' \
  --time-limit 30s \
  --output /tmp/sim.trace \
  --attach "AppName"
```

## Instruments UI Tips

When you need to open the trace:

1. **Call Tree view:**
   - Hide System Libraries
   - Invert Call Tree (see callers)
   - Separate by Thread

2. **Focus on:**
   - Hot frames (high sample count)
   - Your app's functions (not system)
   - Time spent in each function

3. **Useful filters:**
   - Focus on subtree (right-click)
   - Charge to callers

## Common Issues

### Wrong App Profiled

**Symptom:** Stacks show wrong binary
**Fix:** Use direct binary path or `--attach` with verified PID

### Empty Trace / No Samples

**Symptom:** Trace has no useful data
**Causes:**
- App exited before capture
- Idle app (no CPU work)
**Fix:** Longer capture, trigger workload during recording

### Permission Denied

**Symptom:** Can't attach to process
**Fix:** System Settings → Privacy & Security → Developer Tools → Allow Terminal/Xcode

### Large XML Exports

**Symptom:** Export is huge
**Fix:** Filter with XPath, aggregate offline, don't print to terminal

## Verification Checklist

- [ ] Process path matches target build
- [ ] Stacks show expected app frames
- [ ] Capture covers slow operation (startup, refresh, etc.)
- [ ] Debug symbols present for meaningful stacks
