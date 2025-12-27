note
	description: "[
		FFMPEG_DECODER - Decode media files/streams

		Opens media files for frame-by-frame decoding.

		Example:
			if attached ffmpeg.open_input ("video.mp4") as dec then
				from until not attached dec.read_video_frame as f loop
					f.save_as_jpeg ("frame_" + f.timestamp.out + ".jpg", 85)
				end
				dec.close
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_DECODER

create
	make

feature {NONE} -- Initialization

	make (a_file: READABLE_STRING_GENERAL)
			-- Open media file for decoding.
		require
			file_not_empty: not a_file.is_empty
		local
			l_path: C_STRING
		do
			create l_path.make (a_file.to_string_8)
			handle := c_decoder_open (l_path.item)
			if handle /= default_pointer then
				is_open := True
				extract_info
			else
				is_open := False
				last_error := "Failed to open: " + a_file.to_string_32
			end
		end

feature -- Status

	is_open: BOOLEAN
			-- Is decoder open?

	has_video: BOOLEAN
			-- Does source have video?

	has_audio: BOOLEAN
			-- Does source have audio?

	last_error: detachable STRING_32
			-- Last error message.

feature -- Video Info

	video_width: INTEGER
			-- Video width in pixels.

	video_height: INTEGER
			-- Video height in pixels.

	video_frame_rate: REAL_64
			-- Video frame rate.

	video_codec: detachable STRING_32
			-- Video codec name.

feature -- Audio Info

	audio_sample_rate: INTEGER
			-- Audio sample rate in Hz.

	audio_channels: INTEGER
			-- Number of audio channels.

	audio_codec: detachable STRING_32
			-- Audio codec name.

feature -- Position

	duration: REAL_64
			-- Total duration in seconds.

	position: REAL_64
			-- Current position in seconds.
		do
			if is_open then
				Result := c_decoder_position (handle)
			end
		end

feature -- Decoding

	read_video_frame: detachable FFMPEG_VIDEO_FRAME
			-- Read next video frame.
		require
			is_open: is_open
			has_video: has_video
		local
			l_frame_handle: POINTER
		do
			l_frame_handle := c_decoder_read_video (handle)
			if l_frame_handle /= default_pointer then
				create Result.make_from_handle (l_frame_handle)
			end
		end

	read_audio_frame: detachable FFMPEG_AUDIO_FRAME
			-- Read next audio frame.
		require
			is_open: is_open
			has_audio: has_audio
		local
			l_frame_handle: POINTER
		do
			l_frame_handle := c_decoder_read_audio (handle)
			if l_frame_handle /= default_pointer then
				create Result.make_from_handle (l_frame_handle)
			end
		end

	seek (a_time: REAL_64)
			-- Seek to timestamp.
		require
			is_open: is_open
			valid_time: a_time >= 0.0 and a_time <= duration
		do
			c_decoder_seek (handle, a_time)
		end

feature -- Cleanup

	close
			-- Close decoder and free resources.
		require
			is_open: is_open
		do
			c_decoder_close (handle)
			handle := default_pointer
			is_open := False
		ensure
			closed: not is_open
		end

feature {NONE} -- Implementation

	handle: POINTER
			-- C decoder handle.

	extract_info
			-- Extract stream information.
		local
			l_ptr: POINTER
		do
			duration := c_decoder_duration (handle)
			has_video := c_decoder_has_video (handle)
			has_audio := c_decoder_has_audio (handle)

			if has_video then
				video_width := c_decoder_video_width (handle)
				video_height := c_decoder_video_height (handle)
				video_frame_rate := c_decoder_video_fps (handle)
				l_ptr := c_decoder_video_codec (handle)
				if l_ptr /= default_pointer then
					create video_codec.make_from_c (l_ptr)
				end
			end

			if has_audio then
				audio_sample_rate := c_decoder_audio_sample_rate (handle)
				audio_channels := c_decoder_audio_channels (handle)
				l_ptr := c_decoder_audio_codec (handle)
				if l_ptr /= default_pointer then
					create audio_codec.make_from_c (l_ptr)
				end
			end
		end

feature {NONE} -- C Externals

	c_decoder_open (a_path: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_open((const char *)$a_path);"
		end

	c_decoder_close (a_handle: POINTER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_decoder_close($a_handle);"
		end

	c_decoder_duration (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_duration($a_handle);"
		end

	c_decoder_position (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_position($a_handle);"
		end

	c_decoder_has_video (a_handle: POINTER): BOOLEAN
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_has_video($a_handle);"
		end

	c_decoder_has_audio (a_handle: POINTER): BOOLEAN
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_has_audio($a_handle);"
		end

	c_decoder_video_width (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_video_width($a_handle);"
		end

	c_decoder_video_height (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_video_height($a_handle);"
		end

	c_decoder_video_fps (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_video_fps($a_handle);"
		end

	c_decoder_video_codec (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return (EIF_POINTER)ffmpeg_decoder_video_codec($a_handle);"
		end

	c_decoder_audio_sample_rate (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_audio_sample_rate($a_handle);"
		end

	c_decoder_audio_channels (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_audio_channels($a_handle);"
		end

	c_decoder_audio_codec (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return (EIF_POINTER)ffmpeg_decoder_audio_codec($a_handle);"
		end

	c_decoder_read_video (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_read_video($a_handle);"
		end

	c_decoder_read_audio (a_handle: POINTER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_decoder_read_audio($a_handle);"
		end

	c_decoder_seek (a_handle: POINTER; a_time: REAL_64)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_decoder_seek($a_handle, $a_time);"
		end

end
