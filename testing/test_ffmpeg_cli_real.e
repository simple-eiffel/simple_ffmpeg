note
	description: "[
		FFMPEG_CLI against the real ffmpeg and ffprobe, which must be on PATH.
		Each test makes a one-second sample with ffmpeg's own test source,
		so no media files are kept in the repository.
	]"
	author: "Larry Rix"

class
	TEST_FFMPEG_CLI_REAL

inherit
	TEST_SET_BASE

feature -- Tests

	test_finds_ffmpeg_and_ffprobe
			-- Both programs are found and ffmpeg reports a version.
		local
			l_cli: FFMPEG_CLI
		do
			create l_cli.make
			assert_true ("ffmpeg found", l_cli.is_available)
			assert_true ("ffprobe found", l_cli.is_ffprobe_available)
			assert_true ("version read", attached l_cli.ffmpeg_version as v and then not v.is_empty)
		end

	test_probe_reads_a_real_file
			-- ffprobe's answer reaches FFMPEG_MEDIA_INFO.
		local
			l_cli: FFMPEG_CLI
		do
			make_sample (Sample_name)
			create l_cli.make
			if attached l_cli.probe (Sample_name) as l_info then
				assert_true ("has video", l_info.has_video)
				assert_integers_equal ("width", 64, l_info.video_width)
				assert_integers_equal ("height", 48, l_info.video_height)
				assert_true ("has audio", l_info.has_audio)
				assert_true ("about one second: " + l_info.duration.out, l_info.duration > 0.5 and l_info.duration < 1.5)
			else
				assert_true ("probe answered: " + error_text (l_cli), False)
			end
			delete (Sample_name)
		end

	test_transcode_writes_a_file
			-- A transcode that works reports success and leaves a file ffprobe can read.
		local
			l_cli: FFMPEG_CLI
		do
			make_sample (Sample_name)
			create l_cli.make
			assert_true ("transcoded: " + error_text (l_cli), l_cli.transcode (Sample_name, Output_name))
			assert_true ("output exists", (create {RAW_FILE}.make_with_name (Output_name)).exists)
			if attached l_cli.probe (Output_name) as l_info then
				assert_integers_equal ("width kept", 64, l_info.video_width)
			else
				assert_true ("output probed", False)
			end
			delete (Sample_name)
			delete (Output_name)
		end

	test_failed_transcode_is_a_failure
			-- ffmpeg runs but exits non-zero on a missing input: that is a failure.
		local
			l_cli: FFMPEG_CLI
		do
			delete (Output_name)
			create l_cli.make
			assert_false ("not transcoded", l_cli.transcode ("ffmpeg_test_no_such_input.mp4", Output_name))
			assert_true ("has error", l_cli.has_error)
			assert_false ("no output", (create {RAW_FILE}.make_with_name (Output_name)).exists)
		end

	test_failed_probe_gives_nothing
			-- ffprobe on a missing file gives no media info.
		local
			l_cli: FFMPEG_CLI
		do
			create l_cli.make
			assert_true ("no info", l_cli.probe ("ffmpeg_test_no_such_input.mp4") = Void)
		end

feature {NONE} -- Sample files

	Sample_name: STRING = "ffmpeg_test_sample.mp4"
			-- One second of test pattern and tone.

	Output_name: STRING = "ffmpeg_test_output.mkv"
			-- Where transcodes write.

	make_sample (a_name: STRING)
			-- Write a one-second 64x48 video with a tone to `a_name'.
		local
			l_process: SIMPLE_PROCESS
		do
			create l_process.make
			l_process.execute ("ffmpeg -y -v error -f lavfi -i testsrc=duration=1:size=64x48:rate=10 -f lavfi -i sine=frequency=440:duration=1 -shortest -pix_fmt yuv420p " + a_name)
			assert_true ("sample made", l_process.was_successful and then l_process.last_exit_code = 0)
		end

	delete (a_name: STRING)
			-- Remove `a_name' if it exists.
		local
			l_file: RAW_FILE
		do
			create l_file.make_with_name (a_name)
			if l_file.exists then
				l_file.delete
			end
		end

	error_text (a_cli: FFMPEG_CLI): STRING_32
			-- `a_cli''s last error, or empty.
		do
			if attached a_cli.last_error as l_error then
				Result := l_error
			else
				create Result.make_empty
			end
		end

end
