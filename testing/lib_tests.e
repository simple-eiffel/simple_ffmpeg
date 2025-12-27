note
	description: "Tests for SIMPLE_FFMPEG CLI mode"
	author: "Larry Rix"

class
	LIB_TESTS

inherit
	TEST_SET_BASE

feature -- Test: Initialization

	test_initialization
		local
			ffmpeg: SIMPLE_FFMPEG
		do
			create ffmpeg.make
			assert_true ("cli created", ffmpeg /= Void)
		end

	test_version
		local
			ffmpeg: SIMPLE_FFMPEG
		do
			create ffmpeg.make
			assert_true ("has version", not ffmpeg.version.is_empty)
		end

feature -- Test: Options

	test_default_options
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			assert_strings_equal ("video codec", "libx264", opts.video_codec)
			assert_strings_equal ("audio codec", "aac", opts.audio_codec)
			assert_integers_equal ("video bitrate", 2_000_000, opts.video_bitrate)
			assert_integers_equal ("audio bitrate", 128_000, opts.audio_bitrate)
		end

	test_fluent_setters
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_video_codec ("libx265")
						.set_resolution (1280, 720)
						.set_video_bitrate (3_000_000)
			assert_strings_equal ("codec changed", "libx265", opts.video_codec)
			assert_integers_equal ("width", 1280, opts.video_width)
			assert_integers_equal ("height", 720, opts.video_height)
			assert_integers_equal ("bitrate", 3_000_000, opts.video_bitrate)
		end

	test_preset_web
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.preset_web
			assert_integers_equal ("web width", 1280, opts.video_width)
			assert_integers_equal ("web height", 720, opts.video_height)
		end

	test_copy_options
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.copy_video.copy_audio
			assert_strings_equal ("video copy", "copy", opts.video_codec)
			assert_strings_equal ("audio copy", "copy", opts.audio_codec)
		end

	test_disable_streams
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.disable_video.disable_audio
			assert_true ("no video", opts.no_video)
			assert_true ("no audio", opts.no_audio)
		end

feature -- Test: Media Info

	test_media_info_creation
		local
			info: FFMPEG_MEDIA_INFO
		do
			create info.make_empty
			assert_integers_equal ("zero duration", 0, info.duration.truncated_to_integer)
		end

	test_media_info_empty_values
		local
			info: FFMPEG_MEDIA_INFO
		do
			create info.make_empty
			assert_integers_equal ("zero width", 0, info.video_width)
			assert_integers_equal ("zero height", 0, info.video_height)
			assert_integers_equal ("zero sample rate", 0, info.audio_sample_rate)
			assert_true ("zero duration", info.duration < 0.001)
		end

feature -- Test: CLI Backend

	test_cli_creation
		local
			cli: FFMPEG_CLI
		do
			create cli.make
			assert_true ("cli created", cli /= Void)
		end

feature -- Edge Case Tests: Options

	test_empty_codec_string
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_video_codec ("")
			assert_strings_equal ("empty codec allowed", "", opts.video_codec)
		end

	test_min_resolution
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_resolution (1, 1)
			assert_integers_equal ("min width", 1, opts.video_width)
			assert_integers_equal ("min height", 1, opts.video_height)
		end

	test_very_large_resolution
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_resolution (7680, 4320)
			assert_integers_equal ("8k width", 7680, opts.video_width)
			assert_integers_equal ("8k height", 4320, opts.video_height)
		end

	test_odd_resolution
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_resolution (1921, 1081)
			assert_integers_equal ("odd width", 1921, opts.video_width)
			assert_integers_equal ("odd height", 1081, opts.video_height)
		end

	test_min_bitrate
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_video_bitrate (1)
			assert_integers_equal ("min bitrate", 1, opts.video_bitrate)
		end

	test_very_high_bitrate
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.set_video_bitrate (100_000_000)
			assert_integers_equal ("high bitrate", 100_000_000, opts.video_bitrate)
		end

	test_all_presets
		local
			opts: FFMPEG_OPTIONS
		do
			create opts.make
			opts := opts.preset_web
			assert_true ("preset_web ok", opts.video_width > 0)

			create opts.make
			opts := opts.preset_fast
			assert_true ("preset_fast ok", opts.video_codec.count > 0)

			create opts.make
			opts := opts.preset_quality
			assert_true ("preset_quality ok", opts.video_codec.count > 0)
		end

feature -- Edge Case Tests: Multiple Operations

	test_reinitialize_ffmpeg
		local
			ff1, ff2, ff3: SIMPLE_FFMPEG
		do
			create ff1.make
			create ff2.make
			create ff3.make
			assert_true ("all created", ff1 /= Void and ff2 /= Void and ff3 /= Void)
		end

	test_rapid_option_changes
		local
			opts: FFMPEG_OPTIONS
			i: INTEGER
		do
			create opts.make
			from i := 1 until i > 100 loop
				opts := opts.set_video_bitrate (i * 1000)
				i := i + 1
			end
			assert_integers_equal ("final bitrate", 100000, opts.video_bitrate)
		end

end
