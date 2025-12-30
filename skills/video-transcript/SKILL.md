---
name: video-transcript
description: Extract clean transcripts from YouTube videos and other sources. Use when needing video transcripts, subtitles, or captions for summarization, search, or analysis. Complements yt-dlp-expert skill with transcript-focused extraction.
---

# Video Transcript Extraction

Extract clean, readable transcripts from YouTube and other video sources.

## Quick Methods

### Method 1: yt-dlp Subtitles (Preferred)

```bash
# List available subtitles
yt-dlp --list-subs "https://youtube.com/watch?v=VIDEO_ID"

# Download auto-generated subtitles
yt-dlp --write-auto-sub --sub-lang en --skip-download -o "%(title)s" "URL"

# Download manual subtitles if available
yt-dlp --write-sub --sub-lang en --skip-download -o "%(title)s" "URL"

# Convert to plain text (SRT → TXT)
yt-dlp --write-auto-sub --sub-lang en --sub-format srt --skip-download -o "transcript" "URL"
```

### Method 2: YouTube Transcript API

```bash
# Using summarize CLI (if installed)
summarize "https://youtube.com/watch?v=VIDEO_ID"
```

### Method 3: Manual VTT/SRT Processing

```bash
# Download VTT
yt-dlp --write-auto-sub --sub-format vtt --skip-download "URL"

# Convert VTT to clean text
cat transcript.en.vtt | grep -v "^WEBVTT" | grep -v "^Kind:" | grep -v "^Language:" | grep -v "^$" | grep -v "^[0-9]" | grep -v "\-\->" | sort -u
```

## Clean Transcript Script

```bash
#!/bin/bash
# clean-transcript.sh - Convert VTT/SRT to clean paragraphs

input="$1"
output="${2:-transcript.txt}"

# Remove timestamps, metadata, duplicates
cat "$input" | \
  grep -v "^WEBVTT" | \
  grep -v "^Kind:" | \
  grep -v "^Language:" | \
  grep -v "^NOTE" | \
  grep -v "^[0-9][0-9]:[0-9][0-9]" | \
  grep -v "\-\->" | \
  grep -v "^$" | \
  sed 's/<[^>]*>//g' | \
  awk '!seen[$0]++' | \
  tr '\n' ' ' | \
  sed 's/  */ /g' | \
  fold -s -w 80 > "$output"

echo "Cleaned transcript: $output"
```

## Common Patterns

### YouTube Video

```bash
# Get transcript
yt-dlp --write-auto-sub --sub-lang en --sub-format vtt --skip-download \
  -o "%(title)s.%(ext)s" "https://youtube.com/watch?v=VIDEO_ID"

# Clean it
./clean-transcript.sh "Video Title.en.vtt" transcript.txt
```

### Batch Processing

```bash
# Process playlist
yt-dlp --write-auto-sub --sub-lang en --skip-download \
  -o "%(playlist_index)s-%(title)s.%(ext)s" \
  "https://youtube.com/playlist?list=PLAYLIST_ID"
```

### With Timestamps (for reference)

```bash
# Keep timestamps in output
yt-dlp --write-auto-sub --sub-format srt --skip-download "URL"

# SRT format keeps timestamps:
# 1
# 00:00:01,000 --> 00:00:04,000
# Hello and welcome to the video
```

## Subtitle Formats

| Format | Extension | Use Case |
|--------|-----------|----------|
| VTT | .vtt | Web standard, metadata |
| SRT | .srt | Simple, widely supported |
| ASS | .ass | Styled subtitles |
| JSON3 | .json | Programmatic access |

### Convert Between Formats

```bash
# VTT to SRT
yt-dlp --write-auto-sub --sub-format srt --convert-subs srt "URL"

# Get JSON (for programmatic use)
yt-dlp --write-auto-sub --sub-format json3 --skip-download "URL"
```

## Language Options

```bash
# List available languages
yt-dlp --list-subs "URL"

# Specific language
yt-dlp --write-auto-sub --sub-lang es --skip-download "URL"

# Multiple languages
yt-dlp --write-auto-sub --sub-lang en,es,fr --skip-download "URL"

# All available
yt-dlp --write-auto-sub --all-subs --skip-download "URL"
```

## Troubleshooting

### No Subtitles Available

Some videos don't have auto-generated or manual subs:
```bash
# Check what's available
yt-dlp --list-subs "URL"

# Try different source
# Some channels have subs on some videos only
```

### Subtitles in Wrong Language

```bash
# Force specific language
yt-dlp --write-auto-sub --sub-lang en --skip-download "URL"

# Or get all and pick
yt-dlp --all-subs --skip-download "URL"
ls *.vtt
```

### Garbled Auto-Captions

Auto-generated captions can be poor quality. Options:
1. Look for manual subtitles (`--write-sub` instead of `--write-auto-sub`)
2. Use audio transcription (Whisper, etc.)
3. Accept lower quality for the convenience

## Integration with Summarization

```bash
# Extract transcript then summarize
yt-dlp --write-auto-sub --sub-format vtt --skip-download -o "video" "URL"
./clean-transcript.sh video.en.vtt transcript.txt

# If using summarize CLI
summarize transcript.txt
```
