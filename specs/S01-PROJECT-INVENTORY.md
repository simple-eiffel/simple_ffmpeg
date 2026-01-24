# S01-PROJECT-INVENTORY.md
## simple_ffmpeg - Project Inventory

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)
**Library:** simple_ffmpeg
**Version:** 1.0

---

## 1. Project Overview

| Attribute | Value |
|-----------|-------|
| **Name** | simple_ffmpeg |
| **Purpose** | FFmpeg multimedia library facade |
| **Facade Class** | SIMPLE_FFMPEG |
| **Author** | Larry Rix |
| **License** | MIT License |

## 2. Source Files

### Core (src/)
| File | Purpose |
|------|---------|
| `simple_ffmpeg.e` | Main facade class |
| `ffmpeg_options.e` | Transcoding options builder |
| `ffmpeg_encoder_options.e` | Encoder-specific options |
| `ffmpeg_media_info.e` | Media file metadata |

### CLI Backend (src/cli/)
| File | Purpose |
|------|---------|
| `ffmpeg_cli.e` | Command-line interface backend |

### SDK Backend (src/sdk/)
| File | Purpose |
|------|---------|
| `ffmpeg_decoder.e` | Native decode operations |
| `ffmpeg_encoder.e` | Native encode operations |
| `ffmpeg_transcoder.e` | Native transcode operations |
| `ffmpeg_frame.e` | Base frame class |
| `ffmpeg_video_frame.e` | Video frame data |
| `ffmpeg_audio_frame.e` | Audio frame data |

### Testing
| File | Purpose |
|------|---------|
| `testing/lib_tests.e` | Test suite |
| `testing/test_app.e` | Test application |

## 3. Dependencies

### Internal (simple_* ecosystem)
- **simple_file** - File path operations

### External (ISE/Standard)
- **base** - STRING, BOOLEAN, INTEGER
- **time** - Timing operations

### External (System)
- **ffmpeg.exe** - CLI mode (must be in PATH)
- **ffprobe.exe** - CLI mode (must be in PATH)
- **FFmpeg SDK** - SDK mode (FFMPEG_SDK environment variable)

## 4. ECF Configuration

**Targets:**
- `simple_ffmpeg` - CLI mode (default)
- `simple_ffmpeg_sdk` - SDK mode (requires FFmpeg dev libs)

## 5. Design Philosophy

Based on research findings:
- **Dual Mode** - CLI backend for simplicity, SDK for performance
- **Design by Contract** - Preconditions prevent invalid operations
- **Void Safety** - Explicit handling of missing data
- **High-Level Facade** - One-liner for common operations
- **Automatic Resource Management** - RAII-style cleanup

## 6. External Dependencies

### CLI Mode
| Dependency | Required | Purpose |
|------------|----------|---------|
| ffmpeg.exe | Yes | Transcoding, frame extraction |
| ffprobe.exe | Yes | Media probing |

### SDK Mode
| Dependency | Required | Purpose |
|------------|----------|---------|
| libavcodec | Yes | Encoding/decoding |
| libavformat | Yes | Container formats |
| libavutil | Yes | Utilities |
| libswscale | Yes | Video scaling |
| libswresample | Optional | Audio resampling |

## 7. Compliance

- **Void Safety:** Full
- **SCOOP Ready:** Yes
- **Design by Contract:** Comprehensive
