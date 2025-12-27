/*
 * FFmpeg Bridge Header for Eiffel - CLI Mode Stubs
 *
 * CLI Mode (default): Stub implementations that compile without FFmpeg SDK.
 * These stubs allow the Eiffel classes to compile, but the actual
 * functionality is provided by FFMPEG_CLI via ffmpeg.exe execution.
 *
 * SDK Mode: Define FFMPEG_SDK_ENABLED before including this header,
 * then the real FFmpeg library calls will be used.
 */

#ifndef FFMPEG_BRIDGE_H
#define FFMPEG_BRIDGE_H

#include <stdlib.h>
#include <string.h>

/* Stub structure for probe info */
typedef struct {
    double duration;
    char format_name[64];
    int has_video;
    int has_audio;
    int video_width;
    int video_height;
    double video_fps;
    int video_bitrate;
    char video_codec[32];
    int audio_sample_rate;
    int audio_channels;
    int audio_bitrate;
    char audio_codec[32];
    int stream_count;
} FFmpegProbeInfo;

static int g_ffmpeg_initialized = 0;

/* Initialization stubs */
static inline void ffmpeg_init(void) {
    g_ffmpeg_initialized = 1;
}

static inline int ffmpeg_is_initialized(void) {
    return g_ffmpeg_initialized;
}

static inline const char* ffmpeg_version(void) {
    return "CLI mode";
}

/* Probe stubs */
static inline void* ffmpeg_probe(const char* path) {
    (void)path;
    return NULL;
}

static inline void ffmpeg_free_probe(void* handle) {
    if (handle) free(handle);
}

/* Info accessor stubs - safe to call with NULL handle */
static inline double ffmpeg_info_duration(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->duration;
    return 0.0;
}

static inline const char* ffmpeg_info_format(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->format_name;
    return "";
}

static inline int ffmpeg_info_has_video(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->has_video;
    return 0;
}

static inline int ffmpeg_info_video_width(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->video_width;
    return 0;
}

static inline int ffmpeg_info_video_height(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->video_height;
    return 0;
}

static inline double ffmpeg_info_video_fps(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->video_fps;
    return 0.0;
}

static inline int ffmpeg_info_video_bitrate(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->video_bitrate;
    return 0;
}

static inline const char* ffmpeg_info_video_codec(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->video_codec;
    return "";
}

static inline int ffmpeg_info_has_audio(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->has_audio;
    return 0;
}

static inline int ffmpeg_info_audio_sample_rate(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->audio_sample_rate;
    return 0;
}

static inline int ffmpeg_info_audio_channels(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->audio_channels;
    return 0;
}

static inline int ffmpeg_info_audio_bitrate(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->audio_bitrate;
    return 0;
}

static inline const char* ffmpeg_info_audio_codec(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->audio_codec;
    return "";
}

static inline int ffmpeg_info_stream_count(void* handle) {
    if (handle) return ((FFmpegProbeInfo*)handle)->stream_count;
    return 0;
}

/* Transcoding stubs */
static inline int ffmpeg_transcode(const char* input, const char* output) {
    (void)input; (void)output;
    return -1;
}

static inline int ffmpeg_extract_audio(const char* video, const char* audio) {
    (void)video; (void)audio;
    return -1;
}

static inline int ffmpeg_extract_frame(const char* video, double time, const char* output) {
    (void)video; (void)time; (void)output;
    return -1;
}

static inline int ffmpeg_resize_video(const char* input, const char* output, int width, int height) {
    (void)input; (void)output; (void)width; (void)height;
    return -1;
}

#endif /* FFMPEG_BRIDGE_H */
