---
name: ffmpeg-expert
description: Expert FFmpeg knowledge for video/audio processing. Use when encoding, transcoding, remuxing, extracting audio, generating HLS streams, creating thumbnails, cutting/trimming, concatenating, applying filters, or debugging FFmpeg issues. Covers codec selection, format containers, streaming outputs, pipe/stdin/stdout operations, and Node.js spawn integration.
---

# FFmpeg Expert

Comprehensive FFmpeg knowledge for video/audio processing.

## Command Structure

```bash
ffmpeg [global_options] {[input_options] -i input} ... {[output_options] output} ...
```

Key principle: Options apply to the NEXT file (input or output).

## Common Operations

### Remux (Change Container, No Re-encode)

```bash
# MKV to MP4
ffmpeg -i input.mkv -c copy output.mp4

# TS to MP4
ffmpeg -i input.ts -c copy output.mp4

# WebM to MP4 (may need re-encode if codecs incompatible)
ffmpeg -i input.webm -c:v libx264 -c:a aac output.mp4
```

### Transcode (Re-encode)

```bash
# H.264 + AAC (most compatible)
ffmpeg -i input.mp4 -c:v libx264 -preset fast -crf 23 -c:a aac -b:a 128k output.mp4

# H.265/HEVC (better compression)
ffmpeg -i input.mp4 -c:v libx265 -preset medium -crf 28 -c:a aac output.mp4

# VP9 + Opus (WebM)
ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus output.webm
```

### Quality Settings

**CRF (Constant Rate Factor)**: Lower = better quality, larger file
- H.264: 18 (visually lossless) - 23 (default) - 28 (lower quality)
- H.265: 24 (visually lossless) - 28 (default) - 32 (lower quality)

**Presets**: Speed vs compression tradeoff
- `ultrafast`, `superfast`, `veryfast`, `faster`, `fast`, `medium`, `slow`, `slower`, `veryslow`

### Resolution Scaling

```bash
# Scale to 720p (maintain aspect ratio)
ffmpeg -i input.mp4 -vf "scale=-2:720" output.mp4

# Scale to 1080p width
ffmpeg -i input.mp4 -vf "scale=1920:-2" output.mp4

# Exact dimensions (may distort)
ffmpeg -i input.mp4 -vf "scale=1280:720" output.mp4

# Scale with padding (letterbox)
ffmpeg -i input.mp4 -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" output.mp4
```

## Audio Operations

### Extract Audio

```bash
# Extract as MP3
ffmpeg -i input.mp4 -vn -c:a libmp3lame -b:a 192k output.mp3

# Extract as AAC
ffmpeg -i input.mp4 -vn -c:a aac -b:a 128k output.m4a

# Extract as WAV (uncompressed)
ffmpeg -i input.mp4 -vn -c:a pcm_s16le output.wav

# Copy audio stream (no re-encode)
ffmpeg -i input.mp4 -vn -c:a copy output.aac
```

### Audio Conversion

```bash
# Mono, 16kHz (for speech recognition)
ffmpeg -i input.mp4 -vn -ac 1 -ar 16000 -c:a pcm_s16le output.wav

# Stereo, 44.1kHz
ffmpeg -i input.mp4 -vn -ac 2 -ar 44100 -c:a aac output.m4a
```

## Cutting & Trimming

```bash
# Cut from timestamp (fast, may be inaccurate)
ffmpeg -ss 00:01:00 -i input.mp4 -t 00:00:30 -c copy output.mp4

# Cut with re-encode (accurate)
ffmpeg -i input.mp4 -ss 00:01:00 -t 00:00:30 -c:v libx264 -c:a aac output.mp4

# Cut to end
ffmpeg -ss 00:01:00 -i input.mp4 -c copy output.mp4

# Using seconds
ffmpeg -ss 60 -i input.mp4 -t 30 -c copy output.mp4
```

**IMPORTANT**: `-ss` before `-i` (input seeking) is faster but less accurate. `-ss` after `-i` is slower but frame-accurate.

## HLS (HTTP Live Streaming)

### Generate HLS from Video

