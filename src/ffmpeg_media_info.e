note
	description: "[
		FFMPEG_MEDIA_INFO - Media file metadata

		Contains information about a media file including duration,
		resolution, codecs, and stream details.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_MEDIA_INFO

create
	make_from_handle,
	make_empty

feature {NONE} -- Initialization

	make_from_handle (a_handle: POINTER)
			-- Create from C probe handle.
		require
			valid_handle: a_handle /= default_pointer
		do
			handle := a_handle
			extract_info
		end

	make_empty
			-- Create empty media info (for testing).
		do
			-- All attributes have default values
		end

feature -- General

	filename: STRING_32
			-- Source filename.
		attribute
			create Result.make_empty
		end

	format_name: STRING_32
			-- Container format name (mp4, mkv, avi, etc.).
		attribute
			create Result.make_empty
		end

	duration: REAL_64
			-- Duration in seconds.

	size: INTEGER_64
			-- File size in bytes.

	bit_rate: INTEGER
			-- Overall bit rate in bits/second.

feature -- Video

	has_video: BOOLEAN
			-- Does file contain video?

	video_codec: detachable STRING_32
			-- Video codec name (h264, hevc, vp9, etc.).

	video_width: INTEGER
			-- Video width in pixels.

	video_height: INTEGER
			-- Video height in pixels.

	video_frame_rate: REAL_64
			-- Video frame rate in fps.

	video_bit_rate: INTEGER
			-- Video bit rate in bits/second.

	resolution_string: STRING_32
			-- Resolution as "WxH" string.
		do
			create Result.make (10)
			Result.append_integer (video_width)
			Result.append_character ('x')
			Result.append_integer (video_height)
		end

feature -- Audio

	has_audio: BOOLEAN
			-- Does file contain audio?

	audio_codec: detachable STRING_32
			-- Audio codec name (aac, mp3, flac, etc.).

	audio_sample_rate: INTEGER
			-- Audio sample rate in Hz.

	audio_channels: INTEGER
			-- Number of audio channels.

	audio_bit_rate: INTEGER
			-- Audio bit rate in bits/second.

feature -- Streams

	stream_count: INTEGER
			-- Total number of streams.

feature -- Metadata

	title: detachable STRING_32
			-- Title metadata.

	artist: detachable STRING_32
			-- Artist metadata.

	album: detachable STRING_32
			-- Album metadata.

feature {FFMPEG_CLI} -- Setters (for CLI parsing)

	set_duration (a_value: REAL_64)
			-- Set duration.
		do
			duration := a_value
		end

	set_format_name (a_value: READABLE_STRING_GENERAL)
			-- Set format name.
		do
			format_name := a_value.to_string_32
		end

	set_has_video (a_value: BOOLEAN)
			-- Set has_video flag.
		do
			has_video := a_value
		end

	set_video_width (a_value: INTEGER)
			-- Set video width.
		do
			video_width := a_value
		end

	set_video_height (a_value: INTEGER)
			-- Set video height.
		do
			video_height := a_value
		end

	set_video_codec (a_value: READABLE_STRING_GENERAL)
			-- Set video codec.
		do
			video_codec := a_value.to_string_32
		end

	set_video_frame_rate (a_value: REAL_64)
			-- Set video frame rate.
		do
			video_frame_rate := a_value
		end

	set_has_audio (a_value: BOOLEAN)
			-- Set has_audio flag.
		do
			has_audio := a_value
		end

	set_audio_sample_rate (a_value: INTEGER)
			-- Set audio sample rate.
		do
			audio_sample_rate := a_value
		end

	set_audio_channels (a_value: INTEGER)
			-- Set audio channels.
		do
			audio_channels := a_value
		end

	set_audio_codec (a_value: READABLE_STRING_GENERAL)
			-- Set audio codec.
		do
			audio_codec := a_value.to_string_32
		end

feature {NONE} -- Implementation

	handle: POINTER
			-- C probe handle.

	extract_info
			-- Extract information from C handle.
		local
			l_ptr: POINTER
		do
			-- Duration
			duration := c_get_duration (handle)

			-- Format name
			l_ptr := c_get_format_name (handle)
			if l_ptr /= default_pointer then
				create format_name.make_from_c (l_ptr)
			end

			-- Video info
			has_video := c_has_video (handle)
			if has_video then
				video_width := c_get_video_width (handle)
				video_height := c_get_video_height (handle)
				video_frame_rate := c_get_video_fps (handle)
				video_bit_rate := c_get_video_bitrate (handle)
				l_ptr := c_get_video_codec (handle)
				if l_ptr /= default_pointer then
					create video_codec.make_from_c (l_ptr)
				end
			end

			-- Audio info
			has_audio := c_has_audio (handle)
			if has_audio then
				audio_sample_rate := c_get_audio_sample_rate (handle)
				audio_channels := c_get_audio_channels (handle)
				audio_bit_rate := c_get_audio_bitrate (handle)
				l_ptr := c_get_audio_codec (handle)
				if l_ptr /= default_pointer then
					create audio_codec.make_from_c (l_ptr)
				end
			end

			-- Stream count
			stream_count := c_get_stream_count (handle)
		end

feature {NONE} -- C Externals

	c_get_duration (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_duration($a_handle);"
		end

	c_get_format_name (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return (EIF_POINTER)ffmpeg_info_format($a_handle);"
		end

	c_has_video (a_handle: POINTER): BOOLEAN
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_has_video($a_handle);"
		end

	c_get_video_width (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_video_width($a_handle);"
		end

	c_get_video_height (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_video_height($a_handle);"
		end

	c_get_video_fps (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_video_fps($a_handle);"
		end

	c_get_video_bitrate (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_video_bitrate($a_handle);"
		end

	c_get_video_codec (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return (EIF_POINTER)ffmpeg_info_video_codec($a_handle);"
		end

	c_has_audio (a_handle: POINTER): BOOLEAN
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_has_audio($a_handle);"
		end

	c_get_audio_sample_rate (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_audio_sample_rate($a_handle);"
		end

	c_get_audio_channels (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_audio_channels($a_handle);"
		end

	c_get_audio_bitrate (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_audio_bitrate($a_handle);"
		end

	c_get_audio_codec (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return (EIF_POINTER)ffmpeg_info_audio_codec($a_handle);"
		end

	c_get_stream_count (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_info_stream_count($a_handle);"
		end

end