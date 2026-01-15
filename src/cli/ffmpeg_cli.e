note
	description: "[
		FFMPEG_CLI - Command-line interface wrapper for FFmpeg

		Provides FFmpeg functionality by executing ffmpeg.exe/ffprobe.exe
		from the command line. This allows the library to work without
		the SDK installed - users only need ffmpeg.exe in their PATH.

		Operations supported:
		- probe: Get media file info using ffprobe -print_format json
		- transcode: Convert media files using ffmpeg
		- extract_audio: Extract audio track from video
		- extract_frame: Extract single frame as image
		- resize: Resize video to specified dimensions

		Example:
			cli: FFMPEG_CLI
			create cli.make
			if cli.is_available then
				if attached cli.probe ("video.mp4") as info then
					print (info.duration.out + " seconds%N")
				end
			end
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_CLI

inherit
	SIMPLE_PROCESS
		rename
			make as make_process,
			last_error as process_last_error,
			last_output as process_last_output
		end

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize CLI wrapper and detect ffmpeg.
		do
			make_process
			detect_ffmpeg
		end

feature -- Status

	is_available: BOOLEAN
			-- Is ffmpeg.exe available in PATH?
		do
			Result := ffmpeg_path /= Void
		end

	is_ffprobe_available: BOOLEAN
			-- Is ffprobe.exe available?
		do
			Result := ffprobe_path /= Void
		end

	ffmpeg_path: detachable STRING_32
			-- Full path to ffmpeg.exe (or just "ffmpeg" if in PATH).

	ffprobe_path: detachable STRING_32
			-- Full path to ffprobe.exe.

	ffmpeg_version: detachable STRING_32
			-- FFmpeg version string.

	last_error: detachable STRING_32
			-- Last error message.

	last_output: detachable STRING_32
			-- Last command output.

	has_error: BOOLEAN
			-- Did last operation fail?
		do
			Result := last_error /= Void
		end

feature -- Configuration

	set_ffmpeg_path (a_path: READABLE_STRING_GENERAL)
			-- Set path to ffmpeg executable.
		do
			ffmpeg_path := a_path.to_string_32
		ensure
			path_set: attached ffmpeg_path as p and then p.same_string_general (a_path)
		end

	set_ffprobe_path (a_path: READABLE_STRING_GENERAL)
			-- Set path to ffprobe executable.
		do
			ffprobe_path := a_path.to_string_32
		ensure
			path_set: attached ffprobe_path as p and then p.same_string_general (a_path)
		end

