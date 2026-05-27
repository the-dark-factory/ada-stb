--  ada-stb smoke test — load tests/fixtures/tiny.png, verify
--  dimensions + channel count, free the buffer. Exits with status
--  0 on success, 1 on any check failure.
--
--  Run from the repo root so the relative path resolves:
--    ./examples/smoke/bin/smoke

with Ada.Command_Line;
with Ada.Text_IO;

with Stb.Image;

procedure Smoke is
   Path : constant String := "tests/fixtures/tiny.png";

   Img : Stb.Image.Image;

   procedure Fail (Why : String) is
   begin
      Ada.Text_IO.Put_Line ("FAIL: " & Why);
      Stb.Image.Free (Img);
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end Fail;

begin
   Ada.Text_IO.Put_Line ("ada-stb smoke test starting");
   Ada.Text_IO.Put_Line ("  loading " & Path);

   Img := Stb.Image.Load_From_File (Path);

   if not Stb.Image.Loaded (Img) then
      Fail ("Load_From_File returned an unloaded Image: "
            & Stb.Image.Failure_Reason);
      return;
   end if;

   --  The fixture is an 8x8 RGBA PNG. STB returns channels=4
   --  because the file has an alpha channel.
   if Img.Width /= 8 then
      Fail ("Width: expected 8, got" & Img.Width'Image);
      return;
   end if;
   if Img.Height /= 8 then
      Fail ("Height: expected 8, got" & Img.Height'Image);
      return;
   end if;
   if Img.Channels /= 4 then
      Fail ("Channels: expected 4 (RGBA), got" & Img.Channels'Image);
      return;
   end if;

   Ada.Text_IO.Put_Line
     ("  loaded:" & Img.Width'Image & " x"
      & Img.Height'Image & " x"
      & Img.Channels'Image & " channels");

   Stb.Image.Free (Img);

   if Stb.Image.Loaded (Img) then
      Fail ("Free did not clear the image");
      return;
   end if;

   Ada.Text_IO.Put_Line ("  free OK");
   Ada.Text_IO.Put_Line ("ada-stb smoke test passed");
end Smoke;
