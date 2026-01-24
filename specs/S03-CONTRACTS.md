# S03-CONTRACTS.md
## simple_ffmpeg - Contracts Specification

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. SIMPLE_FFMPEG Contracts

### Creation
```eiffel
-- make
ensure
    cli_created: cli /= Void
```

### Probe
```eiffel
-- probe
require
    available: is_available
    file_not_empty: not a_file.is_empty
```

### Transcode
```eiffel
-- transcode
require
    available: is_available
    input_not_empty: not a_input.is_empty
    output_not_empty: not a_output.is_empty

-- transcode_with_options
require
    available: is_available
    input_not_empty: not a_input.is_empty
    output_not_empty: not a_output.is_empty
```

### Audio Operations
```eiffel
-- extract_audio
require
    available: is_available
    video_not_empty: not a_video.is_empty
    audio_not_empty: not a_audio.is_empty
```

### Video Operations
```eiffel
-- extract_frame
require
    available: is_available
    video_not_empty: not a_video.is_empty
    time_non_negative: a_time >= 0.0
    output_not_empty: not a_output.is_empty

-- resize_video
require
    available: is_available
    input_not_empty: not a_input.is_empty
    output_not_empty: not a_output.is_empty
    valid_width: a_width > 0
    valid_height: a_height > 0

-- images_to_video
require
    available: is_available
    pattern_not_empty: not a_pattern.is_empty
    output_not_empty: not a_output.is_empty
    valid_fps: a_fps > 0
```

### Class Invariant
```eiffel
invariant
    cli_attached: cli /= Void
```

---

## 2. FFMPEG_OPTIONS Contracts

### Fluent Setters
```eiffel
-- set_video_bitrate
require
    positive: a_bitrate > 0

-- set_resolution
require
    positive_width: a_width > 0
    positive_height: a_height > 0

-- set_frame_rate
require
    positive: a_fps > 0.0

-- set_audio_bitrate
require
    positive: a_bitrate > 0

-- set_sample_rate
require
    positive: a_rate > 0

-- set_channels
require
    valid: a_count >= 1 and a_count <= 8
```

---

## 3. FFMPEG_MEDIA_INFO Contracts

### Creation
```eiffel
-- make_from_handle
require
    valid_handle: a_handle /= default_pointer
```

---

## 4. Contract Design Principles

1. **Availability Check:** All operations require `is_available`
2. **Non-empty Paths:** All file paths must be non-empty
3. **Positive Values:** Dimensions, bitrates, FPS must be positive
4. **Valid Ranges:** Channels 1-8, time non-negative
5. **Fluent Returns:** All setters return `like Current`

## 5. Error Handling Pattern

Operations return `BOOLEAN` for success/failure:
- `True` = Operation completed successfully
- `False` = Operation failed, check `last_error`

For operations returning objects:
- Returns attached object on success
- Returns `Void` on failure, check `has_error`
