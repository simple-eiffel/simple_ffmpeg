# S04-FEATURE-SPECS.md
## simple_ffmpeg - Feature Specifications

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. SIMPLE_FFMPEG Facade Features

### 1.1 Status Queries

#### is_available
**Signature:** `: BOOLEAN`
**Purpose:** Check if ffmpeg.exe is in system PATH
**Implementation:** Delegates to `cli.is_available`

#### has_error
**Signature:** `: BOOLEAN`
**Purpose:** Check if last operation failed
**Implementation:** Delegates to `cli.has_error`

#### last_error
**Signature:** `: detachable STRING_32`
**Purpose:** Get error message from last failed operation

#### version
**Signature:** `: STRING_32`
**Purpose:** Get FFmpeg version string
**Returns:** Version string or "unknown"

### 1.2 Media Probing

#### probe
**Signature:** `(a_file: READABLE_STRING_GENERAL): detachable FFMPEG_MEDIA_INFO`
**Purpose:** Get media file metadata
**Implementation:**
1. Executes `ffprobe -v quiet -print_format json -show_format -show_streams`
2. Parses JSON output
3. Populates FFMPEG_MEDIA_INFO

**Returned Information:**
- Duration, file size, bit rate
- Video: codec, resolution, frame rate
- Audio: codec, sample rate, channels
- Metadata: title, artist, album

### 1.3 Transcoding

#### transcode
**Signature:** `(a_input, a_output: READABLE_STRING_GENERAL): BOOLEAN`
**Purpose:** Convert media file with default settings
**Implementation:**
1. Executes `ffmpeg -i input -y output`
2. FFmpeg auto-detects output format from extension

**Defaults:**
- Video: libx264, 2 Mbps
- Audio: AAC, 128 kbps

#### transcode_with_options
**Signature:** `(a_input, a_output: READABLE_STRING_GENERAL; a_options: FFMPEG_OPTIONS): BOOLEAN`
**Purpose:** Convert with custom encoding options
**Implementation:** Builds command line from FFMPEG_OPTIONS

### 1.4 Audio Operations

#### extract_audio
**Signature:** `(a_video, a_audio: READABLE_STRING_GENERAL): BOOLEAN`
**Purpose:** Extract audio track from video file
**Implementation:**
1. Executes `ffmpeg -i video -vn -acodec copy audio`
2. Copies audio stream without re-encoding

**Use Cases:**
- Extract MP3 from video
- Get WAV from MP4
- Separate audio for editing

### 1.5 Video Operations

#### extract_frame
**Signature:** `(a_video: READABLE_STRING_GENERAL; a_time: REAL_64; a_output: READABLE_STRING_GENERAL): BOOLEAN`
**Purpose:** Extract single frame as image
**Parameters:**
- `a_time`: Timestamp in seconds (e.g., 5.0 for 5 seconds)
**Implementation:**
1. Executes `ffmpeg -ss time -i video -frames:v 1 output.jpg`

**Supported Output Formats:**
- JPEG (.jpg)
- PNG (.png)
- BMP (.bmp)

#### resize_video
**Signature:** `(a_input, a_output: READABLE_STRING_GENERAL; a_width, a_height: INTEGER): BOOLEAN`
**Purpose:** Resize video to specified dimensions
**Implementation:**
1. Executes `ffmpeg -i input -vf scale=width:height output`

#### images_to_video
**Signature:** `(a_pattern, a_output: READABLE_STRING_GENERAL; a_fps: INTEGER): BOOLEAN`
**Purpose:** Create video from image sequence
**Parameters:**
- `a_pattern`: printf-style pattern (e.g., "frames/frame_%05d.bmp")
- `a_fps`: Frames per second
**Implementation:**
1. Executes `ffmpeg -framerate fps -i pattern -c:v libx264 output`

**Example:**
```eiffel
ffmpeg.images_to_video ("frames/frame_%05d.bmp", "output.mp4", 60)
```

#### images_to_video_with_options
**Signature:** `(...; a_options: FFMPEG_OPTIONS): BOOLEAN`
**Purpose:** Create video from images with custom encoding

---

## 2. FFMPEG_OPTIONS Features

### 2.1 Default Values

| Option | Default Value |
|--------|---------------|
| `video_codec` | "libx264" |
| `audio_codec` | "aac" |
| `video_bitrate` | 2,000,000 bps |
| `audio_bitrate` | 128,000 bps |

### 2.2 Fluent Builder Pattern

All setters return `like Current` for chaining:

```eiffel
options := (create {FFMPEG_OPTIONS}.make)
    .set_video_codec ("libx265")
    .set_resolution (1920, 1080)
    .set_video_bitrate (5_000_000)
    .set_audio_codec ("aac")
    .set_audio_bitrate (192_000)
```

### 2.3 Presets

#### preset_fast
- Video: libx264 with fast preset
- Suitable for quick conversions

#### preset_quality
- Video: libx264, 5 Mbps
- Audio: AAC, 192 kbps
- Suitable for archival

#### preset_web
- Resolution: 1280x720 (720p)
- Video: libx264, 2.5 Mbps
- Audio: AAC, 128 kbps
- Suitable for web streaming

### 2.4 Stream Operations

#### copy_video / copy_audio
**Purpose:** Copy stream without re-encoding
**Implementation:** Sets codec to "copy"
**Use Case:** Fast format conversion, preserving quality

#### disable_video / disable_audio
**Purpose:** Remove stream from output
**Implementation:** Sets no_video/no_audio flag
**Use Case:** Extract audio only, create silent video

---

## 3. FFMPEG_MEDIA_INFO Features

### 3.1 General Information

| Feature | Type | Description |
|---------|------|-------------|
| `filename` | STRING_32 | Source file name |
| `format_name` | STRING_32 | Container format (mp4, mkv, avi) |
| `duration` | REAL_64 | Length in seconds |
| `size` | INTEGER_64 | File size in bytes |
| `bit_rate` | INTEGER | Overall bit rate (bps) |
| `stream_count` | INTEGER | Number of streams |

### 3.2 Video Information

| Feature | Type | Description |
|---------|------|-------------|
| `has_video` | BOOLEAN | Contains video stream |
| `video_codec` | STRING_32 | Codec name (h264, hevc) |
| `video_width` | INTEGER | Width in pixels |
| `video_height` | INTEGER | Height in pixels |
| `video_frame_rate` | REAL_64 | FPS |
| `video_bit_rate` | INTEGER | Video bit rate (bps) |
| `resolution_string` | STRING_32 | "WxH" format |

### 3.3 Audio Information

| Feature | Type | Description |
|---------|------|-------------|
| `has_audio` | BOOLEAN | Contains audio stream |
| `audio_codec` | STRING_32 | Codec name (aac, mp3) |
| `audio_sample_rate` | INTEGER | Sample rate (Hz) |
| `audio_channels` | INTEGER | Channel count |
| `audio_bit_rate` | INTEGER | Audio bit rate (bps) |

### 3.4 Metadata

| Feature | Type | Description |
|---------|------|-------------|
| `title` | STRING_32 | Title tag |
| `artist` | STRING_32 | Artist tag |
| `album` | STRING_32 | Album tag |
