note
	description: "[
		FFMPEG_TRANSCODER - High-level transcoding operations

		Fluent API for converting media files.

		Example:
			create transcoder.make ("input.mov", "output.mp4")
			transcoder
				.set_video_codec ("libx264")
				.set_video_bitrate (2_000_000)
				.set_resolution (1920, 1080)
				.set_audio_codec ("aac")
				.set_audio_bitrate (128_000)

			if transcoder.run then
				print ("Done%N")
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_TRANSCODER

inherit
	FFMPEG_OPTIONS
		rename
			make as make_options
		end

create
	make

feature {NONE} -- Initialization

	make (a_input, a_output: READABLE_STRING_GENERAL)
			-- Create transcoder for input/output files.
		require
			input_valid: not a_input.is_empty
			output_valid: not a_output.is_empty
		do
			make_options
			input_path := a_input.to_string_32
			output_path := a_output.to_string_32
		end

feature -- Access

	input_path: STRING_32
			-- Input file path.

	output_path: STRING_32
			-- Output file path.

	last_error: detachable STRING_32
			-- Last error message.

	progress: REAL_64
			-- Current progress (0.0 to 1.0).

feature -- Configuration

	apply_options (a_options: FFMPEG_OPTIONS)
			-- Apply options from another options object.
		require
			options_valid: a_options /= Void
		do
			video_codec := a_options.video_codec
			video_bitrate := a_options.video_bitrate
			video_width := a_options.video_width
			video_height := a_options.video_height
			frame_rate := a_options.frame_rate
			no_video := a_options.no_video
			audio_codec := a_options.audio_codec
			audio_bitrate := a_options.audio_bitrate
			sample_rate := a_options.sample_rate
			audio_channels := a_options.audio_channels
			no_audio := a_options.no_audio
		end

feature -- Execution

	run: BOOLEAN
			-- Execute transcoding synchronously.
		local
			l_input, l_output, l_vcodec, l_acodec: C_STRING
		do
			create l_input.make (input_path.to_string_8)
			create l_output.make (output_path.to_string_8)
			create l_vcodec.make (video_codec.to_string_8)
			create l_acodec.make (audio_codec.to_string_8)

			Result := c_transcode_full (
				l_input.item, l_output.item,
				l_vcodec.item, video_bitrate, video_width, video_height, frame_rate,
				l_acodec.item, audio_bitrate, sample_rate, audio_channels,
				no_video, no_audio
			) = 0

			if not Result then
				last_error := "Transcode failed"
			end
		end

feature {NONE} -- C Externals

	c_transcode_full (a_input, a_output, a_vcodec: POINTER;
	                  a_vbitrate, a_width, a_height: INTEGER; a_fps: REAL_64;
	                  a_acodec: POINTER; a_abitrate, a_srate, a_channels: INTEGER;
	                  a_no_video, a_no_audio: BOOLEAN): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"[
				return ffmpeg_transcode_full(
					(const char *)$a_input, (const char *)$a_output,
					(const char *)$a_vcodec, $a_vbitrate, $a_width, $a_height, $a_fps,
					(const char *)$a_acodec, $a_abitrate, $a_srate, $a_channels,
					$a_no_video, $a_no_audio
				);
			]"
		end

end
