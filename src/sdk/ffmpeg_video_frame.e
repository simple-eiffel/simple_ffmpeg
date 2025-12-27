note
	description: "[
		FFMPEG_VIDEO_FRAME - Decoded video frame

		Contains decoded video data that can be converted to
		RGB/RGBA or saved as an image file.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	FFMPEG_VIDEO_FRAME

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
			width := c_frame_width (handle)
			height := c_frame_height (handle)
			timestamp := c_frame_timestamp (handle)
		end

feature -- Access

	width: INTEGER
			-- Frame width in pixels.

	height: INTEGER
			-- Frame height in pixels.

	pixel_format: INTEGER
			-- Pixel format code.
		do
			Result := c_frame_pixel_format (handle)
		end

feature -- Status

	is_video: BOOLEAN = True
			-- Is this a video frame?

	is_audio: BOOLEAN = False
			-- Is this an audio frame?

feature -- Data Access

	to_rgb: ARRAY [NATURAL_8]
			-- Convert to RGB byte array (3 bytes per pixel).
		local
			l_size: INTEGER
			l_data: MANAGED_POINTER
		do
			l_size := width * height * 3
			create l_data.make (l_size)
			c_frame_to_rgb (handle, l_data.item, l_size)
			create Result.make_filled (0, 1, l_size)
			copy_to_array (l_data, Result, l_size)
		end

	to_rgba: ARRAY [NATURAL_8]
			-- Convert to RGBA byte array (4 bytes per pixel).
		local
			l_size: INTEGER
			l_data: MANAGED_POINTER
		do
			l_size := width * height * 4
			create l_data.make (l_size)
			c_frame_to_rgba (handle, l_data.item, l_size)
			create Result.make_filled (0, 1, l_size)
			copy_to_array (l_data, Result, l_size)
		end

feature -- Image Output

	save_as_jpeg (a_path: READABLE_STRING_GENERAL; a_quality: INTEGER): BOOLEAN
			-- Save frame as JPEG image.
		require
			path_not_empty: not a_path.is_empty
			valid_quality: a_quality >= 1 and a_quality <= 100
		local
			l_path: C_STRING
		do
			create l_path.make (a_path.to_string_8)
			Result := c_frame_save_jpeg (handle, l_path.item, a_quality) = 0
		end

	save_as_png (a_path: READABLE_STRING_GENERAL): BOOLEAN
			-- Save frame as PNG image.
		require
			path_not_empty: not a_path.is_empty
		local
			l_path: C_STRING
		do
			create l_path.make (a_path.to_string_8)
			Result := c_frame_save_png (handle, l_path.item) = 0
		end

feature -- Cleanup

	dispose
			-- Free frame resources.
		do
			if handle /= default_pointer then
				c_frame_free (handle)
				handle := default_pointer
			end
		end

feature {NONE} -- Implementation

	copy_to_array (a_src: MANAGED_POINTER; a_dest: ARRAY [NATURAL_8]; a_size: INTEGER)
			-- Copy data from managed pointer to array.
		local
			i: INTEGER
		do
			from i := 1 until i > a_size loop
				a_dest [i] := a_src.read_natural_8 (i - 1)
				i := i + 1
			end
		end

feature {NONE} -- C Externals

	c_frame_width (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_width($a_handle);"
		end

	c_frame_height (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_height($a_handle);"
		end

	c_frame_timestamp (a_handle: POINTER): REAL_64
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_timestamp($a_handle);"
		end

	c_frame_pixel_format (a_handle: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_pixel_format($a_handle);"
		end

	c_frame_to_rgb (a_handle, a_buffer: POINTER; a_size: INTEGER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_frame_to_rgb($a_handle, $a_buffer, $a_size);"
		end

	c_frame_to_rgba (a_handle, a_buffer: POINTER; a_size: INTEGER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_frame_to_rgba($a_handle, $a_buffer, $a_size);"
		end

	c_frame_save_jpeg (a_handle, a_path: POINTER; a_quality: INTEGER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_save_jpeg($a_handle, (const char *)$a_path, $a_quality);"
		end

	c_frame_save_png (a_handle, a_path: POINTER): INTEGER
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"return ffmpeg_frame_save_png($a_handle, (const char *)$a_path);"
		end

	c_frame_free (a_handle: POINTER)
		external
			"C inline use %"ffmpeg_bridge.h%""
		alias
			"ffmpeg_frame_free($a_handle);"
		end

end
