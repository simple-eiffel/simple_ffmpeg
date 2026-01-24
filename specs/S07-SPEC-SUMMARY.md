# S07-SPEC-SUMMARY.md
## simple_ffmpeg - Specification Summary

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. Library Identity

| Attribute | Value |
|-----------|-------|
| **Name** | simple_ffmpeg |
| **Version** | 1.0 |
| **Purpose** | FFmpeg multimedia library facade |
| **Facade** | SIMPLE_FFMPEG |
| **Classes** | 12 (4 core + 8 SDK) |

## 2. Class Summary

| Class | Mode | Purpose |
|-------|------|---------|
| SIMPLE_FFMPEG | Both | Main facade |
| FFMPEG_CLI | CLI | Command-line backend |
| FFMPEG_OPTIONS | Both | Encoding options |
| FFMPEG_ENCODER_OPTIONS | Both | Encoder-specific options |
| FFMPEG_MEDIA_INFO | Both | Media metadata |
| FFMPEG_DECODER | SDK | Native decoding |
| FFMPEG_ENCODER | SDK | Native encoding |
| FFMPEG_TRANSCODER | SDK | Native transcoding |
| FFMPEG_FRAME | SDK | Base frame class |
| FFMPEG_VIDEO_FRAME | SDK | Video frame data |
| FFMPEG_AUDIO_FRAME | SDK | Audio frame data |

## 3. Feature Summary (CLI Mode)

| Category | Count | Features |
|----------|-------|----------|
| Status | 4 | is_available, has_error, last_error, version |
| Metadata | 1 | probe |
| Transcoding | 2 | transcode, transcode_with_options |
| Audio | 1 | extract_audio |
| Video | 4 | extract_frame, resize_video, images_to_video (x2) |
| **Total** | **12** | |

## 4. FFMPEG_OPTIONS Summary

| Category | Count | Features |
|----------|-------|----------|
| Video Settings | 5 | codec, bitrate, width, height, frame_rate, no_video |
| Audio Settings | 5 | codec, bitrate, sample_rate, channels, no_audio |
| Fluent Setters | 10 | set_* methods |
| Stream Ops | 4 | copy_video, copy_audio, disable_video, disable_audio |
| Presets | 3 | preset_fast, preset_quality, preset_web |
| **Total** | **27** | |

## 5. Design Patterns

| Pattern | Implementation |
|---------|----------------|
| Facade | SIMPLE_FFMPEG hides CLI complexity |
| Builder | FFMPEG_OPTIONS fluent interface |
| Strategy | CLI vs SDK backend |
| Null Object | make_empty for testing |

## 6. Contract Summary

| Contract Type | Count |
|---------------|-------|
| Preconditions | 18 |
| Postconditions | 2 |
| Class Invariants | 1 |

**Key Validations:**
- is_available checked before operations
- Non-empty file paths
- Positive dimensions/bitrates/FPS
- Valid time values (>= 0)

## 7. Dependency Graph

```
simple_ffmpeg
    |
    +-- FFMPEG_CLI
    |       |
    |       +-- ffmpeg.exe (external process)
    |       +-- ffprobe.exe (external process)
    |
    +-- FFMPEG_OPTIONS (configuration)
    |
    +-- FFMPEG_MEDIA_INFO (metadata)
    |
    +-- simple_file (file operations)
    |
    +-- base (ISE standard library)

SDK Mode additionally:
    |
    +-- libavcodec
    +-- libavformat
    +-- libavutil
    +-- libswscale
```

## 8. Common Operations

| Operation | Method | Example |
|-----------|--------|---------|
| Get info | `probe` | `info := ffmpeg.probe("video.mp4")` |
| Convert format | `transcode` | `ffmpeg.transcode("in.avi", "out.mp4")` |
| Extract audio | `extract_audio` | `ffmpeg.extract_audio("video.mp4", "audio.mp3")` |
| Get thumbnail | `extract_frame` | `ffmpeg.extract_frame("video.mp4", 5.0, "thumb.jpg")` |
| Resize | `resize_video` | `ffmpeg.resize_video("in.mp4", "out.mp4", 1280, 720)` |
| Images to video | `images_to_video` | `ffmpeg.images_to_video("frame_%05d.png", "out.mp4", 30)` |

## 9. Usage Example

```eiffel
class VIDEO_PROCESSOR
feature
    process_video (input, output: STRING)
        local
            ffmpeg: SIMPLE_FFMPEG
            info: FFMPEG_MEDIA_INFO
            options: FFMPEG_OPTIONS
        do
            create ffmpeg.make

            -- Check availability
            if not ffmpeg.is_available then
                print ("FFmpeg not found in PATH%N")
                return
            end

            -- Get source info
            if attached ffmpeg.probe (input) as i then
                info := i
                print ("Input: " + info.resolution_string +
                       " @ " + info.duration.out + "s%N")
            else
                print ("Failed to probe: " + ffmpeg.last_error + "%N")
                return
            end

            -- Configure encoding
            create options.make
            if info.video_width > 1920 then
                -- Downscale to 1080p
                options := options.set_resolution (1920, 1080)
            end
            options := options.set_video_bitrate (5_000_000)

            -- Transcode
            if ffmpeg.transcode_with_options (input, output, options) then
                print ("Success: " + output + "%N")
            else
                print ("Failed: " + ffmpeg.last_error + "%N")
            end
        end
end
```

## 10. Quality Metrics

| Metric | Value |
|--------|-------|
| Void Safety | Full |
| SCOOP Ready | Yes (synchronous) |
| Contract Coverage | Good |
| CLI/SDK Separation | Clean |
| Error Handling | Return value + last_error |
