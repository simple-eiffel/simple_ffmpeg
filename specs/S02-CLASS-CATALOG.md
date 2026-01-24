# S02-CLASS-CATALOG.md
## simple_ffmpeg - Class Catalog

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Class Hierarchy

```
SIMPLE_FFMPEG (facade)
    |
    +-- FFMPEG_CLI (CLI backend)

FFMPEG_OPTIONS (configuration)

FFMPEG_ENCODER_OPTIONS (encoder config)

FFMPEG_MEDIA_INFO (metadata)

FFMPEG_DECODER (SDK mode)
    |
    +-- uses FFMPEG_FRAME
            |
            +-- FFMPEG_VIDEO_FRAME
            +-- FFMPEG_AUDIO_FRAME

FFMPEG_ENCODER (SDK mode)

FFMPEG_TRANSCODER (SDK mode)
```

## 2. Class Descriptions

### 2.1 SIMPLE_FFMPEG (Facade)

**Purpose:** Main entry point for FFmpeg operations via CLI backend.

**Creation:** `make`

**Status:**
- `is_available: BOOLEAN` - Is ffmpeg.exe in PATH?
- `has_error: BOOLEAN` - Did last operation fail?
- `last_error: detachable STRING_32` - Error message
- `version: STRING_32` - FFmpeg version string

**Metadata:**
- `probe (file): detachable FFMPEG_MEDIA_INFO` - Get media info

**Transcoding:**
- `transcode (input, output): BOOLEAN` - Convert with defaults
- `transcode_with_options (input, output, options): BOOLEAN` - Convert with options

**Audio Operations:**
- `extract_audio (video, audio): BOOLEAN` - Extract audio track

**Video Operations:**
- `extract_frame (video, time, output): BOOLEAN` - Extract single frame
- `resize_video (input, output, width, height): BOOLEAN` - Resize video
- `images_to_video (pattern, output, fps): BOOLEAN` - Create video from images
- `images_to_video_with_options (pattern, output, fps, options): BOOLEAN`

---

### 2.2 FFMPEG_CLI

**Purpose:** Command-line interface backend executing ffmpeg.exe/ffprobe.exe.

**Features:**
- Same features as SIMPLE_FFMPEG
- Direct CLI execution
- Error capture from stderr
- JSON parsing for ffprobe output

---

### 2.3 FFMPEG_OPTIONS

**Purpose:** Fluent builder for transcoding configuration.

**Creation:** `make` (with sensible defaults)

**Video Options:**
- `video_codec: STRING_32` - Codec name (libx264, libx265, copy)
- `video_bitrate: INTEGER` - Bits per second
- `video_width`, `video_height: INTEGER` - Output dimensions
- `frame_rate: REAL_64` - Output FPS
- `no_video: BOOLEAN` - Disable video stream

**Audio Options:**
- `audio_codec: STRING_32` - Codec name (aac, mp3, copy)
- `audio_bitrate: INTEGER` - Bits per second
- `sample_rate: INTEGER` - Hz
- `audio_channels: INTEGER` - Channel count
- `no_audio: BOOLEAN` - Disable audio stream

**Fluent Setters:**
- `set_video_codec (codec): like Current`
- `set_video_bitrate (bitrate): like Current`
- `set_resolution (width, height): like Current`
- `set_frame_rate (fps): like Current`
- `set_audio_codec (codec): like Current`
- `set_audio_bitrate (bitrate): like Current`
- `set_sample_rate (rate): like Current`
- `set_channels (count): like Current`
- `copy_video`, `copy_audio`: like Current` - Stream copy
- `disable_video`, `disable_audio`: like Current`

**Presets:**
- `preset_fast: like Current` - Fast encoding
- `preset_quality: like Current` - Quality-focused
- `preset_web: like Current` - Web-optimized (720p)

---

### 2.4 FFMPEG_MEDIA_INFO

**Purpose:** Media file metadata container.

**Creation:**
- `make_from_handle (POINTER)` - From C probe handle
- `make_empty` - Empty info for testing

**General:**
- `filename: STRING_32`
- `format_name: STRING_32` - Container format
- `duration: REAL_64` - Seconds
- `size: INTEGER_64` - Bytes
- `bit_rate: INTEGER` - Overall bps
- `stream_count: INTEGER`

**Video:**
- `has_video: BOOLEAN`
- `video_codec: detachable STRING_32`
- `video_width`, `video_height: INTEGER`
- `video_frame_rate: REAL_64`
- `video_bit_rate: INTEGER`
- `resolution_string: STRING_32` - "WxH" format

**Audio:**
- `has_audio: BOOLEAN`
- `audio_codec: detachable STRING_32`
- `audio_sample_rate: INTEGER`
- `audio_channels: INTEGER`
- `audio_bit_rate: INTEGER`

**Metadata:**
- `title`, `artist`, `album: detachable STRING_32`

---

### 2.5 SDK Classes (Native Mode)

#### FFMPEG_DECODER
- Decode video/audio frames from file
- `read_video_frame`: FFMPEG_VIDEO_FRAME
- `read_audio_frame`: FFMPEG_AUDIO_FRAME
- `seek (time)`
- `close`

#### FFMPEG_ENCODER
- Encode frames to output file
- `write_video_frame (frame)`
- `write_audio_frame (frame)`
- `finalize`, `close`

#### FFMPEG_TRANSCODER
- High-level transcode operations
- Combines decoder + encoder

#### FFMPEG_FRAME (Base)
- Base class for frame data

#### FFMPEG_VIDEO_FRAME
- `width`, `height: INTEGER`
- `timestamp: REAL_64`
- `to_rgb`: ARRAY [NATURAL_8]
- `save_as_jpeg`, `save_as_png`

#### FFMPEG_AUDIO_FRAME
- `sample_rate`, `channels: INTEGER`
- `timestamp: REAL_64`
- `to_pcm_s16`: ARRAY [INTEGER_16]
- `to_pcm_float`: ARRAY [REAL_32]
