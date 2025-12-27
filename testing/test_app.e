note
	description: "Test application for SIMPLE_FFMPEG CLI mode"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
		do
			print ("Running SIMPLE_FFMPEG CLI tests...%N%N")
			passed := 0
			failed := 0
			run_lib_tests
			print ("%N========================%N")
			print ("Results: " + passed.out + " passed, " + failed.out + " failed%N")
			if failed > 0 then
				print ("TESTS FAILED%N")
			else
				print ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Test Runners

	run_lib_tests
		do
			create lib_tests
			run_test (agent lib_tests.test_initialization, "test_initialization")
			run_test (agent lib_tests.test_version, "test_version")
			run_test (agent lib_tests.test_default_options, "test_default_options")
			run_test (agent lib_tests.test_fluent_setters, "test_fluent_setters")
			run_test (agent lib_tests.test_preset_web, "test_preset_web")
			run_test (agent lib_tests.test_copy_options, "test_copy_options")
			run_test (agent lib_tests.test_disable_streams, "test_disable_streams")
			run_test (agent lib_tests.test_media_info_creation, "test_media_info_creation")
			run_test (agent lib_tests.test_media_info_empty_values, "test_media_info_empty_values")
			run_test (agent lib_tests.test_cli_creation, "test_cli_creation")
			run_test (agent lib_tests.test_empty_codec_string, "test_empty_codec_string")
			run_test (agent lib_tests.test_min_resolution, "test_zero_resolution")
			run_test (agent lib_tests.test_very_large_resolution, "test_very_large_resolution")
			run_test (agent lib_tests.test_odd_resolution, "test_odd_resolution")
			run_test (agent lib_tests.test_min_bitrate, "test_zero_bitrate")
			run_test (agent lib_tests.test_very_high_bitrate, "test_very_high_bitrate")
			run_test (agent lib_tests.test_all_presets, "test_all_presets")
			run_test (agent lib_tests.test_reinitialize_ffmpeg, "test_reinitialize_ffmpeg")
			run_test (agent lib_tests.test_rapid_option_changes, "test_rapid_option_changes")
		end

feature {NONE} -- Test Infrastructure

	run_test (a_test: PROCEDURE; a_name: STRING)
		local
			l_failed: BOOLEAN
		do
			if not l_failed then
				a_test.call (Void)
				passed := passed + 1
				print ("[PASS] " + a_name + "%N")
			end
		rescue
			l_failed := True
			failed := failed + 1
			print ("[FAIL] " + a_name + "%N")
			retry
		end

	passed: INTEGER
	failed: INTEGER

feature {NONE} -- Test Objects

	lib_tests: LIB_TESTS

end
