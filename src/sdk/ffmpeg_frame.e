note
	description: "[
		FFMPEG_FRAME - Base class for decoded frames

		Common properties shared by video and audio frames.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FFMPEG_FRAME

feature -- Access

	timestamp: REAL_64
			-- Presentation timestamp in seconds.

	handle: POINTER
			-- C frame handle.

feature -- Status

	is_video: BOOLEAN
			-- Is this a video frame?
		deferred
		end

	is_audio: BOOLEAN
			-- Is this an audio frame?
		deferred
		end

feature -- Cleanup

	dispose
			-- Free frame resources.
		deferred
		end

end
