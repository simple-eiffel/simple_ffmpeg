note
	description: "[
		SIMPLE_FFMPEG - FFmpeg multimedia library facade (CLI mode)

		Provides FFmpeg functionality by delegating to ffmpeg.exe/ffprobe.exe
		via command-line execution. This mode requires ffmpeg.exe in PATH
		but does not require the FFmpeg SDK to be installed.

		For SDK mode (native FFmpeg library calls), use simple_ffmpeg_sdk target
		which requires FFMPEG_SDK environment variable pointing to FFmpeg dev libs.

		Key Operations:
		- probe: Get media file metadata (duration, codecs, resolution)
		- transcode: Convert between formats with optional settings
		- extract_audio: Extract audio track from video file
		- extract_frame: Extract single frame as image
		- resize_video: Resize video to specified dimensions

		Example:
			ffmpeg: SIMPLE_FFMPEG
			create ffmpeg.make
			if ffmpeg.is_available then
				if attached ffmpeg.probe ("video.mp4") as info then
					print ("Duration: " + info.duration.out + " seconds%N")
					print ("Resolution: " + info.resolution_string + "%N")
				end
				ffmpeg.transcode ("input.mp4", "output.webm")
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_FFMPEG

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize FFmpeg CLI backend.
		do
			create cli.make
			is_available := cli.is_available
		ensure
			cli_created: cli /= Void
		end

feature -- Status

	is_available: BOOLEAN
			-- Is ffmpeg.exe available in PATH?

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := cli.has_error
		end

	last_error: detachable STRING_32
			-- Last error message.
		do
			Result := cli.last_error
		end

	version: STRING_32
			-- FFmpeg version string.
		do
			if attached cli.ffmpeg_version as v then
				Result := v
			else
				Result := "unknown"
			end
		end

feature -- Metadata

	probe (a_file: READABLE_STRING_GENERAL): detachable FFMPEG_MEDIA_INFO
			-- Get media file information.
		require
			available: is_available
			file_not_empty: not a_file.is_empty
		do
			Result := cli.probe (a_file)
		end

feature -- Transcoding

	transcode (a_input, a_output: READABLE_STRING_GENERAL): BOOLEAN
			-- Transcode with default settings.
		require
			available: is_available
			input_not_empty: not a_input.is_empty
			output_not_empty: not a_output.is_empty
		do
			Result := cli.transcode (a_input, a_output)
		end

	transcode_with_options (a_input, a_output: READABLE_STRING_GENERAL;
	                        a_options: FFMPEG_OPTIONS): BOOLEAN
			-- Transcode with specified options.
		require
			available: is_available
			input_not_empty: not a_input.is_empty
			output_not_empty: not a_output.is_empty
		do
			Result := cli.transcode_with_options (a_input, a_output, a_options)
		end

feature -- Audio Operations

	extract_audio (a_video, a_audio: READABLE_STRING_GENERAL): BOOLEAN
			-- Extract audio track from video file.
		require
			available: is_available
			video_not_empty: not a_video.is_empty
			audio_not_empty: not a_audio.is_empty
		do
			Result := cli.extract_audio (a_video, a_audio)
		end

feature -- Video Operations

	extract_frame (a_video: READABLE_STRING_GENERAL;
	               a_time: REAL_64;
	               a_output: READABLE_STRING_GENERAL): BOOLEAN
			-- Extract single frame at specified time.
		require
			available: is_available
			video_not_empty: not a_video.is_empty
			time_non_negative: a_time >= 0.0
			output_not_empty: not a_output.is_empty
		do
			Result := cli.extract_frame (a_video, a_time, a_output)
		end

	resize_video (a_input, a_output: READABLE_STRING_GENERAL;
	              a_width, a_height: INTEGER): BOOLEAN
			-- Resize video to specified dimensions.
		require
			available: is_available
			input_not_empty: not a_input.is_empty
			output_not_empty: not a_output.is_empty
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			Result := cli.resize_video (a_input, a_output, a_width, a_height)
		end

feature {NONE} -- Implementation

	cli: FFMPEG_CLI
			-- Command-line interface backend.

invariant
	cli_attached: cli /= Void

end
