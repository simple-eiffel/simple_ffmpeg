# Drift Analysis: simple_ffmpeg

Generated: 2026-01-24
Method: `ec.exe -flatshort` vs `specs/*.md` + `research/*.md`

## Specification Sources

| Source | Files | Lines |
|--------|-------|-------|
| specs/*.md | 8 | 1324 |
| research/*.md | 1 | 424 |

## Classes Analyzed

| Class | Spec'd Features | Actual Features | Drift |
|-------|-----------------|-----------------|-------|
| SIMPLE_FFMPEG | 46 | 31 | -15 |

## Feature-Level Drift

### Specified, Implemented ✓
- `cli_attached` ✓
- `extract_audio` ✓
- `extract_frame` ✓
- `has_error` ✓
- `images_to_video` ✓
- `is_available` ✓
- `last_error` ✓
- `resize_video` ✓
- `transcode_with_options` ✓

### Specified, NOT Implemented ✗
- `a_fps` ✗
- `a_pattern` ✗
- `a_time` ✗
- `audio_bit_rate` ✗
- `audio_bitrate` ✗
- `audio_channels` ✗
- `audio_codec` ✗
- `audio_sample_rate` ✗
- `bit_rate` ✗
- `copy_audio` ✗
- ... and 27 more

### Implemented, NOT Specified
- `Io`
- `Operating_environment`
- `author`
- `conforms_to`
- `copy`
- `date`
- `default_rescue`
- `description`
- `generating_type`
- `generator`
- ... and 12 more

## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 9 |
| Spec'd, missing | 37 |
| Implemented, not spec'd | 22 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_ffmpeg** has high drift. Significant gaps between spec and implementation.