```bash
ffmpeg -i input.mp4 \
  -c:v libx264 -preset fast -crf 23 \
  -c:a aac -b:a 128k \
  -f hls \
  -hls_time 4 \
  -hls_playlist_type vod \
  -hls_segment_filename "segment%03d.ts" \
  playlist.m3u8
```

### HLS Options

```bash
-hls_time 4              # Segment duration (seconds)
-hls_list_size 0         # Keep all segments in playlist
-hls_playlist_type vod   # VOD playlist (all segments listed)
-hls_playlist_type event # Live playlist (append only)
-hls_segment_type mpegts # TS segments (default)
-hls_segment_type fmp4   # Fragmented MP4 segments
-hls_flags delete_segments  # Delete old segments
-hls_flags independent_segments  # Each segment can be decoded independently
```

### Multi-Quality HLS (ABR)

```bash
ffmpeg -i input.mp4 \
  -filter_complex "[0:v]split=3[v1][v2][v3]; \
    [v1]scale=-2:720[v720]; \
    [v2]scale=-2:480[v480]; \
    [v3]scale=-2:360[v360]" \
  -map "[v720]" -c:v:0 libx264 -b:v:0 2500k \
  -map "[v480]" -c:v:1 libx264 -b:v:1 1000k \
  -map "[v360]" -c:v:2 libx264 -b:v:2 500k \
  -map a:0 -c:a aac -b:a 128k \
  -f hls -hls_time 4 \
  -master_pl_name master.m3u8 \
  -var_stream_map "v:0,a:0 v:1,a:0 v:2,a:0" \
  stream_%v.m3u8
```

## Streaming to stdout

### For Piping to Cloud Storage

```bash
# MP4 to stdout (CRITICAL: use movflags for non-seekable output)
ffmpeg -i input.ts -c:v libx264 -c:a aac \
  -movflags +frag_keyframe+empty_moov+default_base_moof \
  -f mp4 pipe:1

# TS to stdout
ffmpeg -i input.mp4 -c copy -f mpegts pipe:1

# Audio to stdout
ffmpeg -i input.mp4 -vn -c:a pcm_s16le -f wav pipe:1
```

**CRITICAL**: For MP4 output to non-seekable destinations (stdout, pipes), you MUST use:
```
-movflags +frag_keyframe+empty_moov+default_base_moof
```

### Reading from stdin

```bash
# From pipe
cat input.ts | ffmpeg -i pipe:0 -c copy output.mp4

# From stdin with format hint
ffmpeg -f mpegts -i pipe:0 -c copy output.mp4
```

## Node.js Integration

### Basic Spawn

```typescript
import { spawn } from 'child_process';

const ffmpeg = spawn('ffmpeg', [
  '-i', 'input.mp4',
  '-c:v', 'libx264',
  '-c:a', 'aac',
  'output.mp4'
]);

ffmpeg.stderr.on('data', (data) => {
  console.log('FFmpeg:', data.toString());
});

ffmpeg.on('close', (code) => {
  console.log('Exit code:', code);
});
```

### Streaming with Pipes

```typescript
import { spawn } from 'child_process';
import { pipeline } from 'stream/promises';
import { createReadStream, createWriteStream } from 'fs';

const ffmpeg = spawn('ffmpeg', [
  '-i', 'pipe:0',           // Read from stdin
  '-c:v', 'libx264',
  '-c:a', 'aac',
  '-movflags', '+frag_keyframe+empty_moov+default_base_moof',
  '-f', 'mp4',
  'pipe:1'                  // Write to stdout
]);

// Pipe input to FFmpeg
const inputStream = createReadStream('input.ts');
inputStream.pipe(ffmpeg.stdin);

// Pipe FFmpeg output to destination
const outputStream = createWriteStream('output.mp4');
ffmpeg.stdout.pipe(outputStream);

// Handle stderr (progress info)
let stderrBuffer = '';
ffmpeg.stderr.on('data', (data) => {
  stderrBuffer += data.toString();
  // Parse progress: "time=00:01:23.45"
  const match = data.toString().match(/time=(\d+:\d+:\d+\.\d+)/);
  if (match) {
    console.log('Progress:', match[1]);
  }
});
```

### With Bounded Buffers (Memory Safety)

