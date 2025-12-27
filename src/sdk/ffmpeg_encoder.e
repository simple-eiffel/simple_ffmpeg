note
	description: "[
		FFMPEG_ENCODER - Encode media files

		Creates media files from raw frames.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_ENCODER

create
	make

feature {NONE} -- Initialization

	make (a_output: READABLE_STRING_GENERAL; a_options: FFMPEG_ENCODER_OPTIONS)
			-- Create encoder for output file.
		require
			output_not_empty: not a_output.is_empty
			options_valid: a_options /= Void
		local
			l_path: C_STRING
		do
			options := a_options
			create l_path.make (a_output.to_string_8)
			handle := c_encoder_create (l_path.item,
				a_options.video_width, a_options.video_height,
				a_options.frame_rate,
				a_options.sample_rate, a_options.audio_channels)
			if handle /= default_pointer then
				is_open := True
			else
				is_open := False
				last_error := "Failed to create encoder: " + a_output.to_string_32
			end
		end

feature -- Status

	is_open: BOOLEAN
			-- Is encoder open?

	frames_written: INTEGER
			-- Number of frames written.

	last_error: detachable STRING_32
			-- Last error message.

feature -- Configuration

	options: FFMPEG_ENCODER_OPTIONS
			-- Encoder options.

feature -- Encoding

	write_video_frame (a_frame: FFMPEG_VIDEO_FRAME): BOOLEAN
			-- Write video frame.
		require
			is_open: is_open
			frame_valid: a_frame /= Void
		do
			Result := c_encoder_write_video (handle, a_frame.handle) = 0
			if Result then
				frames_written := frames_written + 1
			end
		end

	write_audio_frame (a_frame: FFMPEG_AUDIO_FRAME): BOOLEAN
			-- Write audio frame.
		require
			is_open: is_open
			frame_valid: a_frame /= Void
		do
			Result := c_encoder_write_audio (handle, a_frame.handle) = 0
		end

feature -- Cleanup

	finalize
			-- Flush encoder and write trailer.
		require
			is_open: is_open
		do
			c_encoder_finalize (handle)
		end

	close
			-- Close encoder and free resources.
		require
			is_open: is_open
		do
			c_encoder_close (handle)
			handle := default_pointer
			is_open := False
		ensure
			closed: not is_open
		end

feature {NONE} -- Implementation

	handle: POINTER
			-- C encoder handle.

feature {NONE} -- C Externals

	c_encoder_create (a_path: POINTER; a_width, a_height: INTEGER; a_fps: REAL_64;
	                  a_sample_rate, a_channels: INTEGER): POINTER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_encoder_create((const char *)$a_path, $a_width, $a_height, $a_fps, $a_sample_rate, $a_channels);"
		end

	c_encoder_write_video (a_handle, a_frame: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_encoder_write_video($a_handle, $a_frame);"
		end

	c_encoder_write_audio (a_handle, a_frame: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_encoder_write_audio($a_handle, $a_frame);"
		end

	c_encoder_finalize (a_handle: POINTER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_encoder_finalize($a_handle);"
		end

	c_encoder_close (a_handle: POINTER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_encoder_close($a_handle);"
		end

end