feature -- Probe

	probe (a_file: READABLE_STRING_GENERAL): detachable FFMPEG_MEDIA_INFO
			-- Get media file information using ffprobe.
		require
			available: is_ffprobe_available
			file_not_empty: not a_file.is_empty
		local
			l_cmd: STRING_32
			l_result: STRING_32
		do
			clear_error
			if attached ffprobe_path as fp then
				create l_cmd.make (200)
				l_cmd.append (fp)
				l_cmd.append (" -v quiet -print_format json -show_format -show_streams %"")
				l_cmd.append (a_file.to_string_32)
				l_cmd.append ("%"")

				l_result := execute_capture (l_cmd)
				if not has_error and then l_result /= Void then
					Result := parse_probe_json (l_result)
				end
			end
		end

feature -- Transcoding

	transcode (a_input, a_output: READABLE_STRING_GENERAL): BOOLEAN
			-- Transcode with default settings.
		require
			available: is_available
			input_not_empty: not a_input.is_empty
			output_not_empty: not a_output.is_empty
		do
			Result := transcode_with_args (a_input, a_output, "")
		end

	transcode_with_options (a_input, a_output: READABLE_STRING_GENERAL;
	                        a_options: FFMPEG_OPTIONS): BOOLEAN
			-- Transcode with specified options.
		require
			available: is_available
			input_not_empty: not a_input.is_empty
			output_not_empty: not a_output.is_empty
		local
			l_args: STRING_32
		do
			l_args := build_transcode_args (a_options)
			Result := transcode_with_args (a_input, a_output, l_args)
		end

	transcode_with_args (a_input, a_output: READABLE_STRING_GENERAL;
	                     a_args: READABLE_STRING_GENERAL): BOOLEAN
			-- Transcode with raw ffmpeg arguments.
		require
			available: is_available
		local
			l_cmd: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				create l_cmd.make (500)
				l_cmd.append (fp)
				l_cmd.append (" -y -i %"")
				l_cmd.append (a_input.to_string_32)
				l_cmd.append ("%" ")
				if not a_args.is_empty then
					l_cmd.append (a_args.to_string_32)
					l_cmd.append (" ")
				end
				l_cmd.append ("%"")
				l_cmd.append (a_output.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
		end

feature -- Audio Operations

	extract_audio (a_video, a_audio: READABLE_STRING_GENERAL): BOOLEAN
			-- Extract audio track from video.
		require
			available: is_available
			video_not_empty: not a_video.is_empty
			audio_not_empty: not a_audio.is_empty
		local
			l_cmd: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				create l_cmd.make (300)
				l_cmd.append (fp)
				l_cmd.append (" -y -i %"")
				l_cmd.append (a_video.to_string_32)
				l_cmd.append ("%" -vn -acodec copy %"")
				l_cmd.append (a_audio.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
		end

feature -- Video Operations

	extract_frame (a_video: READABLE_STRING_GENERAL;
	               a_time: REAL_64;
	               a_output: READABLE_STRING_GENERAL): BOOLEAN
			-- Extract single frame at timestamp.
		require
			available: is_available
			video_not_empty: not a_video.is_empty
			time_positive: a_time >= 0.0
			output_not_empty: not a_output.is_empty
		local
			l_cmd: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				create l_cmd.make (300)
				l_cmd.append (fp)
				l_cmd.append (" -y -ss ")
				l_cmd.append (format_time (a_time))
				l_cmd.append (" -i %"")
				l_cmd.append (a_video.to_string_32)
				l_cmd.append ("%" -frames:v 1 %"")
				l_cmd.append (a_output.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
		end

	images_to_video (a_pattern, a_output: READABLE_STRING_GENERAL; a_fps: INTEGER): BOOLEAN
			-- Create video from image sequence.
			-- `a_pattern` is printf-style pattern like "frames/frame_%05d.bmp"
			-- Supports BMP, PNG, JPG input formats.
			-- Output codec determined by extension (.mp4=H.264, .webm=VP9, .avi=MPEG4)
		require
			available: is_available
			pattern_not_empty: not a_pattern.is_empty
			output_not_empty: not a_output.is_empty
			valid_fps: a_fps > 0
		local
			l_cmd: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				create l_cmd.make (400)
				l_cmd.append (fp)
				l_cmd.append (" -y -framerate ")
				l_cmd.append_integer (a_fps)
				l_cmd.append (" -i %"")
				l_cmd.append (a_pattern.to_string_32)
				l_cmd.append ("%" -c:v libx264 -pix_fmt yuv420p -crf 18 %"")
				l_cmd.append (a_output.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
		end

	images_to_video_with_options (a_pattern, a_output: READABLE_STRING_GENERAL;
	                              a_fps: INTEGER; a_options: FFMPEG_OPTIONS): BOOLEAN
			-- Create video from image sequence with custom options.
		require
			available: is_available
			pattern_not_empty: not a_pattern.is_empty
			output_not_empty: not a_output.is_empty
			valid_fps: a_fps > 0
		local
			l_cmd: STRING_32
			l_args: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				l_args := build_transcode_args (a_options)
				create l_cmd.make (500)
				l_cmd.append (fp)
				l_cmd.append (" -y -framerate ")
				l_cmd.append_integer (a_fps)
				l_cmd.append (" -i %"")
				l_cmd.append (a_pattern.to_string_32)
				l_cmd.append ("%" ")
				if not l_args.is_empty then
					l_cmd.append (l_args)
					l_cmd.append (" ")
				end
				l_cmd.append ("%"")
				l_cmd.append (a_output.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
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
		local
			l_cmd: STRING_32
		do
			clear_error
			if attached ffmpeg_path as fp then
				create l_cmd.make (300)
				l_cmd.append (fp)
				l_cmd.append (" -y -i %"")
				l_cmd.append (a_input.to_string_32)
				l_cmd.append ("%" -vf scale=")
				l_cmd.append_integer (a_width)
				l_cmd.append_character (':')
				l_cmd.append_integer (a_height)
				l_cmd.append (" %"")
				l_cmd.append (a_output.to_string_32)
				l_cmd.append ("%"")

				Result := execute_silent (l_cmd)
			end
		end

feature {NONE} -- Detection

	detect_ffmpeg
			-- Detect ffmpeg and ffprobe availability.
		local
			l_result: STRING_32
		do
			-- Try ffmpeg
			l_result := execute_capture ("ffmpeg -version")
			if not has_error then
				ffmpeg_path := "ffmpeg"
				parse_version (l_result)
			else
				-- Try common Windows locations
				clear_error
				l_result := execute_capture ("where ffmpeg")
				if not has_error and then l_result /= Void and then not l_result.is_empty then
					ffmpeg_path := l_result.split ('%N').first
					if attached ffmpeg_path as fp then
						fp.right_adjust
					end
				end
			end

			-- Try ffprobe
			clear_error
			l_result := execute_capture ("ffprobe -version")
			if not has_error then
				ffprobe_path := "ffprobe"
			else
				clear_error
				l_result := execute_capture ("where ffprobe")
				if not has_error and then l_result /= Void and then not l_result.is_empty then
					ffprobe_path := l_result.split ('%N').first
					if attached ffprobe_path as fp then
						fp.right_adjust
					end
				end
			end

			clear_error  -- Don't keep detection errors
		end

	parse_version (a_output: READABLE_STRING_GENERAL)
			-- Extract version from ffmpeg -version output.
		local
			l_lines: LIST [STRING_32]
			l_first: STRING_32
			l_start, l_end: INTEGER
		do
			l_lines := a_output.to_string_32.split ('%N')
			if not l_lines.is_empty then
				l_first := l_lines.first
				-- Format: "ffmpeg version N.N.N ..."
				l_start := l_first.substring_index ("version ", 1)
				if l_start > 0 then
					l_start := l_start + 8
					l_end := l_first.index_of (' ', l_start)
					if l_end = 0 then
						l_end := l_first.count
					end
					if l_end > l_start then
						ffmpeg_version := l_first.substring (l_start, l_end - 1)
					end
				end
			end
		end

feature {NONE} -- Execution

	execute_capture (a_cmd: READABLE_STRING_GENERAL): STRING_32
			-- Execute command and capture stdout using SIMPLE_PROCESS.
		do
			execute (a_cmd)
			if was_successful and then attached process_last_output as o then
				Result := o
				last_output := Result
			else
				create Result.make_empty
				set_error ("Command failed with exit code " + last_exit_code.out)
			end
		rescue
			set_error ("Execution error")
			create Result.make_empty
		end

	execute_silent (a_cmd: READABLE_STRING_GENERAL): BOOLEAN
			-- Execute command silently, return True on success.
		do
			clear_error
			execute (a_cmd)
			Result := was_successful
			if not Result then
				set_error ("Command failed with exit code " + last_exit_code.out)
			end
		rescue
			set_error ("Execution error")
			Result := False
		end

feature {NONE} -- Argument Building

	build_transcode_args (a_opts: FFMPEG_OPTIONS): STRING_32
			-- Build ffmpeg arguments from options.
		do
			create Result.make (200)

			-- Video options
			if a_opts.no_video then
				Result.append ("-vn ")
			else
				if not a_opts.video_codec.is_empty and then
				   not a_opts.video_codec.same_string ("libx264") then
					Result.append ("-c:v ")
					Result.append (a_opts.video_codec)
					Result.append (" ")
				end
				if a_opts.video_bitrate > 0 then
					Result.append ("-b:v ")
					Result.append_integer (a_opts.video_bitrate)
					Result.append (" ")
				end
				if a_opts.video_width > 0 and a_opts.video_height > 0 then
					Result.append ("-vf scale=")
					Result.append_integer (a_opts.video_width)
					Result.append_character (':')
					Result.append_integer (a_opts.video_height)
					Result.append (" ")
				end
				if a_opts.frame_rate > 0.0 then
					Result.append ("-r ")
					Result.append (a_opts.frame_rate.out)
					Result.append (" ")
				end
			end

			-- Audio options
			if a_opts.no_audio then
				Result.append ("-an ")
			else
				if not a_opts.audio_codec.is_empty and then
				   not a_opts.audio_codec.same_string ("aac") then
					Result.append ("-c:a ")
					Result.append (a_opts.audio_codec)
					Result.append (" ")
				end
				if a_opts.audio_bitrate > 0 then
					Result.append ("-b:a ")
					Result.append_integer (a_opts.audio_bitrate)
					Result.append (" ")
				end
				if a_opts.sample_rate > 0 then
					Result.append ("-ar ")
					Result.append_integer (a_opts.sample_rate)
					Result.append (" ")
				end
				if a_opts.audio_channels > 0 then
					Result.append ("-ac ")
					Result.append_integer (a_opts.audio_channels)
					Result.append (" ")
				end
			end

			Result.right_adjust
		end

	format_time (a_seconds: REAL_64): STRING_32
			-- Format seconds as HH:MM:SS.mmm for ffmpeg.
		local
			l_hours, l_mins, l_secs: INTEGER
			l_frac: REAL_64
		do
			l_hours := (a_seconds / 3600).truncated_to_integer
			l_mins := ((a_seconds - l_hours * 3600) / 60).truncated_to_integer
			l_secs := (a_seconds - l_hours * 3600 - l_mins * 60).truncated_to_integer
			l_frac := a_seconds - a_seconds.truncated_to_integer

			create Result.make (12)
			if l_hours < 10 then Result.append_character ('0') end
			Result.append_integer (l_hours)
			Result.append_character (':')
			if l_mins < 10 then Result.append_character ('0') end
			Result.append_integer (l_mins)
			Result.append_character (':')
			if l_secs < 10 then Result.append_character ('0') end
			Result.append_integer (l_secs)
			Result.append_character ('.')
			Result.append (((l_frac * 1000).truncated_to_integer).out)
		end

feature {NONE} -- JSON Parsing (Simple)

	parse_probe_json (a_json: READABLE_STRING_GENERAL): detachable FFMPEG_MEDIA_INFO
			-- Parse ffprobe JSON output into FFMPEG_MEDIA_INFO.
			-- Uses simple string parsing (no JSON library dependency).
		local
			l_info: FFMPEG_MEDIA_INFO
			l_json: STRING_32
		do
			create l_info.make_empty
			l_json := a_json.to_string_32

			-- Parse format section
			l_info.set_duration (parse_json_number (l_json, "duration"))
			l_info.set_format_name (parse_json_string (l_json, "format_name"))

			-- Parse video stream (first one found)
			if l_json.has_substring ("%"codec_type%": %"video%"") or
			   l_json.has_substring ("%"codec_type%":%"video%"") then
				l_info.set_has_video (True)
				l_info.set_video_width (parse_json_integer (l_json, "width"))
				l_info.set_video_height (parse_json_integer (l_json, "height"))
				l_info.set_video_codec (parse_json_string (l_json, "codec_name"))
			end

			-- Parse audio stream
			if l_json.has_substring ("%"codec_type%": %"audio%"") or
			   l_json.has_substring ("%"codec_type%":%"audio%"") then
				l_info.set_has_audio (True)
				l_info.set_audio_sample_rate (parse_json_integer (l_json, "sample_rate"))
				l_info.set_audio_channels (parse_json_integer (l_json, "channels"))
			end

			Result := l_info
		rescue
			-- JSON parsing failed
			Result := Void
		end

	parse_json_string (a_json: STRING_32; a_key: STRING): STRING_32
			-- Extract string value for key from JSON.
		local
			l_pattern: STRING_32
			l_start, l_end: INTEGER
		do
			create Result.make_empty
			create l_pattern.make_from_string ("%"")
			l_pattern.append_string_general (a_key)
			l_pattern.append ("%": %"")

			l_start := a_json.substring_index (l_pattern, 1)
			if l_start > 0 then
				l_start := l_start + l_pattern.count
				l_end := a_json.index_of ('"', l_start)
				if l_end > l_start then
					Result := a_json.substring (l_start, l_end - 1)
				end
			end
		end

	parse_json_number (a_json: STRING_32; a_key: STRING): REAL_64
			-- Extract number value for key from JSON.
		local
			l_str: STRING_32
			l_pattern: STRING_32
			l_start, l_end: INTEGER
			l_char: CHARACTER_32
		do
			-- Try quoted number first (ffprobe often quotes numbers)
			l_str := parse_json_string (a_json, a_key)
			if l_str.is_empty then
				-- Try unquoted
				create l_pattern.make_from_string ("%"")
				l_pattern.append_string_general (a_key)
				l_pattern.append ("%": ")

				l_start := a_json.substring_index (l_pattern, 1)
				if l_start > 0 then
					l_start := l_start + l_pattern.count
					from l_end := l_start until l_end > a_json.count or else
						not (a_json.item (l_end).is_digit or a_json.item (l_end) = '.')
					loop
						l_end := l_end + 1
					end
					if l_end > l_start then
						l_str := a_json.substring (l_start, l_end - 1)
					end
				end
			end

			if not l_str.is_empty and then l_str.is_double then
				Result := l_str.to_double
			end
		end

	parse_json_integer (a_json: STRING_32; a_key: STRING): INTEGER
			-- Extract integer value for key from JSON.
		do
			Result := parse_json_number (a_json, a_key).truncated_to_integer
		end

feature {NONE} -- Error Handling

	clear_error
			-- Clear last error.
		do
			last_error := Void
		end

	set_error (a_msg: READABLE_STRING_GENERAL)
			-- Set error message.
		do
			last_error := a_msg.to_string_32
		end

end
