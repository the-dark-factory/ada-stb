--  Ada bindings to stb_image — image loading from disk + memory.
--
--  Supports PNG, JPG (baseline + progressive), BMP, GIF, PSD, PIC,
--  PNM, HDR, TGA. See vendor/stb/stb_image.h for full per-format
--  notes; the headlines are that the format is auto-detected from
--  the file contents (not the extension) and that the returned
--  buffer is always pixel-interleaved row-major top-to-bottom
--  (unless Set_Flip_Vertically_On_Load (True) has been called).
--
--  Memory ownership: Load_From_File / Load_From_Memory return an
--  Image record whose Pixels pointer is owned by STB's allocator
--  (malloc by default). Always pair Load with Free; the Image type
--  is not (yet) controlled, so the caller is responsible.
--
--    Img := Stb.Image.Load_From_File ("hello.png");
--    if Stb.Image.Loaded (Img) then
--       --  use Img.Width, Img.Height, Img.Channels, Img.Pixels
--       Stb.Image.Free (Img);
--    else
--       --  Stb.Image.Failure_Reason returns the last error
--    end if;

with Interfaces;
with System;

package Stb.Image is

   --  Channels in a loaded image. 1 = greyscale, 2 = greyscale+alpha,
   --  3 = RGB, 4 = RGBA. STB will convert on load if Desired_Channels
   --  is specified.
   subtype Channel_Count is Positive range 1 .. 4;

   --  Pixel data is just an opaque byte buffer; the caller knows the
   --  size from Width * Height * Channels. We expose it as an address
   --  rather than a typed array, because the actual layout (8-bit
   --  vs 16-bit, channel order) depends on the load function used,
   --  and forcing an Ada array shape adds friction the user often
   --  doesn't want.
   type Pixel_Address is new System.Address;
   Null_Pixels : constant Pixel_Address;

   --  A loaded image. Width / Height / Channels describe the
   --  pixel buffer at Pixels. The buffer was allocated by STB's
   --  allocator and MUST be released via Free.
   --
   --  Loaded? checks succeed iff Pixels /= Null_Pixels.
   type Image is record
      Width    : Natural       := 0;
      Height   : Natural       := 0;
      Channels : Natural       := 0;  --  0 = no image
      Pixels   : Pixel_Address := Null_Pixels;
   end record;

   --  Load an image from a filesystem path.
   --
   --  Desired_Channels: 0 means "give me whatever the file has".
   --  1..4 means "convert to N channels on load" — useful when your
   --  pipeline wants a uniform format. The loaded Image's Channels
   --  field reflects the OUTPUT channel count, which matches
   --  Desired_Channels when nonzero.
   --
   --  On failure returns an Image with Loaded? = False; check
   --  Failure_Reason for diagnostics.
   function Load_From_File
     (Path             : String;
      Desired_Channels : Natural := 0) return Image
     with Pre => Desired_Channels <= 4;

   --  Load an image from an in-memory buffer (e.g. an asset
   --  embedded in the executable, or a buffer downloaded from
   --  the network).
   function Load_From_Memory
     (Buffer           : System.Address;
      Length           : Natural;
      Desired_Channels : Natural := 0) return Image
     with Pre => Desired_Channels <= 4;

   --  Query an image's dimensions WITHOUT loading the pixel data.
   --  Useful for early validation or asset-pipeline planning.
   --
   --  Returns False on failure; Info_From_File never allocates.
   function Info_From_File
     (Path     : String;
      Width    : out Natural;
      Height   : out Natural;
      Channels : out Natural) return Boolean;

   --  True iff the image has a valid pixel buffer.
   function Loaded (Img : Image) return Boolean;

   --  Release the pixel buffer back to STB's allocator. Safe to
   --  call on an already-freed or never-loaded Image (no-op when
   --  Pixels is null). Clears the Width/Height/Channels too so the
   --  Image is unambiguously empty afterwards.
   procedure Free (Img : in out Image);

   --  The last error message STB recorded, in human-readable form
   --  (e.g. "couldn't open file", "unknown image type", "bad PNG").
   --  Returns the empty string if no failure has been recorded.
   function Failure_Reason return String;

   --  Configure STB to flip the loaded image vertically (Y-axis).
   --  Useful for OpenGL-style pipelines where (0,0) is bottom-left
   --  rather than top-left. Affects all subsequent Load_From_*
   --  calls on the current thread.
   procedure Set_Flip_Vertically_On_Load (Flip : Boolean);

private

   Null_Pixels : constant Pixel_Address :=
     Pixel_Address (System.Null_Address);

end Stb.Image;
