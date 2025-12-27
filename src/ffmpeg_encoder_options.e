note
	description: "[
		FFMPEG_ENCODER_OPTIONS - Options for creating an encoder

		Configuration for output format, codecs, and quality.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_ENCODER_OPTIONS

inherit
	FFMPEG_OPTIONS
		rename
			make as make_options
		end

create
	make,
	make_video,
	make_audio

feature {NONE} -- Initialization

	make (a_width, a_height: INTEGER; a_fps: REAL_64)
			-- Create encoder options for video.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
			valid_fps: a_fps > 0.0
		do
			make_options
			video_width := a_width
			video_height := a_height
			frame_rate := a_fps
		end

	make_video (a_width, a_height: INTEGER)
			-- Create video-only encoder options.
		require
			valid_width: a_width > 0
			valid_height: a_height > 0
		do
			make_options
			video_width := a_width
			video_height := a_height
			frame_rate := 30.0
			no_audio := True
		end

	make_audio (a_rate, a_channels: INTEGER)
			-- Create audio-only encoder options.
		require
			valid_rate: a_rate > 0
			valid_channels: a_channels >= 1 and a_channels <= 8
		do
			make_options
			sample_rate := a_rate
			audio_channels := a_channels
			no_video := True
		end

end
