--  Thin extern "C" bindings to stb_image. Internal use only;
--  consumers should call Stb.Image's public API instead.
--
--  Function names preserve the `stbi_` prefix to keep a 1:1
--  grep against vendor/stb/stb_image.h.

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;
with System;

package Stb.Image.C is

   subtype Chars_Ptr is Interfaces.C.Strings.chars_ptr;

   --  Load via filename. x, y, channels_in_file are out-params.
   --  desired_channels: 0 to keep native, 1..4 to force conversion.
   --  Returns malloc'd buffer of width * height * desired_channels
   --  bytes (8 bits per channel). NULL on failure.
   function stbi_load
     (Filename         : Chars_Ptr;
      X                : access int;
      Y                : access int;
      Channels_In_File : access int;
      Desired_Channels : int) return System.Address
     with Import, Convention => C, External_Name => "stbi_load";

   --  Load from a memory buffer. Same x/y/channels semantics.
   function stbi_load_from_memory
     (Buffer           : System.Address;
      Length           : int;
      X                : access int;
      Y                : access int;
      Channels_In_File : access int;
      Desired_Channels : int) return System.Address
     with Import, Convention => C,
          External_Name => "stbi_load_from_memory";

   --  Read header only — fast, no pixel allocation.
   function stbi_info
     (Filename : Chars_Ptr;
      X        : access int;
      Y        : access int;
      Comp     : access int) return int
     with Import, Convention => C, External_Name => "stbi_info";

   --  Free a pixel buffer returned by stbi_load*.
   procedure stbi_image_free (Pixels : System.Address)
     with Import, Convention => C, External_Name => "stbi_image_free";

   --  NUL-terminated C string of the last failure reason. NEVER
   --  free this — it's a pointer to STB's internal thread-local
   --  storage.
   function stbi_failure_reason return Chars_Ptr
     with Import, Convention => C,
          External_Name => "stbi_failure_reason";

   --  Flip Y on load. Pass nonzero to flip.
   procedure stbi_set_flip_vertically_on_load (Flag_True_If_Should_Flip : int)
     with Import, Convention => C,
          External_Name => "stbi_set_flip_vertically_on_load";

end Stb.Image.C;
