# S06-BOUNDARIES.md
## simple_ffmpeg - API Boundaries

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Public API Surface

### 1.1 SIMPLE_FFMPEG (Facade)

#### Exported to ALL
- `make`
- `is_available: BOOLEAN`
- `has_error: BOOLEAN`
- `last_error: detachable STRING_32`
- `version: STRING_32`
- `probe (READABLE_STRING_GENERAL): detachable FFMPEG_MEDIA_INFO`
- `transcode (READABLE_STRING_GENERAL, READABLE_STRING_GENERAL): BOOLEAN`
- `transcode_with_options (..., FFMPEG_OPTIONS): BOOLEAN`
- `extract_audio (READABLE_STRING_GENERAL, READABLE_STRING_GENERAL): BOOLEAN`
- `extract_frame (READABLE_STRING_GENERAL, REAL_64, READABLE_STRING_GENERAL): BOOLEAN`
- `resize_video (READABLE_STRING_GENERAL, READABLE_STRING_GENERAL, INTEGER, INTEGER): BOOLEAN`
- `images_to_video (READABLE_STRING_GENERAL, READABLE_STRING_GENERAL, INTEGER): BOOLEAN`
- `images_to_video_with_options (..., FFMPEG_OPTIONS): BOOLEAN`

### 1.2 FFMPEG_OPTIONS

#### Exported to ALL
- `make`
- All option attributes (video_codec, audio_codec, etc.)
- All fluent setters (set_video_codec, etc.)
- All presets (preset_fast, preset_quality, preset_web)
- Stream operations (copy_video, copy_audio, disable_video, disable_audio)

### 1.3 FFMPEG_MEDIA_INFO

#### Exported to ALL
- `make_empty`
- All general queries (duration, format_name, etc.)
- All video queries (has_video, video_width, etc.)
- All audio queries (has_audio, audio_sample_rate, etc.)
- All metadata queries (title, artist, album)

#### Exported to FFMPEG_CLI
- All setters (set_duration, set_format_name, etc.)

## 2. Hidden Implementation

### 2.1 SIMPLE_FFMPEG
- `cli: FFMPEG_CLI` - Backend implementation

### 2.2 FFMPEG_MEDIA_INFO
- `handle: POINTER` - C probe handle
- `extract_info` - C data extraction
- C external functions (c_get_duration, etc.)

## 3. Dependency Boundaries

### 3.1 FFMPEG_CLI Dependency
- SIMPLE_FFMPEG delegates all operations to FFMPEG_CLI
- No direct FFmpeg interaction in facade
- Clean separation of interface and implementation

### 3.2 simple_* Dependencies
- **simple_file:** File path operations (if used)
- Minimal coupling with ecosystem

### 3.3 FFmpeg Dependency
- CLI mode: External process (ffmpeg.exe, ffprobe.exe)
- SDK mode: libav* libraries via C externals

## 4. Extension Points

### 4.1 Backend Swapping
- SIMPLE_FFMPEG uses composition with CLI backend
- Could swap to SDK backend for performance
- Same public API either way

### 4.2 Option Extension
- FFMPEG_OPTIONS can be subclassed
- Add specialized options for codecs
- Presets provide starting configurations

### 4.3 Custom Processing
- Use probe() to get media info
- Make decisions based on metadata
- Call appropriate transcode operations

## 5. Integration Patterns

### 5.1 Basic Transcoding
```eiffel
-- Convert video format
ffmpeg: SIMPLE_FFMPEG
create ffmpeg.make

if ffmpeg.is_available then
    if ffmpeg.transcode ("input.avi", "output.mp4") then
        print ("Conversion successful%N")
    else
        print ("Error: " + ffmpeg.last_error + "%N")
    end
end
```

### 5.2 Media Information
```eiffel
-- Get video information
if attached ffmpeg.probe ("video.mp4") as info then
    print ("Duration: " + info.duration.out + " seconds%N")
    print ("Resolution: " + info.resolution_string + "%N")
    if info.has_video then
        print ("Video codec: " + info.video_codec + "%N")
    end
    if info.has_audio then
        print ("Audio: " + info.audio_channels.out + " channels%N")
    end
end
```

### 5.3 Custom Encoding Options
```eiffel
-- High-quality transcode
options: FFMPEG_OPTIONS
create options.make
options := options.preset_quality
               .set_resolution (1920, 1080)

ffmpeg.transcode_with_options ("input.mov", "output.mp4", options)
```

### 5.4 Thumbnail Generation
```eiffel
-- Extract thumbnails at intervals
duration := ffmpeg.probe ("video.mp4").duration
interval := duration / 10

from i := 0 until i >= 10 loop
    timestamp := i * interval
    output := "thumb_" + i.out + ".jpg"
    ffmpeg.extract_frame ("video.mp4", timestamp, output)
    i := i + 1
end
```

### 5.5 Audio Extraction
```eiffel
-- Extract audio to MP3
if ffmpeg.extract_audio ("video.mp4", "audio.mp3") then
    print ("Audio extracted%N")
end
```

### 5.6 Image Sequence to Video
```eiffel
-- Create video from rendered frames
options := (create {FFMPEG_OPTIONS}.make)
    .set_video_codec ("libx264")
    .set_video_bitrate (10_000_000)  -- High quality

ffmpeg.images_to_video_with_options (
    "frames/frame_%05d.png",  -- Pattern
    "animation.mp4",          -- Output
    60,                       -- 60 FPS
    options
)
```

## 6. Type Safety

### 6.1 Void Handling
- `probe` returns detachable (may be Void on error)
- `last_error` is detachable (may be Void if no error)
- Other queries are attached

### 6.2 Return Values
- Boolean operations: True = success, False = failure
- Object operations: Attached = success, Void = failure
- Always check `has_error` after failures
