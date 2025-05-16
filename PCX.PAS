{$A+,B-,E+,F-,G+,N+,R-,S-}
unit pcx;

interface

TYPE
PaletteType = record
   RedLevel:   Array[0..255] of byte;
   GreenLevel: Array[0..255] of byte;
   BlueLevel:  Array[0..255] of byte;
end;

type Pcxheader_rec=record               { EXPECTED VALUES / COMMENTS}
                                        { --------------------------}
     manufacturer: byte;                { 10. (Why does Z-Soft have
                                          this field ?) }
     version: byte;                     { 5. }
     encoding: byte;                    { 0.  (RLE PCX encryption) }
     bits_per_pixel: byte;              { 8.  (8 bits = 256 colours) }
     xmin, ymin: word;                  { 0,0 (Top Left) }
     xmax, ymax: word;                  { 319,199 (Bottom right) }
     hres: word;                        { 320 (although this (and vres)
                                          may be ignored by some
                                          programs)}
     vres: word;                        { 200 }
     palette: array [0..47] of byte;    { Don't use }
     reserved: byte;                    { Don't use }
     colour_planes: byte;               { 0 (Mode 13h is not planar) }
     bytes_per_line: word;              { 320 (usually, may differ -
                                          although I hear this should
                                          be an even number my PCX load
                                          /save routines work with odd
                                          numbers too) }
     palette_type: word;                { 12 (to work with this unit) }
     filler: string[58];                { Don't know the purpose of this,
                                          could it be for comments etc ? }
end;

var header: Pcxheader_rec;
    Palette: PaletteType;
    Error: string;

Procedure GetAllPalette(Var Palette : PaletteType);
Procedure SetAllPalette(Palette : PaletteType);
Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Procedure SavePalette(FileName: String; Palette : PaletteType);
Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
          x,y, PCXWidth,PCXHeight: word);
Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
          x,y,widthtoshow,heighttoshow:word);



implementation

Procedure GetPtrData(pt:pointer; VAR Segm, Offs:word); Assembler;
Asm
   LES DI,PT            { Point ES:DI to where PT is in memory }
   MOV AX,ES            { Set AX to hold segment }
   MOV BX,DI            { BX to hold offset }

   LES DI,Segm          { Now write directly to variable Segm }
   MOV [ES:DI],AX
   LES DI,Offs          { And variable Offs }
   MOV [ES:DI],BX
End;


Procedure CalculateOffset; Near; Assembler;
Asm
     CMP AX,319         { Is X> 319 ? }
     JA @OutOfBounds    { Yes }
     CMP BX,199         { Is Y> 199 ?. Do not use BL instead as this is
                          when problems will occur.}
     JA @OutOfBounds    { Yes }

     XOR CH,CH                  { CX = Y }
     MOV CL,BL
     SHL CX,6                   
     MOV BH,BL                  { BX = Y * 256 }
     XOR BL,BL
     ADD BX,CX                  { BX = BX + CX, which gives Y * 320 }
     ADD BX,AX                  { Add the X position to offset in BX }
     ADD BX,0    { Take into account the offset in memory
                                  of the source Bitmap }

     JMP @Finito                { And exit. }

@OutOfBounds:
     MOV BX,-1                  { Signal that coordinates were not within
                                  the screen limits }

@Finito:
End;


Procedure GetPalette(ColourNumber : Byte;
          VAR RedValue, GreenValue, BlueValue : Byte); Assembler;
Asm
   MOV DX,$3C7          { $3C7 is colour ** READ ** select port. }
   MOV AL,ColourNumber   { Select colour to read }
   OUT DX,AL
   ADD DL,2             { DX now = $3C9, which must be read 3 times
                          in order to obtain the Red, Green and
                          Blue values of a colour }

   IN AL,DX             { Read red amount. Don't use IN AX,DX as
                          for some strange reason it doesn't work ! }
   LES DI,RedValue
   MOV [ES:DI],AL       { Techie saddos note : STOSB is approx 4 cycles
                          slower and requires double cache multiplex,
                          which basically means "who gives a shit ?". :-)
                        }

   IN AL,DX
   LES DI,GreenValue
   MOV [ES:DI],AL

   IN AL,DX             { Read blue }
   LES DI,BlueValue
   MOV [ES:DI],AL
