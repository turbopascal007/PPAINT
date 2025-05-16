{ by Zef Hemel: zef@zefnet.com http://zefnet.com }

unit vga;

INTERFACE

TYPE Virtual = Array [1..64000] of byte;
     VirtPtr = ^Virtual;                  
     charArray = Array [0..4,0..4] of Word;
     FontFile = file of CharArray;
     ImageType = record
                   deltaX,deltaY:longint;
		   vSegment,vOffset:word;
		   Image:pointer;
		 end;

CONST visualscr      = $A000;
      ShRectBig      = 6;
      ShRectNormal   = 5;
      ShRectSmall    = 4;
      ShRoundBig     = 3;
      ShRoundNormal  = 2;
      ShRoundSmall   = 1;
      ShOnepoint     = 0;
      XorV           = $F;
      Size   : byte  = 80;

VAR Virscr : VirtPtr;                     { Our first Virtual screen }
    virtualscr: word;                        { The segment of our virtual screen}
    Scr_Ofs : Array[0..199] of Word;
    Currentshape: integer;
    I1,I2,I3,I4,I5,I6,I7,I8,I9,I0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,point,comma,
      AC,UT,VT,AP,VO,VS,DP,PK:CharArray;

procedure Setvga;                            {Sets the screen to graphic VGA}
procedure Resetvga;                          {Resets the screen to text}
procedure putpixel(x,y:integer; color:byte;dest:Word);{Draws a pixel on x, y with color}
procedure putbrush(x,y:integer; color:byte;dest:Word);{Draws a pixel on x, y with color}
function  getpixel (x,y:integer;source:Word):byte;
procedure SetColor(col,r,g,b:byte);
procedure fadeout (txt: string; speed:integer);
procedure Line(a,b,c,d:integer;col:byte;dest:Word);
procedure Rectangle(x1,y1,x2,y2:integer;col:byte;dest:Word);
procedure FRectangle( X1,Y1,X2,Y2 :WORD; Color :BYTE;dest:word);
procedure Cls (Col : Byte;dest:Word);
procedure WriteXY (cx,cy:Word; Col:Byte; txt:string;dest:word);
Procedure SetVirtual;
Procedure ResetVirtual;
procedure CopyScr(source,dest:Word);
procedure LoadFont(filename:String);
procedure XorLine(X1, Y1, X2, Y2 : integer;dest:word);
procedure XorRectangle(x1,y1,x2,y2:integer;dest:Word);
PROCEDURE XorEllipse(exc, eyc, ea, eb : Integer; dest: word);
PROCEDURE Ellipse(exc, eyc, ea, eb : Integer; Color: byte; dest: word);
PROCEDURE FEllipse(exc, eyc, ea, eb : Integer; Color: byte; dest: word);
procedure Button (x, y: integer; t: string; dest: word);
procedure ButtonDown (x, y: integer; t: string; dest: word);
procedure show_palet;
PROCEDURE FloodFill(StartX, StartY : INTEGER; Color : BYTE);
{ Image procedures }
procedure GetImage(var Image:ImageType;x1,y1,x2,y2:word;dest:word);
procedure PutImage(Image:ImageType;x1,y1:word;dest:word);
procedure KillImage(var Image:ImageType);
{ Screen procedures }
procedure MoveD(SourceSeg, SourceOfs, DestSeg, DestOfs, AnzBytes: Word);
procedure ScrollUp(x1, y1, x2, y2, numlines, SegAdr: word);
procedure ScrollDn(x1, y1, x2, y2, numlines, SegAdr: word);
{ Normal txt functions }
procedure WriteText(Xpos,Ypos : word; Color : byte; ScrTxt : string; Dest: word);

IMPLEMENTATION

uses crt,dos;

procedure SetVga;
begin
  asm
    mov ax, 13h
    int 10h
  end;
end;

procedure ResetVga;
begin
  asm
    mov ax, 03h
    int 10h
  end;
end;

Procedure PutBrush (X,Y : Integer; Color: Byte; dest:word);
BEGIN
  case currentshape of
    0: begin
         mem[dest:y*320+x]:=Color;
       end;
    1: begin
                                     mem[dest:(y-1)*320+x]:=Color;
         mem[dest:y*320+x-1]:=Color; mem[dest:y*320+x]:=Color;     mem[dest:y*320+x+1]:=Color;
                                     mem[dest:(y+1)*320+x]:=Color;
       end;
    2: begin
         mem[dest:(y-2)*320+x-1]:=Color;
         mem[dest:(y-2)*320+x]:=Color;
         mem[dest:(y-2)*320+x+1]:=Color;

         mem[dest:(y-1)*320+x-2]:=Color;
         mem[dest:(y-1)*320+x-1]:=Color;
         mem[dest:(y-1)*320+x]:=Color;
         mem[dest:(y-1)*320+x+1]:=Color;
         mem[dest:(y-1)*320+x+2]:=Color;

         mem[dest:(y-0)*320+x-2]:=Color;
         mem[dest:(y-0)*320+x-1]:=Color;
         mem[dest:(y-0)*320+x]:=Color;
         mem[dest:(y-0)*320+x+1]:=Color;
         mem[dest:(y-0)*320+x+2]:=Color;

         mem[dest:(y+1)*320+x-2]:=Color;
         mem[dest:(y+1)*320+x-1]:=Color;
         mem[dest:(y+1)*320+x]:=Color;
         mem[dest:(y+1)*320+x+1]:=Color;
         mem[dest:(y+1)*320+x+2]:=Color;

         mem[dest:(y+2)*320+x-1]:=Color;
         mem[dest:(y+2)*320+x]:=Color;
         mem[dest:(y+2)*320+x+1]:=Color;
       end;
    3: begin
         mem[dest:(y-3)*320+x-1]:=Color;
         mem[dest:(y-3)*320+x+0]:=Color;
         mem[dest:(y-3)*320+x+1]:=Color;

         mem[dest:(y-2)*320+x-2]:=Color;
         mem[dest:(y-2)*320+x-1]:=Color;
         mem[dest:(y-2)*320+x+0]:=Color;
         mem[dest:(y-2)*320+x+1]:=Color;
         mem[dest:(y-2)*320+x+2]:=Color;

         mem[dest:(y-1)*320+x-3]:=Color;
         mem[dest:(y-1)*320+x-2]:=Color;
         mem[dest:(y-1)*320+x-1]:=Color;
         mem[dest:(y-1)*320+x+0]:=Color;
         mem[dest:(y-1)*320+x+1]:=Color;
         mem[dest:(y-1)*320+x+2]:=Color;
         mem[dest:(y-1)*320+x+3]:=Color;

         mem[dest:(y-0)*320+x-3]:=Color;
         mem[dest:(y-0)*320+x-2]:=Color;
         mem[dest:(y-0)*320+x-1]:=Color;
         mem[dest:(y-0)*320+x+0]:=Color;
         mem[dest:(y-0)*320+x+1]:=Color;
         mem[dest:(y-0)*320+x+2]:=Color;
         mem[dest:(y-0)*320+x+3]:=Color;

         mem[dest:(y+1)*320+x-3]:=Color;
         mem[dest:(y+1)*320+x-2]:=Color;
         mem[dest:(y+1)*320+x-1]:=Color;
         mem[dest:(y+1)*320+x+0]:=Color;
         mem[dest:(y+1)*320+x+1]:=Color;
         mem[dest:(y+1)*320+x+2]:=Color;
         mem[dest:(y+1)*320+x+3]:=Color;

         mem[dest:(y+2)*320+x-2]:=Color;
         mem[dest:(y+2)*320+x-1]:=Color;
         mem[dest:(y+2)*320+x+0]:=Color;
         mem[dest:(y+2)*320+x+1]:=Color;
         mem[dest:(y+2)*320+x+2]:=Color;

         mem[dest:(y+3)*320+x-1]:=Color;
         mem[dest:(y+3)*320+x+0]:=Color;
         mem[dest:(y+3)*320+x+1]:=Color;
       end;
    4: begin
         mem[dest:(y-1)*320+x-1]:=Color; mem[dest:(y-1)*320+x]:=Color; mem[dest:(y-1)*320+x+1]:=Color;
         mem[dest:y*320+x-1]:=Color; mem[dest:y*320+x]:=Color;     mem[dest:y*320+x+1]:=Color;
         mem[dest:(y+1)*320+x-1]:=Color; mem[dest:(y+1)*320+x]:=Color; mem[dest:(y+1)*320+x+1]:=Color;
       end;
    5: begin
         mem[dest:(y-2)*320+x-2]:=Color;
         mem[dest:(y-2)*320+x-1]:=Color;
         mem[dest:(y-2)*320+x]:=Color;
         mem[dest:(y-2)*320+x+1]:=Color;
         mem[dest:(y-2)*320+x+2]:=Color;

         mem[dest:(y-1)*320+x-2]:=Color;
         mem[dest:(y-1)*320+x-1]:=Color;
         mem[dest:(y-1)*320+x]:=Color;
         mem[dest:(y-1)*320+x+1]:=Color;
         mem[dest:(y-1)*320+x+2]:=Color;

         mem[dest:(y-0)*320+x-2]:=Color;
         mem[dest:(y-0)*320+x-1]:=Color;
         mem[dest:(y-0)*320+x]:=Color;
         mem[dest:(y-0)*320+x+1]:=Color;
         mem[dest:(y-0)*320+x+2]:=Color;

         mem[dest:(y+1)*320+x-2]:=Color;
         mem[dest:(y+1)*320+x-1]:=Color;
         mem[dest:(y+1)*320+x]:=Color;
         mem[dest:(y+1)*320+x+1]:=Color;
         mem[dest:(y+1)*320+x+2]:=Color;

         mem[dest:(y+2)*320+x-2]:=Color;
         mem[dest:(y+2)*320+x-1]:=Color;
         mem[dest:(y+2)*320+x]:=Color;
         mem[dest:(y+2)*320+x+1]:=Color;
         mem[dest:(y+2)*320+x+2]:=Color;
       end;
    6: begin
         mem[dest:(y-3)*320+x-3]:=Color;
         mem[dest:(y-3)*320+x-2]:=Color;
         mem[dest:(y-3)*320+x-1]:=Color;
         mem[dest:(y-3)*320+x+0]:=Color;
         mem[dest:(y-3)*320+x+1]:=Color;
         mem[dest:(y-3)*320+x+2]:=Color;
         mem[dest:(y-3)*320+x+3]:=Color;

         mem[dest:(y-2)*320+x-3]:=Color;
         mem[dest:(y-2)*320+x-2]:=Color;
         mem[dest:(y-2)*320+x-1]:=Color;
         mem[dest:(y-2)*320+x+0]:=Color;
         mem[dest:(y-2)*320+x+1]:=Color;
         mem[dest:(y-2)*320+x+2]:=Color;
         mem[dest:(y-2)*320+x+3]:=Color;

         mem[dest:(y-1)*320+x-3]:=Color;
         mem[dest:(y-1)*320+x-2]:=Color;
         mem[dest:(y-1)*320+x-1]:=Color;
         mem[dest:(y-1)*320+x+0]:=Color;
         mem[dest:(y-1)*320+x+1]:=Color;
         mem[dest:(y-1)*320+x+2]:=Color;
         mem[dest:(y-1)*320+x+3]:=Color;

         mem[dest:(y-0)*320+x-3]:=Color;
         mem[dest:(y-0)*320+x-2]:=Color;
         mem[dest:(y-0)*320+x-1]:=Color;
         mem[dest:(y-0)*320+x+0]:=Color;
         mem[dest:(y-0)*320+x+1]:=Color;
         mem[dest:(y-0)*320+x+2]:=Color;
         mem[dest:(y-0)*320+x+3]:=Color;

         mem[dest:(y+1)*320+x-3]:=Color;
         mem[dest:(y+1)*320+x-2]:=Color;
         mem[dest:(y+1)*320+x-1]:=Color;
         mem[dest:(y+1)*320+x+0]:=Color;
         mem[dest:(y+1)*320+x+1]:=Color;
         mem[dest:(y+1)*320+x+2]:=Color;
         mem[dest:(y+1)*320+x+3]:=Color;

         mem[dest:(y+2)*320+x-3]:=Color;
         mem[dest:(y+2)*320+x-2]:=Color;
         mem[dest:(y+2)*320+x-1]:=Color;
         mem[dest:(y+2)*320+x+0]:=Color;
         mem[dest:(y+2)*320+x+1]:=Color;
         mem[dest:(y+2)*320+x+2]:=Color;
         mem[dest:(y+2)*320+x+3]:=Color;

         mem[dest:(y+3)*320+x-3]:=Color;
         mem[dest:(y+3)*320+x-2]:=Color;
         mem[dest:(y+3)*320+x-1]:=Color;
         mem[dest:(y+3)*320+x+0]:=Color;
         mem[dest:(y+3)*320+x+1]:=Color;
         mem[dest:(y+3)*320+x+2]:=Color;
         mem[dest:(y+3)*320+x+3]:=Color;
       end;
  end;
END;

procedure PutPixel(x,y:integer; color:byte;dest:Word); assembler;
asm
  mov   ax, [dest]
  mov   es, ax
  mov   ax, [y]
  mov   bx, 320
  mul   bx
  add   ax, [x]
  mov   di, ax
  mov   al, [color]
  cld
  stosb
end;

function GetPixel (x,y:integer;source:Word):byte;
begin
  GetPixel:=mem[source:y*320+x];
end;

procedure SetColor(col,r,g,b:byte);

begin
  port[$3c8]:=col;
  port[$3c9]:=r;
  port[$3c9]:=g;
  port[$3c9]:=b;
end;

procedure fadeout (txt: string; speed:integer); {1=slow 10=fast}
var b: byte;
    I: Integer;
begin
  b:=60;
  Textcolor(1);
  Write (txt);
  repeat
    Setcolor(1,0,0,b);
    Delay (50);
    b:=b-speed;
  until b<=0;
  SetColor(1,0,0,40);
end;

Procedure Line(a,b,c,d:integer;col:byte;dest:word);
  { This draws a solid line from a,b to c,d in colour col }
  function sgn(a:real):integer;
  begin
       if a>0 then sgn:=+1;
       if a<0 then sgn:=-1;
       if a=0 then sgn:=0;
  end;
var i,s,d1x,d1y,d2x,d2y,u,v,m,n:integer;
begin
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := m shr 1;
     FOR i := 0 TO m DO
     BEGIN
          putbrush(a,b,col,dest);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a + d1x;
               b := b + d1y;
          END
          ELSE
          BEGIN
               a := a + d2x;
               b := b + d2y;
          END;
     end;
END;

procedure Rectangle(x1,y1,x2,y2:integer;col:byte;dest:Word);
begin
  Line(x1,y1,x2,y1,col,dest);
  Line(x1,y2,x2,y2,col,dest);
  Line(x1,y1,x1,y2,col,dest);
  Line(x2,y1,x2,y2,col,dest);
end;

procedure FRectangle( X1,Y1,X2,Y2 :WORD; Color :BYTE;dest:word);
var Row :WORD;

begin
  for Row := Y1 TO Y2 DO FillChar(MEM[dest:(320*Row)+X1],X2-X1+1,Color);
end;

procedure Button (x, y: integer; t: string; dest: word);
var x1,x2,y1,y2 : integer;
    Oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  x1:=x; y1:=y;
  x2:=x+(length(t)*7)+1;
  y2:=y+10;
  FRectangle(x1,y1,x2,y2,Lightgray, dest);
  Line(x1,y1,x2,y1,white,dest);
  Line(x1,y1,x1,y2,white,dest);
  Line(x2,y1,x2,y2,darkgray,dest);
  Line(x1,y2,x2,y2,darkgray,dest);
  WriteXY(x1-5, y1+2, black, t, dest);
  currentshape:=oldsh;
end;

procedure ButtonDown (x, y: integer; t: string; dest: word);
var x1,x2,y1,y2 : integer;
begin
  x1:=x; y1:=y;
  x2:=x+(length(t)*7)+1;
  y2:=y+10;
  FRectangle(x1,y1,x2,y2,Darkgray, dest);
  Line(x1,y1,x2,y1,black,dest);
  Line(x1,y1,x1,y2,black,dest);
  Line(x2,y1,x2,y2,lightgray,dest);
  Line(x1,y2,x2,y2,lightgray,dest);
  WriteXY(x1-5, y1+2, black, t, dest);
  Delay(250);
end;

procedure Cls (Col : Byte;dest:Word); assembler;
asm
   push    es
   mov     cx, 32000;
   mov     es,[dest]
   xor     di,di
   mov     al,[col]
   mov     ah,al
   rep     stosw
   pop     es
End;

procedure WriteXY (cx,cy:Word; Col:Byte; txt:string;dest:word);
var
   Teller: Integer;
procedure drawchar(charx,chary:Word;dchar:chararray;colo:byte);
var x,y:Word;
begin
   x:=0;
   for x:=0 to 4 do
     for y:= 0 to 4 do
        if dchar[y,x]<>0 then
          if ((charx+x) >= 0) and ((chary+y) >= 0) then putpixel (charx+x,chary+y,colo,dest);
end;
begin
   For Teller:=1 to Length(txt) do begin
     if Upcase(txt[Teller]) = 'A' then DrawChar (cx+(Teller*7),cy,A,col);
     if Upcase(txt[Teller]) = 'B' then DrawChar (cx+(Teller*7),cy,B,col);
     if Upcase(txt[Teller]) = 'C' then DrawChar (cx+(Teller*7),cy,C,col);
     if Upcase(txt[Teller]) = 'D' then DrawChar (cx+(Teller*7),cy,D,col);
     if Upcase(txt[Teller]) = 'E' then DrawChar (cx+(Teller*7),cy,E,col);
     if Upcase(txt[Teller]) = 'F' then DrawChar (cx+(Teller*7),cy,F,col);
     if Upcase(txt[Teller]) = 'G' then DrawChar (cx+(Teller*7),cy,G,col);
     if Upcase(txt[Teller]) = 'H' then DrawChar (cx+(Teller*7),cy,H,col);
     if Upcase(txt[Teller]) = 'I' then DrawChar (cx+(Teller*7),cy,I,col);
     if Upcase(txt[Teller]) = 'J' then DrawChar (cx+(Teller*7),cy,J,col);
     if Upcase(txt[Teller]) = 'K' then DrawChar (cx+(Teller*7),cy,K,col);
     if Upcase(txt[Teller]) = 'L' then DrawChar (cx+(Teller*7),cy,L,col);
     if Upcase(txt[Teller]) = 'M' then DrawChar (cx+(Teller*7),cy,M,col);
     if Upcase(txt[Teller]) = 'N' then DrawChar (cx+(Teller*7),cy,N,col);
     if Upcase(txt[Teller]) = 'O' then DrawChar (cx+(Teller*7),cy,O,col);
     if Upcase(txt[Teller]) = 'P' then DrawChar (cx+(Teller*7),cy,P,col);
     if Upcase(txt[Teller]) = 'Q' then DrawChar (cx+(Teller*7),cy,Q,col);
     if Upcase(txt[Teller]) = 'R' then DrawChar (cx+(Teller*7),cy,R,col);
     if Upcase(txt[Teller]) = 'S' then DrawChar (cx+(Teller*7),cy,S,col);
     if Upcase(txt[Teller]) = 'T' then DrawChar (cx+(Teller*7),cy,T,col);
     if Upcase(txt[Teller]) = 'U' then DrawChar (cx+(Teller*7),cy,U,col);
     if Upcase(txt[Teller]) = 'V' then DrawChar (cx+(Teller*7),cy,V,col);
     if Upcase(txt[Teller]) = 'W' then DrawChar (cx+(Teller*7),cy,W,col);
     if Upcase(txt[Teller]) = 'X' then DrawChar (cx+(Teller*7),cy,X,col);
     if Upcase(txt[Teller]) = 'Y' then DrawChar (cx+(Teller*7),cy,Y,col);
     if Upcase(txt[Teller]) = 'Z' then DrawChar (cx+(Teller*7),cy,Z,col);
     if Upcase(txt[Teller]) = '1' then DrawChar (cx+(Teller*7),cy,I1,col);
     if Upcase(txt[Teller]) = '2' then DrawChar (cx+(Teller*7),cy,I2,col);
     if Upcase(txt[Teller]) = '3' then DrawChar (cx+(Teller*7),cy,I3,col);
     if Upcase(txt[Teller]) = '4' then DrawChar (cx+(Teller*7),cy,I4,col);
     if Upcase(txt[Teller]) = '5' then DrawChar (cx+(Teller*7),cy,I5,col);
     if Upcase(txt[Teller]) = '6' then DrawChar (cx+(Teller*7),cy,I6,col);
     if Upcase(txt[Teller]) = '7' then DrawChar (cx+(Teller*7),cy,I7,col);
     if Upcase(txt[Teller]) = '8' then DrawChar (cx+(Teller*7),cy,I8,col);
     if Upcase(txt[Teller]) = '9' then DrawChar (cx+(Teller*7),cy,I9,col);
     if Upcase(txt[Teller]) = '0' then DrawChar (cx+(Teller*7),cy,I0,col);
     if Upcase(txt[Teller]) = '.' then DrawChar (cx+(Teller*7),cy,point,col);
     if Upcase(txt[Teller]) = ',' then DrawChar (cx+(Teller*7),cy,comma,col);
     if Upcase(txt[Teller]) = '@' then DrawChar (cx+(Teller*7),cy,AC,col);
     if Upcase(txt[Teller]) = '!' then DrawChar (cx+(Teller*7),cy,UT,col);
     if Upcase(txt[Teller]) = '?' then DrawChar (cx+(Teller*7),cy,VT,col);
     if Upcase(txt[Teller]) = '''' then DrawChar (cx+(Teller*7),cy,AP,col);
     if Upcase(txt[Teller]) = '"' then DrawChar (cx+(Teller*7),cy,AP,col);
     if Upcase(txt[Teller]) = '`' then DrawChar (cx+(Teller*7),cy,AP,col);
     if Upcase(txt[Teller]) = '(' then DrawChar (cx+(Teller*7),cy,VO,col);
     if Upcase(txt[Teller]) = ')' then DrawChar (cx+(Teller*7),cy,VS,col);
     if Upcase(txt[Teller]) = ':' then DrawChar (cx+(Teller*7),cy,DP,col);
     if Upcase(txt[Teller]) = ';' then DrawChar (cx+(Teller*7),cy,PK,col);
   end;
end;

Procedure SetVirtual;
BEGIN
  GetMem (VirScr,64000);
  virtualscr := seg (virscr^);
END;

Procedure ResetVirtual;
BEGIN
  FreeMem (VirScr,64000);
END;

procedure CopyScr(source,dest:Word); assembler;
asm
  push    ds
  mov     ax, [Dest]
  mov     es, ax
  mov     ax, [Source]
  mov     ds, ax
  xor     si, si
  xor     di, di
  mov     cx, 32000
  rep     movsw
  pop     ds
end;

procedure LoadFont(filename:String);
var fil:FontFile;
begin
  Assign(Fil, filename);
  {$I-} Reset(Fil); {$I+}
  if IOResult<>0 then
  begin
    WriteLn ('Font file not found...');
    Halt(2);
  end;
  Read(Fil,I1,I2,I3,I4,I5,I6,I7,I8,I9,I0,
           a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,
           Point,Comma,AC,UT,VT,AP,VO,VS,DP,PK);
  Close(Fil);
end;

procedure XorLine(X1, Y1, X2, Y2 : integer;dest:word);

VAR DeltaX, DeltaY, XStep, YStep, Error : integer;

   procedure
      DrawPixel(X, Y : integer);

      begin { DrawPixel }
         PutPixel(X, Y, GetPixel(X, Y, dest) xor xorv, dest);
      end { DrawPixel } ;

   begin { XorLine }
      DeltaX := Abs(X2 - X1);                { Bereken de horizontale }
      DeltaY := Abs(Y2 - Y1);                {   en verticale afstand }

      XStep := 1;                            { Bepaal de richting van }
      YStep := 1;                            {   de stapjes in hori-  }
      if X1 > X2 then                        {   zontale en verticale }
         XStep := -1;                        {   zin.                 }
      if Y1 > Y2 then
         YStep := -1;

      DrawPixel(X1, Y1);                     { Plot het beginpunt }

      if DeltaX > DeltaY then                { "Horizontale" lijn }
      begin
         Error := - (DeltaX shr 1);

         while (X1 <> X2) do                 { Zolang we nog niet bij }
         begin                               {   het eindpunt zijn... }
            X1 := X1 + XStep;                { Doe een stapje in      }
            Error := Error + DeltaY;         {   horizontale richting }

            if Error > 0 then
            begin
               Y1 := Y1 + YStep;             { En eventueel ook in  }
               Error := Error - DeltaX;      {   verticale richting }
            end;

            DrawPixel(X1, Y1);               { Teken het nieuwe punt }
         end { while } ;
      end
      else                                   { "Verticale" lijn }
      begin
         Error := - (DeltaY shr 1);

         while (Y1 <> Y2) do                 { Zolang we nog niet bij }
         begin                               {   het eindpunt zijn... }
            Y1 := Y1 + YStep;                { Doe een stapje in    }
            Error := Error + DeltaX;         {   verticale richting }

            if Error > 0 then
            begin
               X1 := X1 + XStep;             { En eventueel ook in    }
               Error := Error - DeltaY;      {   horizontale richting }
            end;

            DrawPixel(X1, Y1);               { Teken het nieuwe punt }
       end { while } ;
    end;
end { XorLine } ;

procedure XorRectangle(x1,y1,x2,y2:integer;dest:Word);
begin
  XorLine(x1,y1,x2,y1,dest);
  XorLine(x1,y2,x2,y2,dest);
  XorLine(x1,y1,x1,y2,dest);
  XorLine(x2,y1,x2,y2,dest);
end;

PROCEDURE Ellipse(exc, eyc, ea, eb : Integer; Color: byte; dest: word);
VAR
  elx, ely : Integer;
  aa, aa2, bb, bb2, d, dx, dy : LongInt;
BEGIN
  elx := 0; ely := eb; aa := LongInt(ea) * ea; aa2 := 2 * aa;
  bb := LongInt(eb) * eb; bb2 := 2 * bb;
  d := bb - aa * eb + aa DIV 4; dx := 0; dy := aa2 * eb;
  PutBrush(exc, eyc - ely, Color, dest); putbrush(exc, eyc + ely, Color,dest);
  PutBrush(exc - ea, eyc, Color,dest); putbrush(exc + ea, eyc, Color,dest);

  WHILE (dx < dy) DO BEGIN
    IF (d > 0) THEN BEGIN Dec(ely); Dec(dy, aa2); Dec(d, dy); END;
    Inc(elx); Inc(dx, bb2); Inc(d, bb + dx);
    putbrush(exc + elx, eyc + ely, Color,dest);
    putbrush(exc - elx, eyc + ely, Color,dest);
    putbrush(exc + elx, eyc - ely, Color,dest);
    putbrush(exc - elx, eyc - ely, Color,dest);
  END;
  Inc(d, (3 * (aa - bb) DIV 2 - (dx + dy)) DIV 2);
  WHILE (ely > 0) DO BEGIN
    IF (d < 0) THEN BEGIN Inc(elx); Inc(dx, bb2); Inc(d, bb + dx); END;
    Dec(ely); Dec(dy, aa2); Inc(d, aa - dy);
    putbrush(exc + elx, eyc + ely, Color,dest);
    putbrush(exc - elx, eyc + ely, Color,dest);
    putbrush(exc + elx, eyc - ely, Color,dest);
    putbrush(exc - elx, eyc - ely, Color,dest);
  END;
END;

PROCEDURE FEllipse(exc, eyc, ea, eb : Integer; Color: byte; dest: word);
var rx1, rx2, ry1, ry2, oldsh : integer;
begin
  oldsh:=currentshape;
  currentshape:=1;
  rx1:=exc; rx2:=ea; ry1:=eyc; ry2:=eb;
  while (rx2<>0) or (ry2<>0) do
  begin
    Ellipse(rx1,ry1,rx2,ry2,color,dest);
    if rx2<>0 then
      dec(rx2);
    if ry2<>0 then
      dec(ry2);
  end;
  currentshape:=oldsh;
end;

PROCEDURE XorEllipse(exc, eyc, ea, eb : Integer; dest: word);
VAR
  elx, ely : Integer;
  oldsh: Integer;
  aa, aa2, bb, bb2, d, dx, dy : LongInt;
  procedure
      DrawPixel(X, Y : integer);

      begin { DrawPixel }
         PutPixel(X, Y, GetPixel(X, Y, dest) xor XorV, dest);
      end { DrawPixel } ;

BEGIN
  Oldsh:=currentshape;
  currentshape:=ShOnePoint;
  elx := 0; ely := eb; aa := LongInt(ea) * ea; aa2 := 2 * aa;
  bb := LongInt(eb) * eb; bb2 := 2 * bb;
  d := bb - aa * eb + aa DIV 4; dx := 0; dy := aa2 * eb;
  DrawPixel(exc, eyc - ely); DrawPixel(exc, eyc + ely);
  DrawPixel(exc - ea, eyc); DrawPixel(exc + ea, eyc);

  WHILE (dx < dy) DO BEGIN
    IF (d > 0) THEN BEGIN Dec(ely); Dec(dy, aa2); Dec(d, dy); END;
    Inc(elx); Inc(dx, bb2); Inc(d, bb + dx);
    DrawPixel(exc + elx, eyc + ely);
    DrawPixel(exc - elx, eyc + ely);
    DrawPixel(exc + elx, eyc - ely);
    DrawPixel(exc - elx, eyc - ely);
  END;
  Inc(d, (3 * (aa - bb) DIV 2 - (dx + dy)) DIV 2);
  WHILE (ely > 0) DO BEGIN
    IF (d < 0) THEN BEGIN Inc(elx); Inc(dx, bb2); Inc(d, bb + dx); END;
    Dec(ely); Dec(dy, aa2); Inc(d, aa - dy);
    DrawPixel(exc + elx, eyc + ely);
    DrawPixel(exc - elx, eyc + ely);
    DrawPixel(exc + elx, eyc - ely);
    DrawPixel(exc - elx, eyc - ely);
  END;
  currentshape:=oldsh;
END;

procedure show_palet;
var x,y,p :integer;
begin
  cls(0,visualscr);
  x :=7;y :=12;
  for p :=0 to 255 do begin
    FRectangle(x,y,x+17,y+9,p,visualscr);
    inc(x,19);if x >299 then begin x :=7;inc(y,11);end;
  end;
end;

PROCEDURE FloodFill(StartX, StartY : INTEGER; Color : BYTE);
TYPE
  XYType = RECORD
    X, Y : INTEGER
  END;
CONST
  StackSize  = 500;
VAR
  V,
  RegionColor : BYTE;
  StackPtr    : INTEGER;
  Stack       : ARRAY[0..StackSize] OF XYType;
  Holder      : XYType;
  OKToPush    : BOOLEAN;
  X, X1, Xr, Y : INTEGER;
  Oldsh        : Integer;
BEGIN
  OldSh:=currentshape;
  currentshape:=ShOnePoint;
  RegionColor := GetPixel(StartX, StartY, visualscr);
  IF RegionColor = Color THEN EXIT;

  OkToPush := TRUE;
  Holder.X := StartX;
  Holder.Y := StartY;
  StackPtr := 0;
  Stack[StackPtr] := Holder;
  INC(StackPtr);
  WHILE (StackPtr > 0) AND (StackPtr <= StackSize) DO
  BEGIN
    DEC(StackPtr);
    Holder := Stack[StackPtr];

    X1 := Holder.X;
    XR := X1;
    Y := Holder.Y;

    X := X1;
    IF (X > 0) THEN
    BEGIN
      REPEAT
        DEC(X);
        V := GetPixel(X, Y, visualscr);
      UNTIL (V <> RegionColor) OR (X < 0);
      INC(X);
      X1 := X;
    END;
    X := XR;
    IF (X <= 319) THEN
    BEGIN
      REPEAT
        INC(X);
        V := GetPixel(X, Y, visualscr);
      UNTIL (V <> RegionColor) OR (X > 319);
      DEC(X);
      XR := X;
    END;
    Line(X1, Y, XR, Y, Color, visualscr);

    IF Y > 0 THEN
      for X:= X1 TO XR DO
      BEGIN
        V := GetPixel(X, Y-1, visualscr);
        IF (V = RegionColor) AND OkToPush THEN
        BEGIN
          Holder.X := X;
          Holder.Y := Y-1;
          Stack[StackPtr] := Holder;
          INC(StackPtr);
          IF StackPtr < StackSize THEN
          BEGIN
            REPEAT
              INC(X);
              V := GetPixel(X, Y-1, visualscr);
            UNTIL (V <> RegionColor) OR (X >= 319);
            DEC(X);
            IF X > XR THEN Exit;
          END
          ELSE
            OkToPush := FALSE;
        END;
      END;

    IF Y < 199 THEN
      for X := X1 TO XR DO
      BEGIN
        V := GetPixel(X, Y+1, visualscr);
        IF (V = RegionColor) AND OkToPush THEN
        BEGIN
          Holder.X := X;
          Holder.Y := Y+1;
          Stack[StackPtr] := Holder;
          INC(StackPtr);
          IF (StackPtr < StackSize) THEN
          BEGIN
            REPEAT
              INC(X);
              V := GetPixel(X, Y+1, visualscr);
            UNTIL (V <> RegionColor) OR (X >= 319);
            DEC(X);
            IF X > XR THEN Exit;
          END
          ELSE
            OkToPush := FALSE;
        END;
      END;
  END;
  CurrentShape:=OldSh;
END;

procedure GetImage(var Image:ImageType;x1,y1,x2,y2:word; dest: word);
var
  yImg,yShl,x,y,size,vSeg,vOfs:word;
begin
  Image.DeltaX:=abs(x2-x1); Image.DeltaY:=abs(y2-y1);
  GetMem(Image.Image,(Image.DeltaX+1)*(Image.DeltaY+1));
  Image.vSegment:=seg(Image.Image^); vSeg:=Image.vSegment;
  Image.vOffset:=ofs(Image.Image^); vOfs:=Image.vOffset;

  for x:=x1 to x2 do begin
    for y:=y1 to y2 do begin
      Mem[Image.vSegment:Image.vOffset+((y-y1)*(Image.DeltaX+1))+(x-x1)]:=GetPixel(x,y,dest);
    end; {for}
  end; {for}
end; {GetImage}

procedure PutImage(Image:ImageType;x1,y1:word;dest:word);
var
  yImg,yShl:word;
  x,y:word;
begin
  for x:=0 to Image.DeltaX do begin
    for y:=0 to Image.DeltaY do begin
      if ((x1+x) < 320) and ((y1+y) < 200) and ((x1+x) >= 0) and ((y1+y)>=0) then
        Mem[dest:(y+y1)*320+x+x1]:=Mem[Image.vSegment:Image.vOffset+(y*(Image.DeltaX+1))+x];
    end; {for}
  end; {for}
end; {PutImage}

procedure KillImage(var Image:ImageType);
begin
  FreeMem(Image.Image,(Image.DeltaX+1)*(Image.DeltaY+1));
end; {KillImage}

procedure MoveD(SourceSeg, SourceOfs, DestSeg, DestOfs, AnzBytes: Word); Assembler;
asm
    push   ds
    mov    ds, [SourceSeg]
    mov    si, [SourceOfs]
    mov    es, [DestSeg]
    mov    di, [DestOfs]
    mov    bx, AnzBytes           { BX := AnzBytes                   }
    mov    cx, bx
    shr    cx, 2                  { Anz. d. Bytes durch 4 dividieren }
db 66h
    rep    movsw                  { rep movsd }
    and    bx, 00000011b
    mov    cx, bx
    rep    movsb
    pop ds
end;

procedure ScrollUp(x1, y1, x2, y2, numlines, SegAdr: word);
var y: integer;
begin
  if y1 = 0 then y:=1
            else y:=y1;
  for y:=y to y2 do
    moved(SegAdr, y*320+x1, SegAdr, (y-numlines)*320+x1, (x2-x1)+1);
  FRectangle(x1, y2-numlines+1, x2, y2, 0, SegAdr);
end;

procedure ScrollDn(x1, y1, x2, y2, numlines, SegAdr: word);
var y: integer;
begin
  if y2 = 199 then y:=198
              else y:=y2;
  for y:=y downto y1 do
    moved(SegAdr, y*320+x1, SegAdr, (y+numlines)*320+x1, (x2-x1)+1);
  FRectangle(x1, y1, x2, y1+numlines-1, 0, SegAdr);
end;

procedure WriteText(Xpos,Ypos : word; Color : byte; ScrTxt : string; dest: word);
var
  I,J,K : byte;
  FontSeg, FontOfs: word;
  Regs : registers;

begin
  with Regs do begin
    AX := $1130;
    BH := 1;
    intr($10,Regs);
    FontSeg := ES;
    FontOfs := BP;
  end;
  for I := 1 to length(ScrTxt) do
    for J := 0 to 7 do
      for K := 0 to 7 do
        if ((mem[FontSeg:FontOfs+ord(ScrTxt[I])*8+J] shl K) and 128) <> 0 then
          mem[dest:(Ypos+J)*320+(I*8)+Xpos+K] := Color;
end;

end.