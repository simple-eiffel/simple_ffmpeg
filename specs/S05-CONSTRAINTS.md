# S05-CONSTRAINTS.md
## simple_ffmpeg - Constraints and Limitations

**Generated:** 2026-01-23
**Type:** BACKWASH (reverse-engineered from implementation)

---

## 1. External Dependency Constraints

### 1.1 CLI Mode Requirements
- **ffmpeg.exe** must be in system PATH
- **ffprobe.exe** must be in system PATH
- If not found, `is_available` returns False

### 1.2 SDK Mode Requirements
- **FFMPEG_SDK** environment variable must point to FFmpeg dev libs
- Required libraries: avcodec, avformat, avutil, swscale
- Windows: .lib files for linking
- Compile-time dependency

## 2. Platform Constraints

### 2.1 Windows Focus
- **Constraint:** Developed primarily for Windows
- **Impact:** PATH lookup uses Windows conventions
- **Note:** FFmpeg itself is cross-platform

### 2.2 File Path Handling
- Uses `READABLE_STRING_GENERAL` for paths
- Converts to appropriate format for CLI execution
- Spaces in paths require proper quoting

## 3. Format Constraints

### 3.1 Supported Formats
FFmpeg supports 100+ formats, but common ones include:

**Containers:**
- Video: MP4, MKV, AVI, MOV, WebM
- Audio: MP3, AAC, FLAC, WAV, OGG

**Codecs:**
- Video: H.264 (libx264), H.265 (libx265), VP9
- Audio: AAC, MP3 (libmp3lame), FLAC, Opus

### 3.2 Format Detection
- Output format detected from file extension
- Input format auto-detected by FFmpeg
- No explicit format specification in simple_ffmpeg API

## 4. Performance Constraints

### 4.1 CLI Overhead
- **Constraint:** CLI mode spawns external process
- **Impact:** Startup overhead per operation
- **Mitigation:** Use SDK mode for high-performance needs

### 4.2 Memory Usage
- **Constraint:** CLI mode reads entire output
- **Impact:** Very long stderr may consume memory
- **Mitigation:** Normal use is fine; avoid extreme cases

### 4.3 Real-Time Processing
- **Constraint:** CLI mode not suitable for real-time
- **Impact:** Cannot process live streams frame-by-frame
- **Mitigation:** Use SDK mode for real-time

## 5. API Constraints

### 5.1 Synchronous Operations
- **Constraint:** All operations are blocking
- **Impact:** Long transcodes block caller
- **Mitigation:** Run in separate thread/processor

### 5.2 No Progress Callback
- **Constraint:** No progress reporting in CLI mode
- **Impact:** Cannot show transcode progress
- **Future:** SDK mode may add callbacks

### 5.3 No Streaming Support
- **Constraint:** File-based operations only
- **Impact:** No RTMP, HLS input/output
- **Future:** Planned for SDK mode

## 6. Error Handling Constraints

### 6.1 Error Information
- **Constraint:** Errors from FFmpeg stderr
- **Detail:** Full FFmpeg error message available
- **Access:** Via `last_error` after failure

### 6.2 No Exception Model
- **Constraint:** Uses return value pattern
- **Pattern:** Returns False on failure
- **Check:** `has_error` and `last_error`

## 7. Feature Gaps (vs Research Recommendations)

| Feature | Status | Notes |
|---------|--------|-------|
| Media probing | Implemented | Duration, codecs, resolution |
| Transcode | Implemented | Format conversion |
| Extract audio | Implemented | Audio track extraction |
| Extract frame | Implemented | Thumbnail generation |
| Resize video | Implemented | Scale filter |
| Images to video | Implemented | Sequence encoding |
| Streaming (RTMP/HLS) | NOT Implemented | Future SDK feature |
| Hardware acceleration | NOT Implemented | Future feature |
| Filter graphs | NOT Implemented | Complex filters unsupported |
| Screen capture | NOT Implemented | Future feature |
| SCOOP async | NOT Implemented | Synchronous only |
| Progress callback | NOT Implemented | No feedback during transcode |

## 8. SDK Mode Limitations

### 8.1 Compile-Time Setup
- Requires FFmpeg dev headers and libs
- Environment variable configuration
- Platform-specific library paths

### 8.2 C Integration Complexity
- Uses inline C externals
- Requires ffmpeg_bridge.h
- Memory management across Eiffel/C boundary

## 9. Recommendations

### For Typical Use
1. CLI mode is sufficient for most applications
2. Check `is_available` before operations
3. Handle errors via `has_error` / `last_error`

### For High Performance
1. Consider SDK mode for batch processing
2. Implement progress tracking if needed
3. Use SCOOP for non-blocking operations

### For Real-Time
1. SDK mode required
2. Frame-by-frame processing available
3. Consider hardware acceleration