End;

Procedure SetAllPalette(Palette : PaletteType); Assembler;
Asm
   PUSH DS
   LDS BX, Palette      { DS:BX points to Palette record }
   XOR AL,AL
   MOV DX,$3c8          { $3c8 selects the first colour to alter.
                          After 3 writes to $3c9, the VGA automatically
                          moves to the next Colour so there is no
                          need to write to $3c8 again. }
   OUT DX,AL
   INC DL               { Make DX = $3c9, which is used to set the
                          Red / Green and Blue values of a Colour }

   MOV CL,(255) { 256 colours }

   MOV SI,BX
   ADD SI,255     { Make SI point to green levels }
   MOV DI,BX
   ADD DI,255     { Make DI point to blue levels }
   ADD DI,255

{
Note: I read somewhere that some VGA adapters don't like
      being hit with continuous data too quickly..

      If not then you should use the BIOS load palette
      function (which will be 20 times slower than this
      hack trick)
}

@WritePaletteInfo:
   MOV AL, [BX]         { Read red level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [SI]         { Read green level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [DI]         { Read blue level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }

   INC DI               { Next Red part of record }
   INC BX               { Next Green }
   INC SI               { Next Blue }

   DEC CL
   CMP CL,$FF               { Dunno if a JNZ works when register is 0
                            or $ff. }
   JNZ @WritePaletteInfo
   POP DS
End;



Procedure GetAllPalette(Var Palette : PaletteType);
Var ColourCount:byte;
Begin
     For ColourCount:=0 to 255 do
     GetPalette(ColourCount,Palette.RedLevel[ColourCount],
     Palette.GreenLevel[ColourCount],Palette.BlueLevel[ColourCount]);
End;

Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     Reset(PaletteFile,1);
     BlockRead(PaletteFile,Palette,SizeOf(Palette));
     Close(PaletteFile);
End;

Procedure SavePalette(FileName: String; Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     Rewrite(PaletteFile,1);
     BlockWrite(PaletteFile,Palette,SizeOf(Palette));
     Close(PaletteFile);
End;


Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
          x,y, PCXWidth,PCXHeight: word);

Var f: File;                    { File for writing PCX to }
    ColourMapID: byte;           { Always holds 12, for the PCX }
    ColourCount: byte;           { Counts up to number of colours on
                                  screen (255) }
    RedValue: byte;             { Palette Values of a colour }
    GreenValue: byte;
    BlueValue: byte;

    LastOffset: word;           { Used as a latch for VidOffset }
    VidOffset: word;            { Offset into Source Bitmap }
    VerticalCount: byte;        { Number of scan lines to use }
    LastByte : byte;            { The last byte read from Source Bitmap }
    NewByte: byte;              { The current byte }
    RunLength : byte;           { Counter for run length compression }
    ByteCount: word;            { Counts up to bytes per scan line (320) }

Begin
     Assign(f,filename);
     Rewrite(f,1);

     With header do
     Begin
          Manufacturer := 10;
          Version := 5;
          Encoding :=0;
          Bits_per_pixel:=8;    { 8 bits = 256 colours }
          XMin:=0;
          YMin:=0;

          {
          Can't save a PCX more than 320 x 200 in size.
          }

          if (PCXwidth + x) > 320 Then
             PCXwidth:=320-x;
          if (PCXheight+ y) > 200 Then
             PCXheight:=200-y;

          XMax:=(PCXWidth-1);
          YMax:=(PCXHeight-1);
          Hres:=320;                        { Hres/Vres could be used to
                                              determine screen mode -
                                              probably :-( }
          VRes:=200;

          Colour_planes:=1;                 { Mode 13h is not planar }
          Bytes_per_line:=PCXWidth;         { One byte per pixel }
          Palette_type:=12;                 { Dunno what 12 is for }
     End;

     BlockWrite(F,Header,SizeOf(Header));

     Asm
     MOV AX,X
     MOV BX,Y
     CALL CalculateOffset
     MOV VidOffset,BX
     End;

     For VerticalCount:=0 to PCXHeight-1 do
     Begin
          LastOffset:=VidOffset;
          ByteCount:=0;
          LastByte:=0;

          Repeat
                NewByte:=Mem[$A000:Vidoffset];

                {
                If the last byte read is equal to the new byte read
                then a run of bytes has been identified and so the
                system needs to count how many identical bytes (up
                to a total of 63) follow. When finished, the
                system writes this count to disk PLUS a value of
                192 (which is the signal to the PCX reader that
                a run of bytes follows) then writes the byte that
                was prevalent in the run.

                For example, say in the data stream there were 10
                values :

                0 1 2 6 9 8 7 7 7 4

                When the system gets to 8 it would then compare
                that number with the next value (7) and see that 8 is
                not equal to 7, then the computer would move to said 7
                (after the 8) and compare it to the next digit, which
                is also a 7.

                As a match has been found, the system counts the
                number of 7s there, which is (all together now !)
                3!! and then adds 192 to the result.. to give 195.

                As stated before, bits 6 + 7 of the byte have
                been set in order to "flag" to the PCX reader that
                a run of bytes have been found.

                The value 195 is written to disk, then value 7 so the
                PCX reader that loads this file knows what value (and
                how many times) to write to the screen during unpacking.

                I hope this has explained one of the PCX mysteries. If
                it hasn't I typed all that for nothing!! :-)
                }

                If NewByte = LastByte Then
                   Begin

                   RunLength:=0;
                   While (NewByte = LastByte) and (RunLength < 63)
                      and (ByteCount <> PCXWidth) do
                      Begin
                      Inc(RunLength);
                      Inc(ByteCount);

                      {
                      Move to next byte on Source Bitmap
                      }

                      Inc(vidoffset);

                      NewByte:=Mem[$A000:Vidoffset];
                   End;


                   Asm
                   OR Byte Ptr RunLength, 192
                   End;

                   BlockWrite(f,RunLength,1);
                   BlockWrite(f,LastByte,1);

                   LastByte:=NewByte;
                   End
                Else

                { How to deal with colours > 191. }
                    If (NewByte > 191) Then
                       Begin
                       Inc(ByteCount);
                       Inc(VidOffset);                { Point to next byte on screen }
                       RunLength:=193;
                       BlockWrite(f,RunLength,1);     { Write run length byte of 1  ! }
                       BlockWrite(f,NewByte,1);       { The ONLY way to get round }
                       LastByte:=NewByte;
                       End
                    Else
                        Begin
                        Inc(ByteCount);
                        Inc(vidoffset);
                        BlockWrite(f,NewByte,1);
                        LastByte:=NewByte;
                        End;

          Until ByteCount = PCXWidth;

          VidOffset:=LastOffset+320;
     End;

     {
     12 is Colourmap ID.
     }

     ColourMapID:=12;
     BlockWrite(f,ColourMapID,1);

     {
     Now write Palette R,G,B values to disk. The only reason
     I didn't implement :

     BlockWrite(F,Palette,SizeOf(Palette))

     was that all the palette entries had to be shifted LEFT
     twice (To represent a 16.7 million colour palette..) 
     
                                DAMN!
     }

     For ColourCount:=0 to 255 do
         Begin

         RedValue:=ThePalette.   RedLevel[ColourCount] SHL 2;
         GreenValue:=ThePalette. GreenLevel[ColourCount] SHL 2;
         BlueValue:=ThePalette.  BlueLevel[ColourCount] SHL 2;

         BlockWrite(F,RedValue,1);
         BlockWrite(F,GreenValue,1);
         BlockWrite(F,BlueValue,1);
     End;

     Close(F);         { That's it - it's not over, not over yet .. :-) }
End;

Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
          x,y,widthtoshow,heighttoshow:word);

var PCXFile: file;

    ReadingFromMem  : Boolean;      { If True it means All/Some PCX
                                      Data is in RAM }
    MemRequired     : longint;      { Size of PCX bitmap data }
    BytesRead       : longint;      { Number of PCX bytes read }
    PCXFileSize     : longint;      { How many bytes PCX uses }
    Count           : integer;      { I is a general counter used to set
                                      the PCX's palette and then count
                                      scan lines }
    RedVal          : byte;         { Used for ColourMap, Palette values }
    GreenVal        : byte;         { which define a colour }
    BlueVal         : byte;

    MemoryAccessVar : pointer;      { Pointer to read bitmap data }
    BufferSeg,                      { Where PCX will be loaded to }
    BufferOffset    : word;

    VidOffset       : word;         { Screen offset }

    Width,Height,                   { Width is number of horizontal bytes to grab
                                      Height is number of vertical bytes to grab }
    N,Bytes             : word;     { N counts up to Bytes }
    RunLength,c     : byte;         { RunLength is the Run Length Encoding
                                      byte, C is the character read from
                                      PCX data }
    PastHorizontalLimit : boolean;  { Set true this means no more
                                     horizontal pixel writes to do, advance 
                                     to next line as soon as poss.}

begin
    assign(PCXFile,FileName);

{$i-}
    reset (PCXFile,1);
{$i+}
    If IOResult = 0 Then
       Begin

       blockread (PCXFile, header, sizeof (header));       { Read in PCX header }

       if (header.manufacturer=10) and (header.version=5) and
          (header.bits_per_pixel=8) and (header.colour_planes=1) then
          begin
               seek (PCXFile, filesize (PCXFile)-769);     { Move to palette data }
               blockread (PCXFile, c, 1);                  { Read Colourmap type }
               if (c=12) then                              { 12 is correct type }
               begin
                    {
                    Read palette data and write to palette
                    structure.
                    }

                    for Count:=0 to 255 do
                        Begin
                          BlockRead(PCXFile,RedVal,1);
                          BlockRead(PCXFile,GreenVal,1);
                          BlockRead(PCXFile,BlueVal,1);

                          ThePalette.RedLevel[Count]:=RedVal SHR 2;
                          ThePalette.GreenLevel[Count]:=GreenVal SHR 2;
                          ThePalette.BlueLevel[Count]:=BlueVal SHR 2;
                      End;


                  seek (PCXFile, 128);

                  {
                  If entire size of PCX is less than 64K in length then
                  it can be stored in a memory buffer and uncompacted
                  from there. However, if PCX exceeds 64K then it must
                  be split into several chunks. If your machine does
                  not have 64K left for the buffer used (You're in trouble !!)
                  then the system will read the PCX from disk continually,
                  which works OK but is very slow. So there.
                  }

                  MemRequired:=Filesize(PCXFile)-897;
                  PCXFileSize:=MemRequired;
                  BytesRead:=0;

                  If (MemRequired < 65528) And (MaxAvail > MemRequired) Then
                     Begin
                     getmem(MemoryAccessVar,MemRequired);
                     GetPtrData(MemoryAccessVar, BufferSeg, BufferOffset);
                     BlockRead(PCXFile,Mem[BufferSeg:BufferOffset],MemRequired);
                     ReadingFromMem:=True;
                     End
                  Else

                  {
                  If the PCX occupies more than approx. 64K bytes then it
                  is necessary to read the data into memory in 64K chunks
                  which is still considerably faster than the
                  final method (continual reading from disk)
                  }

                      If (MaxAvail > 65527) Then
                         Begin
                         GetMem(MemoryAccessVar,65528);
                         GetPtrData(MemoryAccessVar, BufferSeg, BufferOffset);
                         BlockRead(PCXFile,Mem[BufferSeg:BufferOffset],65528);
                         BytesRead:=65528;
                         MemRequired:=65528;
                         ReadingFromMem:=True;
                         End
                      Else
                          { CLUCK!! Oh well, system is just going to have
                          to read from disk as there is not even 64K
                          memory left. (A very bad situation) }

                          ReadingFromMem:=False;

                  {
                  Find out width & height of PCX.
                  }

                  width:=(header.xmax - header.xmin)+1;
                  height:=(header.ymax - header.ymin)+1;
                  bytes:=header.bytes_per_line;

                  {
                  Adjust width & height of PCX if necessary so that PCX
                  "fits" on screen.

                  }

                  if widthtoshow > width Then
                     widthtoshow:=width;

                  if (widthtoshow + x) > 320 Then
                     widthtoshow:=width-x;

                  if heighttoshow > height Then
                     heighttoshow:=height;

                  if (heighttoshow + y)> 200 Then
                     heighttoshow:=height-y;


                  {
                  Do all scan lines.
                  }

                  for Count:=0 to (heighttoshow-1) do
                  begin
                      n:=0;
                      PastHorizontalLimit:=False;
                      vidoffset:= ((Y+Count)* 320)+X;

                      while (n<bytes) do
                      begin

                           { Display any more pixels width wise from PCX ? }

                           If N >= WidthToShow Then
                              PastHorizontalLimit:=True;

                           If ReadingFromMem Then
                               Begin
                               c:=Mem[BufferSeg:BufferOffset];
                               Inc(BufferOffset);
                               If BufferOffset = 65528 Then
                                  Begin
                                  { End of buffer has been reached, so
                                    it's time to load another part of the
                                    PCX }

                                  If (PCXFileSize - BytesRead)> 65527 Then
                                     Begin
                                     BlockRead(PCXFile,Mem[BufferSeg:0],65528);
                                     Inc(BytesRead,65528);
                                     End
                                  Else
                                      { Load last chunk of PCX }

                                      Begin
                                      BlockRead(PCXFile,Mem[BufferSeg:0],
                                      (PCXFileSize - BytesRead));
                                      End;

                                  {
                                  Now reset buffer pointer to start
                                  }

                                  BufferOffset:=0;
                                  End;
                               End
                            Else
                                BlockRead(PCXFile,c,1);

{
At this point one element of data has been read, and stored in
variable C. If bits 6 & 7 of C are set then this means to the system
a "run of bytes" has been found. (i.e. a number sequence - for example,
four 1's, twenty 15's, any sequence of identical numbers).

In this case, the 6 least significant bits of C indicate how long the run
of bytes is. For example, if a sequence of five bytes has been found
the run = 5. Of course, using 6 bits limits you to a maximum run length
of 63 bytes but that should be more than enough for most pictures.

Quite a simple method of compaction eh? Definitely the easiest format to
understand!

}

                            if ((c and 192)=192) then
                            begin

                               { Get the 6 least significant bits }
                               RunLength:=c and 63;

                               { get the run byte }

                               If ReadingFromMem Then
                                  Begin
                                  c:=Mem[BufferSeg:BufferOffset];
                                  Inc(BufferOffset);

                               { Time to read in more data from disk ? }

                                  If BufferOffset = 65528 Then
                                     Begin
                                     If (PCXFileSize - BytesRead)> 65527 Then
                                        Begin
                                        BlockRead(PCXFile,Mem[BufferSeg:0],65528);
                                        Inc(BytesRead,65528);
                                        End
                                     Else
                                         Begin
                                         BlockRead(PCXFile,Mem[BufferSeg:0],
                                         (PCXFileSize - BytesRead));
                                     End;

                                     BufferOffset:=0;
                                     End;
                                  End
                               Else
                                   BlockRead(PCXFile,c,1);

                               {
                               Can't do blit if past the horizontal limit
                               of the window.
                               }

                               If Not PastHorizontalLimit Then
                                  Begin
                                  If n+RunLength > widthtoshow Then
                                     fillchar(Mem[$A000:VidOffset],WidthToShow-n,c)
                                  else
                                      fillchar(Mem[$A000:VidOffset],RunLength,c);

                                  inc(vidoffset,RunLength);
                               End;

                               inc(n,RunLength);
                               end
                            else
                                begin
                                If Not PastHorizontalLimit Then
                                   Begin
                                   mem [$A000:vidoffset]:=c;
                                   inc (vidoffset);
                                End;
                                inc (n);
                            end;

                      end;

                  end;

                  If ReadingFromMem Then
                     freemem(MemoryAccessVar,MemRequired);
               end
          else
              Begin
              Error:='The PCX''s ColourMap is not of the correct type !';
              Close(PCXFile);
              End;
          end
       Else
           Begin
           Error:='PCX unsuitable for loading.';
           Close(PCXFile);
       End;

       end
    Else
        Begin
          Error:='File not found ?';
        End;

end;

end.