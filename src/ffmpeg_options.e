note
	description: "[
		FFMPEG_OPTIONS - Transcoding options

		Fluent builder for configuring transcoding parameters.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_OPTIONS

create
	make

feature {NONE} -- Initialization

	make
			-- Create with default options.
		do
			video_codec := "libx264"
			audio_codec := "aac"
			video_bitrate := 2_000_000
			audio_bitrate := 128_000
		end

feature -- Video Options

	video_codec: STRING_32
			-- Video codec (libx264, libx265, libvpx-vp9, copy).

	video_bitrate: INTEGER
			-- Video bitrate in bits/second.

	video_width: INTEGER
			-- Output width (0 = keep original).

	video_height: INTEGER
			-- Output height (0 = keep original).

	frame_rate: REAL_64
			-- Output frame rate (0 = keep original).

	no_video: BOOLEAN
			-- Disable video stream.

feature -- Audio Options

	audio_codec: STRING_32
			-- Audio codec (aac, libmp3lame, flac, copy).

	audio_bitrate: INTEGER
			-- Audio bitrate in bits/second.

	sample_rate: INTEGER
			-- Audio sample rate (0 = keep original).

	audio_channels: INTEGER
			-- Number of channels (0 = keep original).

	no_audio: BOOLEAN
			-- Disable audio stream.

feature -- Fluent Setters

	set_video_codec (a_codec: READABLE_STRING_GENERAL): like Current
			-- Set video codec.
		do
			video_codec := a_codec.to_string_32
			Result := Current
		end

	set_video_bitrate (a_bitrate: INTEGER): like Current
			-- Set video bitrate.
		require
			positive: a_bitrate > 0
		do
			video_bitrate := a_bitrate
			Result := Current
		end

	set_resolution (a_width, a_height: INTEGER): like Current
			-- Set output resolution.
		require
			positive_width: a_width > 0
			positive_height: a_height > 0
		do
			video_width := a_width
			video_height := a_height
			Result := Current
		end

	set_frame_rate (a_fps: REAL_64): like Current
			-- Set output frame rate.
		require
			positive: a_fps > 0.0
		do
			frame_rate := a_fps
			Result := Current
		end

	set_audio_codec (a_codec: READABLE_STRING_GENERAL): like Current
			-- Set audio codec.
		do
			audio_codec := a_codec.to_string_32
			Result := Current
		end

	set_audio_bitrate (a_bitrate: INTEGER): like Current
			-- Set audio bitrate.
		require
			positive: a_bitrate > 0
		do
			audio_bitrate := a_bitrate
			Result := Current
		end

	set_sample_rate (a_rate: INTEGER): like Current
			-- Set audio sample rate.
		require
			positive: a_rate > 0
		do
			sample_rate := a_rate
			Result := Current
		end

	set_channels (a_count: INTEGER): like Current
			-- Set audio channel count.
		require
			valid: a_count >= 1 and a_count <= 8
		do
			audio_channels := a_count
			Result := Current
		end

	copy_video: like Current
			-- Copy video stream without re-encoding.
		do
			video_codec := "copy"
			Result := Current
		end

	copy_audio: like Current
			-- Copy audio stream without re-encoding.
		do
			audio_codec := "copy"
			Result := Current
		end

	disable_video: like Current
			-- Disable video in output.
		do
			no_video := True
			Result := Current
		end

	disable_audio: like Current
			-- Disable audio in output.
		do
			no_audio := True
			Result := Current
		end

feature -- Presets

	preset_fast: like Current
			-- Fast encoding preset.
		do
			Result := set_video_codec ("libx264")
			-- x264 uses presets but we'll use defaults for now
		end

	preset_quality: like Current
			-- Quality-focused encoding preset.
		do
			Result := set_video_codec ("libx264")
					 .set_video_bitrate (5_000_000)
					 .set_audio_bitrate (192_000)
		end

	preset_web: like Current
			-- Web-optimized preset.
		do
			Result := set_video_codec ("libx264")
					 .set_resolution (1280, 720)
					 .set_video_bitrate (2_500_000)
					 .set_audio_bitrate (128_000)
		end

end