```typescript
const MAX_STDERR_SIZE = 100 * 1024; // 100KB
let stderrOutput = '';
let stderrTruncated = false;

ffmpeg.stderr.on('data', (data: Buffer) => {
  if (stderrTruncated) return;

  const text = data.toString();
  if (stderrOutput.length + text.length > MAX_STDERR_SIZE) {
    stderrOutput += text.slice(0, MAX_STDERR_SIZE - stderrOutput.length);
    stderrOutput += '\n... [truncated]';
    stderrTruncated = true;
  } else {
    stderrOutput += text;
  }
});
```

## Thumbnails

### Single Thumbnail

```bash
# At specific time
ffmpeg -i input.mp4 -ss 00:00:10 -vframes 1 thumb.jpg

# Best quality
ffmpeg -i input.mp4 -ss 10 -vframes 1 -q:v 2 thumb.jpg
```

### Multiple Thumbnails

```bash
# Every N seconds
ffmpeg -i input.mp4 -vf "fps=1/10" thumb_%04d.jpg

# Specific number of thumbnails
ffmpeg -i input.mp4 -vf "select='not(mod(n,100))'" -vsync vfr thumb_%04d.jpg

# Thumbnail sheet/sprite
ffmpeg -i input.mp4 -vf "fps=1/10,scale=160:-1,tile=10x10" sprite.jpg
```

## Filters

### Video Filters (-vf)

```bash
# Multiple filters (comma-separated)
ffmpeg -i input.mp4 -vf "scale=1280:720,fps=30" output.mp4

# Crop
-vf "crop=640:480:100:50"  # width:height:x:y

# Pad
-vf "pad=1920:1080:(ow-iw)/2:(oh-ih)/2:black"

# Rotate
-vf "transpose=1"  # 90° clockwise
-vf "transpose=2"  # 90° counter-clockwise

# Overlay (watermark)
-vf "overlay=10:10"

# Deinterlace
-vf "yadif"
```

### Audio Filters (-af)

```bash
# Volume adjustment
-af "volume=2.0"     # Double volume
-af "volume=-3dB"    # Reduce by 3dB

# Normalize
-af "loudnorm"

# Fade
-af "afade=t=in:st=0:d=3"   # 3s fade in
-af "afade=t=out:st=57:d=3" # 3s fade out at 57s
```

## Concatenation

### Concat Demuxer (same codecs)

```bash
# Create file list
echo "file 'input1.mp4'" > list.txt
echo "file 'input2.mp4'" >> list.txt

# Concatenate
ffmpeg -f concat -safe 0 -i list.txt -c copy output.mp4
```

### Concat Filter (different codecs/formats)

```bash
ffmpeg -i input1.mp4 -i input2.mp4 \
  -filter_complex "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" \
  output.mp4
```

## Debugging

### Verbose Output

```bash
# Show all options
ffmpeg -h full

# Show format info
ffmpeg -i input.mp4

# Show available codecs
ffmpeg -codecs

# Show available formats
ffmpeg -formats

# Debug logging
ffmpeg -loglevel debug -i input.mp4 output.mp4
```

### Common Issues

**"moov atom not found"**: File is incomplete or corrupt
```bash
# Try to recover
ffmpeg -i broken.mp4 -c copy -movflags faststart fixed.mp4
```

**"Non-monotonous DTS"**: Timestamp issues
```bash
# Fix timestamps
ffmpeg -fflags +genpts -i input.mp4 -c copy output.mp4
```

**"Too many packets buffered"**: Memory issues with streaming
```bash
# Limit buffer
ffmpeg -max_muxing_queue_size 1024 -i input.mp4 output.mp4
```

## Performance Tips

1. **Use hardware acceleration** when available:
   ```bash
   # NVIDIA
   ffmpeg -hwaccel cuda -i input.mp4 -c:v h264_nvenc output.mp4

   # macOS
   ffmpeg -hwaccel videotoolbox -i input.mp4 -c:v h264_videotoolbox output.mp4
   ```

2. **Use `-threads` for multi-core**:
   ```bash
   ffmpeg -threads 4 -i input.mp4 -c:v libx264 output.mp4
   ```

3. **Use `-preset ultrafast` for speed over compression**

4. **Use `-c copy` when possible** to avoid re-encoding

5. **Place `-ss` before `-i`** for faster seeking (less accurate)
