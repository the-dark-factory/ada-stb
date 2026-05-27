with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings;

with Stb.Image.C;

package body Stb.Image is

   ------------------------
   --  Loaded
   ------------------------

   function Loaded (Img : Image) return Boolean is
      use type System.Address;
   begin
      return System.Address (Img.Pixels) /= System.Null_Address;
   end Loaded;

   ------------------------
   --  Free
   ------------------------

   procedure Free (Img : in out Image) is
      use type System.Address;
   begin
      if System.Address (Img.Pixels) /= System.Null_Address then
         Stb.Image.C.stbi_image_free (System.Address (Img.Pixels));
      end if;
      Img.Pixels   := Null_Pixels;
      Img.Width    := 0;
      Img.Height   := 0;
      Img.Channels := 0;
   end Free;

   ------------------------
   --  Failure_Reason
   ------------------------

   function Failure_Reason return String is
      use Interfaces.C.Strings;
      Reason : constant chars_ptr := Stb.Image.C.stbi_failure_reason;
   begin
      if Reason = Null_Ptr then
         return "";
      else
         return Value (Reason);
      end if;
   end Failure_Reason;

   ------------------------
   --  Set_Flip_Vertically_On_Load
   ------------------------

   procedure Set_Flip_Vertically_On_Load (Flip : Boolean) is
   begin
      Stb.Image.C.stbi_set_flip_vertically_on_load (if Flip then 1 else 0);
   end Set_Flip_Vertically_On_Load;

   ------------------------
   --  Load_From_File
   ------------------------

   function Load_From_File
     (Path             : String;
      Desired_Channels : Natural := 0) return Image
   is
      use Interfaces.C.Strings;
      use type System.Address;
      C_Path : chars_ptr := New_String (Path);
      X      : aliased int := 0;
      Y      : aliased int := 0;
      Ch     : aliased int := 0;
      Buf    : System.Address;
      Result : Image := (others => <>);
   begin
      Buf := Stb.Image.C.stbi_load
        (C_Path,
         X'Access, Y'Access, Ch'Access,
         int (Desired_Channels));
      Free (C_Path);
      if Buf = System.Null_Address then
         return Result;  --  Loaded? will return False
      end if;
      Result :=
        (Width    => Natural (X),
         Height   => Natural (Y),
         Channels =>
           (if Desired_Channels = 0 then Natural (Ch)
            else Desired_Channels),
         Pixels   => Pixel_Address (Buf));
      return Result;
   end Load_From_File;

   ------------------------
   --  Load_From_Memory
   ------------------------

   function Load_From_Memory
     (Buffer           : System.Address;
      Length           : Natural;
      Desired_Channels : Natural := 0) return Image
   is
      use type System.Address;
      X      : aliased int := 0;
      Y      : aliased int := 0;
      Ch     : aliased int := 0;
      Buf    : System.Address;
      Result : Image := (others => <>);
   begin
      Buf := Stb.Image.C.stbi_load_from_memory
        (Buffer, int (Length),
         X'Access, Y'Access, Ch'Access,
         int (Desired_Channels));
      if Buf = System.Null_Address then
         return Result;
      end if;
      Result :=
        (Width    => Natural (X),
         Height   => Natural (Y),
         Channels =>
           (if Desired_Channels = 0 then Natural (Ch)
            else Desired_Channels),
         Pixels   => Pixel_Address (Buf));
      return Result;
   end Load_From_Memory;

   ------------------------
   --  Info_From_File
   ------------------------

   function Info_From_File
     (Path     : String;
      Width    : out Natural;
      Height   : out Natural;
      Channels : out Natural) return Boolean
   is
      use Interfaces.C.Strings;
      C_Path : chars_ptr := New_String (Path);
      X, Y, C_Comp : aliased int := 0;
      OK     : int;
   begin
      Width := 0; Height := 0; Channels := 0;
      OK := Stb.Image.C.stbi_info
        (C_Path, X'Access, Y'Access, C_Comp'Access);
      Free (C_Path);
      if OK = 0 then
         return False;
      end if;
      Width    := Natural (X);
      Height   := Natural (Y);
      Channels := Natural (C_Comp);
      return True;
   end Info_From_File;

end Stb.Image;
