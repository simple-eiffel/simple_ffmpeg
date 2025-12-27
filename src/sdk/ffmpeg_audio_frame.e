note
	description: "[
		FFMPEG_AUDIO_FRAME - Decoded audio frame

		Contains decoded audio samples that can be converted to
		PCM format (signed 16-bit or float).
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_AUDIO_FRAME

inherit
	FFMPEG_FRAME

create
	make_from_handle

feature {NONE} -- Initialization

	make_from_handle (a_handle: POINTER)
			-- Create from C frame handle.
		require
			valid_handle: a_handle /= default_pointer
		do
			handle := a_handle
			sample_rate := c_audio_sample_rate (handle)
			channels := c_audio_channels (handle)
			sample_count := c_audio_sample_count (handle)
			timestamp := c_audio_timestamp (handle)
		end

feature -- Access

	sample_rate: INTEGER
			-- Sample rate in Hz.

	channels: INTEGER
			-- Number of channels.

	sample_count: INTEGER
			-- Number of samples per channel.

	sample_format: INTEGER
			-- Sample format code.
		do
			Result := c_audio_sample_format (handle)
		end

	duration_ms: REAL_64
			-- Frame duration in milliseconds.
		do
			if sample_rate > 0 then
				Result := (sample_count.to_double / sample_rate.to_double) * 1000.0
			end
		end

feature -- Status

	is_video: BOOLEAN = False
			-- Is this a video frame?

	is_audio: BOOLEAN = True
			-- Is this an audio frame?

feature -- Data Access

	to_pcm_s16: ARRAY [INTEGER_16]
			-- Convert to signed 16-bit PCM.
		local
			l_size: INTEGER
			l_data: MANAGED_POINTER
			i: INTEGER
		do
			l_size := sample_count * channels
			create l_data.make (l_size * 2) -- 2 bytes per sample
			c_audio_to_s16 (handle, l_data.item, l_size)
			create Result.make_filled (0, 1, l_size)
			from i := 1 until i > l_size loop
				Result [i] := l_data.read_integer_16 ((i - 1) * 2)
				i := i + 1
			end
		end

	to_pcm_float: ARRAY [REAL_32]
			-- Convert to 32-bit float PCM.
		local
			l_size: INTEGER
			l_data: MANAGED_POINTER
			i: INTEGER
		do
			l_size := sample_count * channels
			create l_data.make (l_size * 4) -- 4 bytes per sample
			c_audio_to_float (handle, l_data.item, l_size)
			create Result.make_filled (0.0, 1, l_size)
			from i := 1 until i > l_size loop
				Result [i] := l_data.read_real_32 ((i - 1) * 4)
				i := i + 1
			end
		end

feature -- Cleanup

	dispose
			-- Free frame resources.
		do
			if handle /= default_pointer then
				c_audio_free (handle)
				handle := default_pointer
			end
		end

feature {NONE} -- C Externals

	c_audio_sample_rate (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_audio_sample_rate($a_handle);"
		end

	c_audio_channels (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_audio_channels($a_handle);"
		end

	c_audio_sample_count (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_audio_sample_count($a_handle);"
		end

	c_audio_timestamp (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_audio_timestamp($a_handle);"
		end

	c_audio_sample_format (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_audio_sample_format($a_handle);"
		end

	c_audio_to_s16 (a_handle, a_buffer: POINTER; a_size: INTEGER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_audio_to_s16($a_handle, $a_buffer, $a_size);"
		end

	c_audio_to_float (a_handle, a_buffer: POINTER; a_size: INTEGER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_audio_to_float($a_handle, $a_buffer, $a_size);"
		end

	c_audio_free (a_handle: POINTER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_audio_free($a_handle);"
		end

end
