<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/.github/main/profile/assets/logo.png" alt="simple_ library logo" width="400">
</p>

# simple_ffmpeg

**[Documentation](https://simple-eiffel.github.io/simple_ffmpeg/)** | **[GitHub](https://github.com/simple-eiffel/simple_ffmpeg)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()

FFmpeg multimedia library for Eiffel - video/audio transcoding, metadata, frame extraction.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Development** - CLI mode (uses ffmpeg.exe), SDK mode available

## Features

- **Media Probing**: Get file duration, resolution, codecs, sample rates
- **Transcoding**: Convert between formats with customizable settings
- **Audio Extraction**: Extract audio tracks from video files
- **Frame Extraction**: Capture individual frames as images
- **Video Resizing**: Scale videos to target resolutions
- **Fluent API**: Chainable option setters for clean code
- **CLI Mode**: Works with ffmpeg.exe - no SDK required

## Quick Start

```eiffel
local
    ffmpeg: SIMPLE_FFMPEG
do
    create ffmpeg.make
    if ffmpeg.is_available then
        -- Get file info
        if attached ffmpeg.probe ("video.mp4") as info then
            print ("Duration: " + info.duration.out + " seconds%N")
            print ("Resolution: " + info.resolution_string + "%N")
        end
        
        -- Transcode to WebM
        if ffmpeg.transcode ("input.mp4", "output.webm") then
            print ("Transcoding complete%N")
        end
    end
end
```

## Installation

1. Set the environment variable:
```batch
set SIMPLE_EIFFEL=D:\prod
```

2. Add to your ECF file:
```xml
<library name="simple_ffmpeg" location="$SIMPLE_EIFFEL/simple_ffmpeg/simple_ffmpeg.ecf"/>
```

Requires: ffmpeg.exe and ffprobe.exe in PATH (download from https://ffmpeg.org)

## Options API

```eiffel
local
    ffmpeg: SIMPLE_FFMPEG
    opts: FFMPEG_OPTIONS
do
    create ffmpeg.make
    create opts.make
    
    -- Custom options with fluent API
    opts := opts.set_video_codec ("libx265")
               .set_resolution (1920, 1080)
               .set_video_bitrate (5_000_000)
               .set_audio_codec ("aac")
               .set_audio_bitrate (192_000)
    
    ffmpeg.transcode_with_options ("input.mov", "output.mp4", opts)
end
```

## Presets

```eiffel
opts := opts.preset_web      -- 720p, optimized for streaming
opts := opts.preset_fast     -- Fast encoding, lower quality
opts := opts.preset_quality  -- Slow encoding, best quality
```

## Audio Extraction

```eiffel
-- Extract audio track (copy codec, fast)
ffmpeg.extract_audio ("video.mp4", "audio.m4a")
```

## Frame Extraction

```eiffel
-- Extract frame at 5 seconds as JPEG
ffmpeg.extract_frame ("video.mp4", 5.0, "frame.jpg")
```

## Video Resizing

```eiffel
-- Resize to 1280x720
ffmpeg.resize_video ("input.mp4", "output.mp4", 1280, 720)
```

## Media Info

```eiffel
if attached ffmpeg.probe ("video.mp4") as info then
    print ("Format: " + info.format_name + "%N")
    print ("Duration: " + info.duration.out + " seconds%N")
    
    if info.has_video then
        print ("Video: " + info.video_codec + " " + info.resolution_string + "%N")
    end
    
    if info.has_audio then
        print ("Audio: " + info.audio_codec + " " + info.audio_sample_rate.out + "Hz%N")
    end
end
```

## Targets

- `simple_ffmpeg` - CLI mode library (default)
- `simple_ffmpeg_sdk` - Native SDK mode (requires FFmpeg dev libraries)
- `simple_ffmpeg_tests` - Test suite

## Dependencies

- simple_process (command execution)
- simple_file (file utilities)
- ISE base, time

## License

MIT License - See LICENSE file

---

Part of the **Simple Eiffel** ecosystem - modern, contract-driven Eiffel libraries.
