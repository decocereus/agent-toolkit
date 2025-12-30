---
name: browser-tools
description: Chrome DevTools automation for web scraping, testing, and content extraction without MCP. Use when scraping websites, capturing screenshots, extracting readable content as markdown, running JavaScript in pages, monitoring console logs, or automating browser interactions.
---

# Browser Tools

Lightweight Chrome DevTools helpers via CDP (no MCP required).

## Quick Start

```bash
# Start Chrome with debugging
browser-tools start

# Navigate
browser-tools nav https://example.com

# Extract content as markdown
browser-tools content https://example.com

# Screenshot
browser-tools screenshot

# Google search
browser-tools search "query" -n 5 --content
```

## Commands

### start

Launch Chrome with remote debugging enabled.

```bash
browser-tools start
browser-tools start --port 9222
browser-tools start --profile          # Copy your Chrome profile
browser-tools start --kill-existing    # Kill existing Chrome first
```

Options:
- `-p, --port <number>`: Debug port (default: 9222)
- `--profile`: Copy default Chrome profile before launch
- `--profile-dir <path>`: Custom profile directory
- `--chrome-path <path>`: Custom Chrome binary path
- `--kill-existing`: Kill running Chrome instances first

### nav

Navigate current tab or open new tab.

```bash
browser-tools nav https://example.com
browser-tools nav https://example.com --new    # New tab
```

### eval

Run JavaScript in the active page.

```bash
browser-tools eval "document.title"
browser-tools eval "document.querySelectorAll('a').length"
browser-tools eval "[...document.querySelectorAll('h1')].map(h => h.textContent)"
browser-tools eval "await fetch('/api/data').then(r => r.json())" --pretty-print
```

Options:
- `--pretty-print`: Format output with indentation

### screenshot

Capture viewport as PNG.

```bash
browser-tools screenshot
# Outputs: /var/folders/.../screenshot-2024-12-30T12-00-00.png
```

### pick

Interactive DOM picker - click elements to get metadata.

```bash
browser-tools pick "Select the login button"
```

- Hover highlights elements
- Click to select
- Cmd/Ctrl+click for multi-select
- Enter to confirm selection
- ESC to cancel

Returns: tag, id, class, text, html snippet, parent chain

### console

Capture console logs from active tab.

```bash
browser-tools console                    # 5 second capture
browser-tools console --timeout 30       # 30 seconds
browser-tools console --follow           # Continuous (Ctrl+C to stop)
browser-tools console --types error,warn # Filter by type
```

Options:
- `--timeout <seconds>`: Capture duration (default: 5)
- `--follow`: Continuous monitoring
- `--types <list>`: Filter by log types (log,error,warn,info,debug)
- `--color / --no-color`: Force color output
- `--no-serialize`: Show raw text only

### search

Google search with optional content extraction.

```bash
browser-tools search "SwiftUI state management"
browser-tools search "react hooks" -n 10
browser-tools search "node.js streams" --content   # Extract full content
```

Options:
- `-n, --count <number>`: Results to return (default: 5, max: 50)
- `--content`: Fetch readable content for each result
- `--timeout <seconds>`: Per-page timeout (default: 10)

### content

Extract readable content from URL as markdown.

```bash
browser-tools content https://example.com/article
```

Uses Mozilla Readability + Turndown for clean markdown output.

Options:
- `--timeout <seconds>`: Navigation timeout (default: 10)

### cookies

Dump cookies from active tab as JSON.

```bash
browser-tools cookies
browser-tools cookies > cookies.json
```

### inspect

List Chrome instances with DevTools ports.

```bash
browser-tools inspect
browser-tools inspect --json
browser-tools inspect --ports 9222,9223
browser-tools inspect --pids 12345
```

Shows: PID, port, Chrome version, open tabs

### kill

Terminate Chrome instances with DevTools ports.

```bash
browser-tools kill --all              # All instances
browser-tools kill --ports 9222       # Specific port
browser-tools kill --pids 12345       # Specific PID
browser-tools kill --all --force      # Skip confirmation
```

## Common Workflows

### Web Scraping

```bash
browser-tools start
browser-tools nav "https://example.com/products"

# Extract data
browser-tools eval "[...document.querySelectorAll('.product')].map(p => ({
  name: p.querySelector('h2').textContent,
  price: p.querySelector('.price').textContent
}))" --pretty-print
```

### Testing / Debugging

```bash
browser-tools start
browser-tools nav "http://localhost:3000"
browser-tools console --follow   # Watch for errors
```

### Content Research

```bash
browser-tools start
browser-tools search "topic" -n 5 --content > research.md
```

## Troubleshooting

### "No active tab found"

Chrome hasn't finished starting or no tabs open.
```bash
browser-tools start --kill-existing
```

### "Failed to start Chrome"

Port already in use or Chrome path wrong.
```bash
browser-tools kill --all
browser-tools start
```

### Content extraction empty

Page uses heavy JS or requires auth.
```bash
# Wait for JS to load
browser-tools nav "https://example.com"
sleep 3
browser-tools content "https://example.com"
```
