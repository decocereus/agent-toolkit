---
name: yt-dlp-expert
description: Expert-level yt-dlp knowledge for video/audio downloading. Use when working with yt-dlp commands, format selection, extractor arguments, YouTube downloads, HLS/DASH streams, cookies, authentication, throttling workarounds, or debugging download issues. Covers all yt-dlp options, output templates, format filtering/sorting, post-processing, and YouTube-specific extractor arguments (player_client, po_token, etc.).
---

# yt-dlp Expert

Comprehensive yt-dlp knowledge for downloading video/audio from YouTube and thousands of other sites.

## Quick Reference

### Format Selection Essentials

```bash
# Best quality (default)
yt-dlp -f "bv*+ba/b" URL

# Specific resolution with codec preference
yt-dlp -f "bv*[height<=1080][vcodec^=avc]+ba[acodec^=mp4a]/b" URL

# Best MP4
yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" URL

# Audio only (best quality)
yt-dlp -f "ba" -x --audio-format mp3 URL

# List available formats
yt-dlp -F URL
```

### Format Specifiers
- `b/best` - Best combined (video+audio)
- `bv/bestvideo` - Best video-only
- `ba/bestaudio` - Best audio-only
- `bv*` - Best with video (may include audio)
- `ba*` - Best with audio (may include video)
- `w/worst`, `wv`, `wa` - Worst quality variants

### Format Sorting (-S)
```bash
# Prefer h264, max 1080p, best audio
yt-dlp -S "vcodec:h264,res:1080,acodec:aac" URL

# Smallest file
yt-dlp -S "+size,+br" URL

# Prefer specific resolution
yt-dlp -S "res:720" URL  # Largest up to 720p
```

Sort fields: `res`, `fps`, `vcodec`, `acodec`, `ext`, `size`, `br`, `tbr`, `vbr`, `abr`, `asr`, `proto`, `hdr`, `channels`

### Format Filtering
```bash
# Height filter
-f "bv[height<=720]+ba/b"

# Codec filter
-f "bv[vcodec^=avc]+ba"  # h264 only

# Protocol filter
-f "(bv*+ba/b)[protocol^=http]"  # Direct HTTP only
```

Filter operators: `=`, `!=`, `<`, `<=`, `>`, `>=`, `^=` (starts), `$=` (ends), `*=` (contains), `~=` (regex)

## YouTube-Specific

### Player Clients (--extractor-args)
```bash
# Default clients (recommended)
--extractor-args "youtube:player_client=tv,android_sdkless,web"

# For throttled downloads
--extractor-args "youtube:player_client=android_sdkless,web"

# For age-restricted
--extractor-args "youtube:player_client=tv_embedded,web_creator"
```

Available clients: `web`, `web_safari`, `web_embedded`, `web_music`, `web_creator`, `mweb`, `ios`, `android`, `android_sdkless`, `android_vr`, `tv`, `tv_simply`, `tv_downgraded`, `tv_embedded`

### Throttling Workarounds
```bash
# Concurrent fragments
-N 16 --concurrent-fragments 16

# Throttle detection
--throttled-rate 100K

# Use specific downloader
--downloader aria2c
--downloader-args "aria2c:-x 16 -s 16"

# Impersonation (requires curl_cffi)
--impersonate chrome
```

### Cookies & Authentication
```bash
# Netscape cookies file
--cookies cookies.txt

# Browser cookies
--cookies-from-browser chrome

# For premium content
--cookies cookies.txt --extractor-args "youtube:player_client=tv_downgraded,web_creator"
```

### PO Token (Proof of Origin)
```bash
--extractor-args "youtube:po_token=web.gvs+TOKEN_HERE"
```

## Download Options

### Output Templates
```bash
# Basic
-o "%(title)s.%(ext)s"

# With metadata
-o "%(uploader)s/%(title)s [%(id)s].%(ext)s"

# Playlist
-o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"
```

Common fields: `id`, `title`, `ext`, `uploader`, `channel`, `upload_date`, `duration`, `view_count`, `playlist`, `playlist_index`

### HLS/DASH Downloads
```bash
# Prefer native HLS
--downloader "m3u8:native"

# Use ffmpeg for HLS
--downloader "m3u8:ffmpeg"

# Skip fragments on error
--skip-unavailable-fragments
```

### Retries & Timeouts
```bash
--retries 10
--fragment-retries 10
--retry-sleep linear=1::2
--socket-timeout 30
```

## Post-Processing

### Remux/Recode
```bash
# Remux to MP4
--remux-video mp4

# Force MP4 container
--merge-output-format mp4

# Extract audio
-x --audio-format mp3 --audio-quality 0
```

### FFmpeg Integration
```bash
# Pass args to ffmpeg
--postprocessor-args "ffmpeg:-c:v libx264 -preset fast"

# Specific position args
--postprocessor-args "Merger+ffmpeg_i1:-ss 10"
```

## Debugging

```bash
# Verbose output
-v --print-traffic

# Dump JSON info
-j --no-simulate

# Write pages for debugging
--dump-pages
--write-pages
```

## Common Patterns

### Download Strategy Order (for reliability)
1. Try default clients
2. Try HLS native if throttled
3. Increase concurrent fragments
4. Use impersonation
5. Try different player clients

### Datacenter IP Workarounds
- Use `--proxy` with residential proxy
- Impersonate browser: `--impersonate chrome`
- Multiple concurrent fragments: `-N 16`
- Throttle detection: `--throttled-rate 100K`

## Reference

For complete documentation including all options, output template fields, and extractor arguments, see:
- [references/yt-dlp-docs.md](references/yt-dlp-docs.md) - Full yt-dlp documentation

Key sections in docs:
- Format Selection: Search "FORMAT SELECTION"
- Output Templates: Search "OUTPUT TEMPLATE"
- Extractor Arguments: Search "EXTRACTOR ARGUMENTS"
- YouTube options: Search "#### youtube"
