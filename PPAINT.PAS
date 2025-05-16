Program PowerPaint;

USES Mouse, Crt,vga, dos, pcx, pli;

var
   MouseB, LastB          : word;               { Mouse Buttons }
   MouseX, LastX          : word;               { Mouse X coordinaat }
   MouseY, LastY          : word;               { Mouse Y coordinaat }
   Kar                    : char;               { karakter }
   FilNam                 : string;
   LineX, LineY           : word;
   Color                  : Byte;
   Action                 : Integer;
   Xit                    : Integer;
   MaxX, MaxY             : Integer;
   Filename               : string;
   Selected               : boolean;
   Selection              : ImageType;
   SelX1, SelX2,
   SelY1, SelY2           : Integer;
   BACKGR                 : byte;
   Currentfont            : string;
   F                      : text;

Const
   VERSION = '2.3';

{$I mousecur.inc}

FUNCTION  FileExist(filename:STRING):BOOLEAN;
 VAR fil:FILE;
 BEGIN
   {$I-}
   Assign(fil,filename);
   Reset(fil);
   Close(fil);
   {$I+}
   FileExist:=(IOResult=0) AND (filename<>'');
 END;

procedure PutImag(Image:ImageType;x1,y1:word;dest:word);
var
  yImg,yShl:word;
  x,y:word;
begin
  for x:=0 to Image.DeltaX do begin
    for y:=0 to Image.DeltaY do begin
      if Mem[Image.vSegment:Image.vOffset+(y*(Image.DeltaX+1))+x] <> BACKGR then
        Mem[dest:(y+y1)*320+x+x1]:=Mem[Image.vSegment:Image.vOffset+(y*(Image.DeltaX+1))+x];
    end; {for}
  end; {for}
end; {PutImage}


function MouseIn(x1,y1,x2,y2: integer) : boolean;
begin
  if (MouseX>=x1) and (MouseX<=x2) and (MouseY>=y1) and (MouseY<=y2) then
    MouseIn:=TRUE
  else
    MouseIn:=FALSE;
end;

procedure Selectedbox (x1,y1,x2,y2:integer);
var oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=5;
  if selected then
  begin
    XorLine(x1, y1, x1+3, y1, visualscr);XorLine(x1, y1, x1, y1+3, visualscr);
    XorLine(x2, y1, x2-3, y1, visualscr);XorLine(x2, y1, x2, y1+3, visualscr);
    XorLine(x1, y2, x1+3, y2, visualscr);XorLine(x1, y2, x1, y2-3, visualscr);
    XorLine(x2, y2, x2-3, y2, visualscr);XorLine(x2, y2, x2, y2-3, visualscr);
  end else XorRectangle(x1,y1,x2,y2,visualscr);
  CurrentShape:=OldSh;
end;

procedure get_palet;
var x,y,p :integer;
begin
  cls(0,visualscr);
  x :=7;y :=12;
  for p :=0 to 254 do begin
    if MouseIn (x,y,x+17,y+9) then Color:=p;
    inc(x,19);if x >299 then begin x :=7;inc(y,11);end;
  end;
end;

procedure bget_palet;
var x,y,p :integer;
begin
  cls(0,visualscr);
  x :=7;y :=12;
  for p :=0 to 254 do begin
    if MouseIn (x,y,x+17,y+9) then BACKGR:=p;
    inc(x,19);if x >299 then begin x :=7;inc(y,11);end;
  end;
end;

function ButtonClicked(x, y: integer; t: string):boolean;
var x1,x2,y1,y2 : integer;
    Oldsh: integer;
begin
  x1:=x; y1:=y;
  x2:=x+(length(t)*7)+1;
  y2:=y+10;
  if (MouseX>=x1) and (MouseX<=x2) and (MouseY>=y1) and (MouseY<=y2)
      and ((MouseB and L_Pressed) <> 0) then
  begin
    MouseHide;
    Oldsh:=currentshape;
    currentshape:=ShOnePoint;
    ButtonDown(x,y,t,visualscr);
    sound(1000);
    delay(2);
    Nosound;
    delay(250);
    Button(x,y,t,visualscr);
    Currentshape:=oldsh;
    MouseShow;
    ButtonClicked:=TRUE
  end
  else
    ButtonClicked:=FALSE;
end;


procedure GetPallet;
var
  col  : integer;
  y    : integer;
  oldsh: integer;
begin
  y:=20;
  col:=0;
  while col<254 do
  begin
    if(MouseX=256) and (MouseY=y) then Color:=Col;
    if(MouseX=257) and (MouseY=y) then Color:=Col;
    if(MouseX=258) and (MouseY=y) then Color:=Col;
    if(MouseX=259) and (MouseY=y) then Color:=Col;
    inc(col);
    if(MouseX=260) and (MouseY=y) then Color:=Col;
    if(MouseX=261) and (MouseY=y) then Color:=Col;
    if(MouseX=262) and (MouseY=y) then Color:=Col;
    if(MouseX=263) and (MouseY=y) then Color:=Col;
    inc(col);
    if(MouseX=264) and (MouseY=y) then Color:=Col;
    if(MouseX=265) and (MouseY=y) then Color:=Col;
    if(MouseX=266) and (MouseY=y) then Color:=Col;
    if(MouseX=267) and (MouseY=y) then Color:=Col;
    inc(y);
    col:=col-2;
    if(MouseX=256) and (MouseY=y) then Color:=Col;
    if(MouseX=257) and (MouseY=y) then Color:=Col;
    if(MouseX=258) and (MouseY=y) then Color:=Col;
    if(MouseX=259) and (MouseY=y) then Color:=Col;
    Inc(col);
    if(MouseX=260) and (MouseY=y) then Color:=Col;
    if(MouseX=261) and (MouseY=y) then Color:=Col;
    if(MouseX=262) and (MouseY=y) then Color:=Col;
    if(MouseX=263) and (MouseY=y) then Color:=Col;
    Inc(col);
    if(MouseX=264) and (MouseY=y) then Color:=Col;
    if(MouseX=265) and (MouseY=y) then Color:=Col;
    if(MouseX=266) and (MouseY=y) then Color:=Col;
    if(MouseX=267) and (MouseY=y) then Color:=Col;
    Inc(col);
    if(MouseX=264) and (MouseY=y) then Color:=Col;
    if(MouseX=265) and (MouseY=y) then Color:=Col;
    if(MouseX=266) and (MouseY=y) then Color:=Col;
    if(MouseX=267) and (MouseY=y) then Color:=Col;
    Inc(col);
    Inc(y);
  end;
  putbrush(5,5, color, visualscr);
end;

procedure BGetPallet;
var
  col  : integer;
  y    : integer;
  oldsh: integer;
begin
  y:=20;
  col:=0;
  while col<254 do
  begin
    if(MouseX=256) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=257) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=258) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=259) and (MouseY=y) then BACKGR:=Col;
    inc(col);
    if(MouseX=260) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=261) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=262) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=263) and (MouseY=y) then BACKGR:=Col;
    inc(col);
    if(MouseX=264) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=265) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=266) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=267) and (MouseY=y) then BACKGR:=Col;
    inc(y);
    col:=col-2;
    if(MouseX=256) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=257) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=258) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=259) and (MouseY=y) then BACKGR:=Col;
    Inc(col);
    if(MouseX=260) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=261) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=262) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=263) and (MouseY=y) then BACKGR:=Col;
    Inc(col);
    if(MouseX=264) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=265) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=266) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=267) and (MouseY=y) then BACKGR:=Col;
    Inc(col);
    if(MouseX=264) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=265) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=266) and (MouseY=y) then BACKGR:=Col;
    if(MouseX=267) and (MouseY=y) then BACKGR:=Col;
    Inc(col);
    Inc(y);
  end;
  FRectangle(15, 1, 20, 6, BACKGR, visualscr);
end;

procedure Pallet;
var
  col  : integer;
  y    : integer;
  oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  y:=20;
  col:=0;
  while col<254 do
  begin
    PutPixel(256, y, col, virtualscr);PutPixel(257, y, col, virtualscr);
    PutPixel(258, y, col, virtualscr);PutPixel(259, y, col, virtualscr);
    inc(col);
    PutPixel(260, y, col, virtualscr);PutPixel(261, y, col, virtualscr);
    PutPixel(262, y, col, virtualscr);PutPixel(263, y, col, virtualscr);
    inc(col);
    PutPixel(264, y, col, virtualscr);PutPixel(265, y, col, virtualscr);
    PutPixel(266, y, col, virtualscr);PutPixel(267, y, col, virtualscr);
    col:=col-2;
    inc(y);
    PutPixel(256, y, col, virtualscr);PutPixel(257, y, col, virtualscr);
    PutPixel(258, y, col, virtualscr);PutPixel(259, y, col, virtualscr);
    Inc(col);
    PutPixel(260, y, col, virtualscr);PutPixel(261, y, col, virtualscr);
    PutPixel(262, y, col, virtualscr);PutPixel(263, y, col, virtualscr);
    Inc(col);
    PutPixel(264, y, col, virtualscr);PutPixel(265, y, col, virtualscr);
    PutPixel(266, y, col, virtualscr);PutPixel(267, y, col, virtualscr);
    Inc(col);
    PutPixel(264, y, col, virtualscr);PutPixel(265, y, col, virtualscr);
    PutPixel(266, y, col, virtualscr);PutPixel(267, y, col, virtualscr);
    Inc(col);
    Inc(y);
  end;
  currentshape:=oldsh;
end;

procedure vPallet;
var
  col  : integer;
  y    : integer;
  oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  y:=20;
  col:=0;
  while col<254 do
  begin
    PutPixel(256, y, col, visualscr);PutPixel(257, y, col, visualscr);
    PutPixel(258, y, col, visualscr);PutPixel(259, y, col, visualscr);
    inc(col);
    PutPixel(260, y, col, visualscr);PutPixel(261, y, col, visualscr);
    PutPixel(262, y, col, visualscr);PutPixel(263, y, col, visualscr);
    inc(col);
    PutPixel(264, y, col, visualscr);PutPixel(265, y, col, visualscr);
    PutPixel(266, y, col, visualscr);PutPixel(267, y, col, visualscr);
    inc(y);
    col:=col-2;
    PutPixel(256, y, col, visualscr);PutPixel(257, y, col, visualscr);
    PutPixel(258, y, col, visualscr);PutPixel(259, y, col, visualscr);
    Inc(col);
    PutPixel(260, y, col, visualscr);PutPixel(261, y, col, visualscr);
    PutPixel(262, y, col, visualscr);PutPixel(263, y, col, visualscr);
    Inc(col);
    PutPixel(264, y, col, visualscr);PutPixel(265, y, col, visualscr);
    PutPixel(266, y, col, visualscr);PutPixel(267, y, col, visualscr);
    Inc(col);
    PutPixel(264, y, col, visualscr);PutPixel(265, y, col, visualscr);
    PutPixel(266, y, col, visualscr);PutPixel(267, y, col, visualscr);
    Inc(col);
    Inc(y);
  end;
  currentshape:=oldsh;
end;

procedure init;
begin
   BACKGR:=white;
   Color:=black;
   Filename:='';
   Cls(black, visualscr);
   Currentshape:=ShOnePoint;
   WriteXY(1,1, white, 'One moment please...', visualscr);
   Cls(black, virtualscr);
   WriteXY(30, 1, yellow, 'Power Paint version '+VERSION, virtualscr);
   FRectangle(1, 15, MaxX+3, MaxY, BACKGR, virtualscr);
   FRectangle(255, 15, 318, 198, white, virtualscr);
   Currentshape:=0; putbrush(310, 20, black, virtualscr);
   Currentshape:=1; putbrush(310, 30, black, virtualscr);
   Currentshape:=2; putbrush(310, 40, black, virtualscr);
   Currentshape:=3; putbrush(310, 50, black, virtualscr);
   Currentshape:=4; putbrush(310, 60, black, virtualscr);
   Currentshape:=5; putbrush(310, 70, black, virtualscr);
   Currentshape:=6; putbrush(310, 80, black, virtualscr);
   Pallet;
   currentshape:=0;
   Button(271, 18, 'Poin', virtualscr);
   Button(271, 30, 'Line', virtualscr);
   Button(271, 42, 'Rect', virtualscr);
   Button(271, 54, 'Elli', virtualscr);
   Button(271, 66, 'Eras', virtualscr);
   Button(271, 78, 'Fill', virtualscr);
   Button(271, 90, 'Text', virtualscr);
   Button(271, 102,'Slct', virtualscr);
   Button(271, 114,'Zoom', virtualscr);

   Button(271, 128, 'Cls ', virtualscr);
   Button(271, 140, 'Load', virtualscr);
   Button(301, 140, 'fn', virtualscr);
   Button(271, 152, 'Save', virtualscr);
   Button(271, 164, 'S.as', virtualscr);
   Button(271, 176, 'Exit', virtualscr);
   Button(301, 176, '??', virtualscr);
   Button(255, 188, ' Palette ', virtualscr);
   currentshape:=0;
   CopyScr(virtualscr, visualscr);
   currentshape:=ShRectSmall;
   putbrush(5,5, color, visualscr);
   FRectangle(15, 1, 20, 6, BACKGR, visualscr);
end;

procedure Save;
var Loop: byte;
    FullFilename: boolean;
    Saveas: byte;
    countx,county: integer;
    puts: string;
begin
  MouseHide;
  CopyScr(visualscr, virtualscr);
  FRectangle(10,20,200,100,red,visualscr);
  FRectangle(20,45,150,58,black,visualscr);
  Button(20, 80, 'pcx', visualscr);
  Button(50, 80, 'pas', visualscr);
  Button(80, 80, 'cpp', visualscr);
  Button(110,80, 'dat', visualscr);
  WriteXY(130,22,yellow,'Save', visualscr);
  WriteXY(15,32,white,'Type filename', visualscr);
  gotoxy(5,7); ReadLn(Filename);
  MouseShow;
  puts:=Filename;
  Saveas:=0;
  repeat
    MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
    MouseX := MouseX div 2;
    if ButtonClicked(20, 80, 'pcx') then Saveas:=1;
    if ButtonClicked(50, 80, 'pas') then Saveas:=2;
    if ButtonClicked(80, 80, 'cpp') then Saveas:=3;
    if ButtonClicked(110,80, 'dat') then Saveas:=4;
  until Saveas<>0;
  MouseHide;
  if Filename<>'' then begin
  FullFilename:=FALSE;
  For Loop := 1 to Ord(Filename[0]) do
      Begin
         FileName[Loop] := Filename[Loop];
         If FileName[Loop] = '.'
            then
               FullFilename := TRUE;
      end;

  If Not(FullFilename) then
  begin
    if Saveas=1 then Filename:=Filename+'.pcx';
    if Saveas=2 then Filename:=Filename+'.pas';
    if Saveas=3 then Filename:=Filename+'.cpp';
    if Saveas=4 then Filename:=Filename+'.dat';
  end;
  CopyScr(virtualscr,visualscr);
  CopyScr(visualscr,virtualscr);
  GetAllPalette(Palette);
  WriteXY(250, 1, red, 'Busy...', visualscr);
  if Saveas=1 then SaveAreaAsPCX(Filename,Palette,1,15, MaxX,200-16);
  if Saveas=4 then
  begin
    if not FileExist(Filename) then PLI_CreateNew(Filename);
    PLI_Add(Filename, 0, 15, visualscr);
  end;
  if Saveas=2 then
  begin
    CopyScr(virtualscr,visualscr);
    WriteXY(220, 1, red, 'Click where', visualscr);
    delay(200);
    XorRectangle(MouseX, MouseY, MouseX+25, MouseY+25, visualscr);
    repeat
      LastX := MouseX;
      LastY := MouseY;
      LastB := MouseB;
      MouseGetPosition(MouseB, MouseX, MouseY);
      MouseX := MouseX div 2;
      if (LastX <> MouseX) or (LastY <> MouseY) or
         (LastB <> MouseB) then
      begin
        XorRectangle(LastX, LastY, LastX+25, LastY+25, visualscr);
        XorRectangle(MouseX, MouseY, MouseX+25, MouseY+25, visualscr);
      end;
   until (MouseB and L_Pressed) <> 0;
    XorRectangle(MouseX, MouseY, MouseX+25, MouseY+50, visualscr);
    Assign(F, filename);
    Rewrite(F);
    WriteLn(F, '{ Include file ',filename,'     }');
    WriteLn(F, '{ Produced by Power Paint II      }');
    WriteLn(F, '{ by Zef Hemel and Sander de Jong }');
    WriteLn(F);
    WriteLn(F,'PROCEDURE Show_',puts,'(px,py: integer);');
    WriteLn(F,'CONST');
    WriteLn(F,'  Picture: array [0..25,0..25] of byte =');
    Write  (F,'     (');
    for county:=0 to 25 do
    begin
      if county=0 then Write(F,'(')
        else Write(F,'      (');
      for countx:=0 to 25 do
      begin
        if countx <> 25 then
          Write(F, ord(getpixel(MouseX+countx,MouseY+county,visualscr)),',')
        else
          Write(F, ord(getpixel(MouseX+countx,MouseY+county,visualscr)));
      end;
      if county <> 25 then WriteLn(F,'),')
        else WriteLn(F,'));');
    end;
    WriteLn(F,'VAR x,y : integer;');
    WriteLn(F,'BEGIN');
    WriteLn(F,'  CurrentShape:=ShOnePoint;');
    WriteLn(F,'  for y:=0 to 25 do');
    WriteLn(F,'    for x:=0 to 25 do');
    WriteLn(F,'      if Picture[y,x] <> ', BACKGR, ' then');
    WriteLn(F,'        PutPixel(x+px,y+py,Picture[y,x],visualscr);');
    WriteLn(F,'end;');
    Close(F);
    Filename:='';
  end;
  if Saveas=3 then
  begin
    CopyScr(virtualscr,visualscr);
    WriteXY(220, 1, red, 'Click where', visualscr);
    delay(200);
    XorRectangle(MouseX, MouseY, MouseX+25, MouseY+25, visualscr);
    repeat
      LastX := MouseX;
      LastY := MouseY;
      LastB := MouseB;
      MouseGetPosition(MouseB, MouseX, MouseY);
      MouseX := MouseX div 2;
      if (LastX <> MouseX) or (LastY <> MouseY) or
         (LastB <> MouseB) then
      begin
        XorRectangle(LastX, LastY, LastX+25, LastY+25, visualscr);
        XorRectangle(MouseX, MouseY, MouseX+25, MouseY+25, visualscr);
      end;
   until (MouseB and L_Pressed) <> 0;
    XorRectangle(MouseX, MouseY, MouseX+25, MouseY+25, visualscr);
    Assign(F, filename);
    Rewrite(F);
    WriteLn(F, '// Include file ',filename,'     }');
    WriteLn(F, '// Produced by Power Paint II      }');
    WriteLn(F, '// by Zef Hemel and Sander de Jong }');
    WriteLn(F);
    WriteLn(F,'unsigned char Picture[25*25] =');
    WriteLn(F,'     {');
    for county:=0 to 25 do
    begin
      Write(F,'      ');
      for countx:=0 to 25 do
      begin
        if countx <> 25 then
          Write(F, ord(getpixel(MouseX+countx,MouseY+county,visualscr)),',')
        else
          Write(F, ord(getpixel(MouseX+countx,MouseY+county,visualscr)));
      end;
      if county <> 25 then WriteLn(F,',');
    end;
    WriteLn(F);
    WriteLn(F, '     };');
    Close(F);
    Filename:='';
  end;
  end;
  CopyScr(virtualscr,visualscr);
  MouseShow;
  sound(650); delay(50);
  sound(600); delay(50);
  sound(550); delay(50);
  sound(500); delay(50);
  nosound;
  LineX:=MouseX; LineY:=MouseY;
end;

function VSave : boolean;
var Loop : byte;
    key  : char;
    Oldsh: integer;
    uit  : integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  MouseHide;
  CopyScr(visualscr,virtualscr);
  FRectangle(10,20,200,64,red,visualscr);
  WriteXY(140,22,yellow,'Exit', visualscr);
  WriteXY(15,32,white,'Do you want to save ?', visualscr);
  Button(100,44,'Y',visualscr);Button(115,44,'N',visualscr);
  MouseShow;
  uit:=0;
  repeat
      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
      IF ButtonClicked(100,44,'Y') THEN uit:=1;
      IF ButtonClicked(115,44,'N') THEN uit:=2;
  until uit<>0;
  currentshape:=oldsh;
  MouseHide;
  CopyScr(virtualscr,visualscr);
  MouseShow;
  if uit=1 then VSave:=TRUE
    else VSave:=FALSE;
end;

procedure Wrong;
var Loop : byte;
    key  : char;
    Oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  MouseHide;
  CopyScr(visualscr,virtualscr);
  FRectangle(10,20,220,72,red,visualscr);
  WriteXY(140,22,yellow,'Bug found!', visualscr);
  WriteXY(15,32,white,'Power Paint detected a bug.', visualscr);
  WriteXY(15,40,white,'I have to reinit. I''m sorry.', visualscr);
  WriteXY(15,48,white,'Please report the bug!', visualscr);
  Button(100,60,'OK',visualscr);
  MouseShow;
  repeat
      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
  until ButtonClicked(100,60,'OK');
  MouseHide;
  Init;
  MouseShow;
  LineX:=MouseX; LineY:=MouseY;
  LastB:=0; MouseB:=0;
end;

procedure About;
var Loop : byte;
    key  : char;
    Oldsh: integer;
begin
  oldsh:=currentshape;
  currentshape:=ShOnePoint;
  MouseHide;
  CopyScr(visualscr,virtualscr);
  FRectangle(10,20,200,130,red,visualscr);
  WriteXY(155,22,yellow,'About', visualscr);
  WriteXY(15,32,white,'Power Paint version 2.3', visualscr);
  WriteXY(15,40,white,'Programming by', visualscr);
  WriteXY(15,48,white,'  Zef Hemel', visualscr);
  WriteXY(15,56,white,'  Sander de Jong', visualscr);
  WriteXY(15,64,white,'Fonts by', visualscr);
  WriteXY(15,72,white,'  Zef Hemel', visualscr);
  WriteXY(15,80,white,'  Sander de Jong', visualscr);
  WriteXY(15,88,white,'EMail:', visualscr);
  WriteXY(15,96,white,'  zef@zefnet.com', visualscr);
  WriteXY(15,104,white,'  s.dejong@mailcity.com', visualscr);
  Button(140, 110, 'OK',visualscr);
  MouseShow;
  repeat
      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
  until ButtonClicked(140,110,'OK');
  MouseHide;
  CopyScr(virtualscr,visualscr);
  MouseShow;
end;

procedure Load;
var Loop: byte;
    FullFilename: boolean;
    Saveas: byte;
    number: integer;
begin
  MouseHide;
  CopyScr(visualscr, virtualscr);
  FRectangle(10,20,200,100,red,visualscr);
  Button(20, 80, 'pcx', visualscr);
  Button(50, 80, 'dat', visualscr);
  FRectangle(20,45,150,58,black,visualscr);
  WriteXY(130,22,yellow,'Load', visualscr);
  WriteXY(15,32,white,'Type filename', visualscr);
  gotoxy(5,7); ReadLn(Filename);
  MouseShow;
  Saveas:=0;
  repeat
    MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
    MouseX := MouseX div 2;
    if ButtonClicked(20, 80, 'pcx') then Saveas:=1;
    if ButtonClicked(50, 80, 'dat') then Saveas:=2;
  until Saveas<>0;
  MouseHide;
  FullFilename:=FALSE;
  For Loop := 1 to Ord(Filename[0]) do
      Begin
         FileName[Loop] := Filename[Loop];
         If FileName[Loop] = '.'
            then
               FullFilename := TRUE;
      end;
  If Not(FullFilename) then
  begin
    if Saveas=1 then Filename:=Filename+'.pcx';
    if Saveas=2 then Filename:=Filename+'.dat';
  end;
  CopyScr(virtualscr,visualscr);
  CopyScr(visualscr,virtualscr);
  GetAllPalette(Palette);
  Error:='';
  if Saveas = 1 then LocatePCX(Filename,Palette,1,15, MaxX,200-16);
  if Saveas = 2 then
  begin
    FRectangle(10,20,200,100,red,visualscr);
    FRectangle(20,45,150,58,black,visualscr);
    WriteXY(130,22,yellow,'Load', visualscr);
    WriteXY(15,32,white,'Type number of image', visualscr);
    gotoxy(5,7); ReadLn(Number);
    copyscr(virtualscr, visualscr);
    PLI_Load(Filename, Number, 0, 15, visualscr);
  end;
  WriteXY(200, 1, red, Error, visualscr);
  if error<>'' then
  begin
    delay(1000);
    CopyScr(virtualscr,visualscr);
  end;
  MouseShow;
  sound(500); delay(50);
  sound(550); delay(50);
  sound(600); delay(50);
  sound(650); delay(50);
  nosound;
  LineX:=MouseX; LineY:=MouseY;
end;

procedure GetFont;
var Loop: byte;
    FullFilename: boolean;
begin
  MouseHide;
  CopyScr(visualscr, virtualscr);
  FRectangle(10,20,200,70,red,visualscr);
  FRectangle(20,45,150,58,black,visualscr);
  WriteXY(130,22,yellow,'Font', visualscr);
  WriteXY(15,32,white,'Type fontname', visualscr);
  gotoxy(5,7); ReadLn(CurrentFont);
  FullFilename:=FALSE;
  For Loop := 1 to Ord(CurrentFont[0]) do
      Begin
         CurrentFont[Loop] := CurrentFont[Loop];
         If CurrentFont[Loop] = '.'
            then
               FullFilename := TRUE;
      end;
  If Not(FullFilename) then CurrentFont:=CurrentFont+'.fon';
  CopyScr(virtualscr,visualscr);
  CopyScr(visualscr,virtualscr);
  if FSEARCH(CurrentFont,'') = '' then
  begin
    WriteXY(200, 1, red, 'Font not found', visualscr);
    delay(1000);
    CopyScr(virtualscr,visualscr);
    Currentfont:='default.fon';
  end;
  MouseShow;
  nosound;
end;

procedure WriteWin;
var Loop: byte;
    s: String;
begin
  MouseHide;
  CopyScr(visualscr, virtualscr);
  FRectangle(10,20,270,70,red,visualscr);
  FRectangle(20,45,260,58,black,visualscr);
  WriteXY(130,22,yellow,'Text', visualscr);
  WriteXY(15,32,white,'Type textline', visualscr);
  gotoxy(5,7); ReadLn(s);
  CopyScr(virtualscr,visualscr);
  LoadFont(Currentfont);
  WriteXY(MouseX, MouseY, Color, s, visualscr);
  LoadFont('default.fon');
  MouseShow;
end;

procedure zoom;
var zoomX, zoomY: integer;
    putX , putY : integer;
    calcX, calcY: integer;
begin
   delay(200);
   Standard;
   MouseHide;
   XorRectangle(MouseX, MouseY, MouseX+42, MouseY+27, visualscr);
   MouseSetWindow (0, 15, 255*2-91, 200-28);
   repeat              { Ask for place to zoom }
      LastX := MouseX;                     
      LastY := MouseY;
      LastB := MouseB;
      MouseGetPosition(MouseB, MouseX, MouseY);
      MouseX := MouseX div 2;
      if (LastX <> MouseX) or (LastY <> MouseY) or
         (LastB <> MouseB) then
      begin
        XorRectangle(LastX, LastY, LastX+42, LastY+27, visualscr);
        XorRectangle(MouseX, MouseY, MouseX+42, MouseY+27, visualscr);
      end;
   until (MouseB and L_Pressed) <> 0;
   XorRectangle(MouseX, MouseY, MouseX+42, MouseY+27, visualscr);
   MouseSetWindow (0, 15, 640, 200);
   zoomX:=MouseX; zoomY:=MouseY-3;
   copyscr(visualscr, virtualscr);
   cls(0,visualscr);
   currentshape:=ShRectNormal;
   for putX:=0 to 41 do
     for putY:=3 to 30 do
     begin
       calcX:=putX*6;
       calcY:=putY*6;
       putbrush(calcX+6, calcY, getpixel(zoomX+putX, zoomY+putY,virtualscr), visualscr);
     end;
   vPallet;
   WriteXY(20,1,white,'press esc to exit',visualscr);
   putbrush(5,5, color, visualscr);
   FRectangle(15, 1, 20, 6, BACKGR, visualscr);
   MouseShow;
   repeat
      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
      if ((MouseB and L_Pressed) <> 0) and (MouseX<255) then
      begin
        MouseHide;
        MouseX := MouseX div 6; MouseY := MouseY div 6;
        currentshape:=ShOnePoint;
        putbrush(MouseX+zoomX-1, MouseY+zoomY, color,virtualscr);
        currentshape:=ShRectNormal;
        MouseX := MouseX  *  6; MouseY := MouseY  *  6;
        putbrush(MouseX,MouseY,color,visualscr);
        MouseShow;
      end;
      if ((MouseB and R_Pressed) <> 0) and (MouseX<255) then
      begin
        MouseHide;
        MouseX := MouseX div 6; MouseY := MouseY div 6;
        currentshape:=ShOnePoint;
        putpixel(MouseX+zoomX-1, MouseY+zoomY, BACKGR,virtualscr);
        currentshape:=ShRectNormal;
        MouseX := MouseX  *  6; MouseY := MouseY  *  6;
        putbrush(MouseX,MouseY,BACKGR,visualscr);
        MouseShow;
      end;
      if ((MouseB and L_Pressed) <> 0) and (MouseX>=255) then
        getpallet;
      if ((MouseB and R_Pressed) <> 0) and (MouseX>=255) and (MouseX<271) then
        BGetpallet;
      if keypressed then kar:=readkey;
   until kar=#27;
   MouseHide;
   copyscr(virtualscr,visualscr);
   putbrush(5,5, color, visualscr);
   FRectangle(15, 1, 20, 6, BACKGR, visualscr);
   MouseShow;
   kar:=' ';
   if action = 3 then point;
   if action = 0 then Lin;
   if action = 1 then Rect;
   if action = 2 then Cir;
   if action = 4 then Erase;
   if action = 5 then Fill;
   if action = 6 then Text;
   if action = 10 then Select;
   MouseSetWindow (0, 15, 640, 200);
end;

procedure CheckMouse;
begin
  if (GetPixel(318, 50,visualscr) <> 15) and (MouseX<300) then Wrong;
  if ((MouseB and L_Pressed) <> 0) and (MouseX > 308) and (MouseX < 312) then
  begin
    putbrush(5,5, black, visualscr);
    if (MouseY>=20) and (MouseY<=30) then Currentshape:=0;
    if (MouseY>=30) and (MouseY<=40) then Currentshape:=1;
    if (MouseY>=40) and (MouseY<=50) then Currentshape:=2;
    if (MouseY>=50) and (MouseY<=60) then Currentshape:=3;
    if (MouseY>=60) and (MouseY<=70) then Currentshape:=4;
    if (MouseY>=70) and (MouseY<=80) then Currentshape:=5;
    if (MouseY>=80) and (MouseY<=90)then Currentshape:=6;
    putbrush(5,5, color, visualscr);
  end;
  if ((MouseB and L_Pressed) <> 0) and (MouseX > 250) and (MouseX < 270) then
    GetPallet;
  if ((MouseB and R_Pressed) <> 0) and (MouseX > 250) and (MouseX < 270) then
    BGetPallet;
  if ButtonClicked(271,18,'Poin') then
  begin
    action:=3;
    Point;
  end;
  if ButtonClicked(271,114,'Zoom') then zoom;
  if ButtonClicked(271,30,'Line') then
  begin
    action:=0;
    Lin;
  end;
  if ButtonClicked(271,42,'Rect') then
  begin
    action:=1;
    Rect;
  end;
  if ButtonClicked(271,54,'Elli') then
  begin
    action:=2;
    Cir;
  end;
  if ButtonClicked(271, 66, 'Eras') then
  begin
    action:=4;
    Erase;
  end;
  if ButtonClicked(271, 78, 'Fill') then
  begin
    action:=5;
    Fill;
  end;
  if Buttonclicked(271,102,'Slct') then
  begin
    if action=10 then SelectedBox(SelX1, SelY1, SelX2, SelY2);
    action:=10;
    Select;
    Selected:=FALSE;
  end;
  if ButtonClicked(301,140,'fn') then GetFont;
  if ButtonClicked(271,128,'Cls ') then
  begin
    MouseHide;
    FRectangle(1, 15, MaxX+3, MaxY, BACKGR, visualscr);
    nosound;
    Filename:='';
    MouseShow;
  end;
  if ButtonClicked(271, 90, 'Text') then
  begin
    Action:=6;
    Text;
  end;
  if ButtonClicked(255, 188,' Palette ') then
  begin
    MouseHide;
    CopyScr(visualscr,virtualscr);
    show_palet;
    MouseShow;
    repeat
      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
    until MouseB <> 0;
    if (MouseB and L_Pressed) <> 0 then Get_Palet;
    if (MouseB and R_Pressed) <> 0 then BGet_Palet;
    MouseHide;
    CopyScr(virtualscr,visualscr);
    MouseShow;
    putbrush(5,5,color,visualscr);
    FRectangle(15, 1, 20, 6, BACKGR, visualscr);
    MouseGetPosition(MouseB, MouseX, MouseY);
    MouseX := MouseX div 2;
    LastB:=0;
    MouseB:=0;
    LastX:=MouseX; LastY:=MouseY;
    LineX:=MouseX; LineY:=MouseY;
  end;
  if ButtonClicked(271,176,'Exit') then Xit:=1;
  if ButtonClicked(301, 176, '??') then About;
  if ButtonClicked(271,140,'Load') then Load;
  if ButtonClicked(271,164,'S.as') then Save;
  if ButtonClicked(271,152,'Save') then
  begin
    if filename<>'' then begin
      MouseHide;
      CopyScr(visualscr,virtualscr);
      CopyScr(virtualscr,visualscr);
      GetAllPalette(Palette);
      WriteXY(250, 1, red, 'Busy...', visualscr);
      SaveAreaAsPCX(Filename,Palette,1,15, MaxX,200-16);
      CopyScr(virtualscr,visualscr);
      MouseShow;
    end else Save;
  end;
end;

begin
   randomize;
   Color:=black;
   BACKGR:=white;
   Xit:=0;
   action:=3;
   MaxX:=247; MaxY:=198;
   WriteLn('======== POWER PAINT 2.2 ========');
   WriteLn('Loading font...');
   LoadFont('default.fon');
   CurrentFont:='default.fon';
   WriteLn('Searching for mouse...');
   if MouseButtons < 1 then                     { Initialiseer mouse }
   begin                                        { Helaas... }
      WriteLn('No mouse Found!!!');
      Halt(2);
   end;
   SetVga;
   SetVirtual;
   Init;
   
   MouseX := 320;
   MouseY := 200 div 2;
   MouseB := 0;

   MouseSetWindow(1,15,320*2,200-1);{ Houd muis binnen kader }
   MouseSetPosition(MouseX, MouseY);      { Zet muis in het midden }
   MouseSetSensitivity(10, 10);
   Point;
   if paramcount>0 then
   begin
     Error:='';
     copyscr(visualscr,virtualscr);
     LocatePCX(ParamStr(1),Palette,1,15, MaxX,200-16);
     WriteXY(200, 1, red, Error, visualscr);
     if error<>'' then
     begin
       delay(1000);
       CopyScr(virtualscr,visualscr);
     end else Filename:=ParamStr(1);
   end else Filename:='';
   MouseShow;                                   { Laat cursor zien }
   repeat
      LastX := MouseX;                     { Onthoud de huidige     }
      LastY := MouseY;                     {   toestand van de muis }
      LastB := MouseB;

      MouseGetPosition(MouseB, MouseX, MouseY); { Vraag de nieuwe op }
      MouseX := MouseX div 2;
      if (LastX <> MouseX) or (LastY <> MouseY) or
         (LastB <> MouseB) then
      begin
         if ((MouseB and L_Pressed) <> 0) and (MouseX<250) and (Action<3) then
         begin
            MouseHide;
            if action=2 then
            begin
              if MouseX<LineX then MouseX:=lineX+1;
              if MouseY<LineY then MouseY:=lineY+1;
            end;
            if ((LastB and L_Pressed) <> 0) then
               if action=0 then
                 XorLine(LineX, LineY, LastX, LastY, visualscr)
               else if action=1 then
                 XorRectangle(LineX,LineY,LastX,LastY,visualscr)
               else if action=2 then
                 XorEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                            (LastX-LineX) div 2, (LastY-LineY) div 2, visualscr);
               if action=10 then
                 SelectedBox(LineX, LineY, LastX, LastY);
            if action=0 then
              XorLine(LineX, LineY, MouseX, MouseY, visualscr)
            else if action=1 then
              XorRectangle(LineX, LineY, MouseX, MouseY, visualscr)
            else if action=2 then
                 XorEllipse(LineX+((MouseX-LineX) div 2), LineY+((MouseY-LineY) div 2),
                            (MouseX-LineX) div 2, (MouseY-LineY) div 2, visualscr);
            MouseShow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (Action=10) and (not selected) and (MouseX<250) then
         begin
           MouseHide;
           Selected:=FALSE;
           SelectedBox(LineX, LineY, LastX, LastY);
           SelectedBox(LineX, LineY, MouseX, MouseY);
           MouseShow;
         end
         else if ((LastB and L_Pressed) <> 0) and (action<3) and (MouseX<250)then
         begin
            MouseHide;
            if action=0 then XorLine(LineX, LineY, LastX, LastY,visualscr);
            if action=1 then XorRectangle(LineX, LineY, LastX, LastY,visualscr);
            if action=2 then XorEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                                        (LastX-LineX) div 2, (LastY-LineY) div 2, visualscr);
            if action=0 then Line(LineX, LineY, MouseX, MouseY, Color, visualscr);
            if action=1 then Rectangle(LineX, LineY, MouseX, MouseY, Color, visualscr);
            if action=2 then Ellipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                                     (LastX-LineX) div 2, (LastY-LineY) div 2, Color, visualscr);
            Mouseshow;
         end else
         if ((LastB and L_Pressed) <> 0) and ((MouseB and L_Pressed) = 0) and (action=10)
             and (not selected) and (MouseX<250) then
         begin
            MouseHide;
            SelX1:=LineX; SelX2:=MouseX;
            SelY1:=LineY; SelY2:=MouseY;
            SelectedBox(SelX1, SelY1, SelX2, SelY2);
            GetImage(Selection, SelX1, SelY1, SelX2, SelY2, visualscr);
            Selected:=TRUE;
            SelectedBox(SelX1, SelY1, SelX2, SelY2);
            XorRectangle(MouseX, MouseY, MouseX+(SelX2-SelX1), MouseY+(SelY2-SelY1), visualscr);
            MouseSetPosition(LineX*2,LineY);
            MouseShow;
         end else
         if ((MouseB and R_Pressed) <> 0) and (MouseX<250) and (action < 3) then
         begin
            MouseHide;
            if (action=2) or (action=1) then
            begin
              if MouseX<LineX then MouseX:=lineX+1;
              if MouseY<LineY then MouseY:=lineY+1;
            end;
            if action=1 then XorRectangle(LineX, LineY, LastX, LastY, visualscr);
            if action=2 then XorEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                                        (LastX-LineX) div 2, (LastY-LineY) div 2, visualscr);
            if action=1 then XorRectangle(LineX, LineY, MouseX, MouseY, visualscr);
            if action=2 then XorEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                                        (LastX-LineX) div 2, (LastY-LineY) div 2, visualscr);
            MouseShow;
         end
         else if ((LastB and R_Pressed) <> 0) and (action < 3) and (MouseX<250) then
         begin
            MouseHide;
            if (action=2) or (action=2) then
            begin
              if MouseX<LineX then MouseX:=lineX+1;
              if MouseY<LineY then MouseY:=lineY+1;
            end;
            if action=1 then XorRectangle(LineX, LineY, LastX, LastY,visualscr);
            if action=2 then XorEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                                        (LastX-LineX) div 2, (LastY-LineY) div 2, visualscr);
            if action=1 then
            begin
              CopyScr(visualscr,virtualscr);
              WriteXY(250, 1, red, 'Busy...', visualscr);
              FRectangle(LineX, LineY, MouseX, MouseY, Color, virtualscr);
              CopyScr(virtualscr,visualscr);
            end;
            if action=2 then
            begin
              CopyScr(visualscr,virtualscr);
              WriteXY(250, 1, red, 'Busy...', visualscr);
              FEllipse(LineX+((LastX-LineX) div 2), LineY+((LastY-LineY) div 2),
                       (LastX-LineX) div 2, (LastY-LineY) div 2, Color, virtualscr);
              CopyScr(virtualscr,visualscr);
            end;
            Mouseshow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (action=3) and (MouseX<250) then
         begin
            MouseHide;
            XorLine(LineX, LineY, LastX, LastY,visualscr);
            if MouseX<255 then Line(LineX, LineY, MouseX, MouseY, Color, visualscr);
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (action=4) and (MouseX<250) then
         begin
            MouseHide;
            Line(LineX, LineY, MouseX, MouseY, BACKGR, visualscr);
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (action=5) and (MouseX<250) then
         begin
            MouseHide;
            FloodFill(MouseX, MouseY, Color);
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (action=6) and (MouseX<250) then
         begin
            MouseHide;
            WriteWin;
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else if (MouseB = 0) and (selected) and (action=10) and (MouseX<250) then
         begin
           MouseHide;
           XorRectangle(LastX, LastY, LastX+(SelX2-SelX1), LastY+(SelY2-SelY1), visualscr);
           XorRectangle(MouseX, MouseY, MouseX+(SelX2-SelX1), MouseY+(SelY2-SelY1), visualscr);
           MouseShow;
         end
         else if ((MouseB and L_Pressed) <> 0) and (selected) and (action=10) and (MouseX<250) then
         begin
            MouseHide;
            XorRectangle(MouseX, MouseY, MouseX+(SelX2-SelX1), MouseY+(SelY2-SelY1), visualscr);
            SelectedBox(SelX1, SelY1, SelX2, SelY2);
            PutImag(Selection, MouseX, MouseY, visualscr);
            Selected:=FALSE;
            KillImage(Selection);
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else if ((MouseB and R_Pressed) <> 0) and (selected) and (action=10) and (MouseX<250) then
         begin
            MouseHide;
            XorRectangle(MouseX, MouseY, MouseX+(SelX2-SelX1), MouseY+(SelY2-SelY1), visualscr);
            SelectedBox(SelX1, SelY1, SelX2, SelY2);
            FRectangle(SelX1, SelY1, SelX2, SelY2, BACKGR, visualscr);
            PutImag(Selection, MouseX, MouseY, visualscr);
            Selected:=FALSE;
            KillImage(Selection);
            LineX:=MouseX; LineY:=MouseY;
            MouseShow;
         end
         else
         begin
            LineX:=MouseX; LineY:=MouseY;
         end;
      end;
   IF KeyPressed THEN
   BEGIN
     Kar := ReadKey;
     if (kar>#47) and (kar<#56) then
     begin
       putbrush(5,5, black, visualscr);
       Currentshape:=ord(kar)-49;
       putbrush(5,5, color, visualscr);
     end;
     if kar='+' then
     begin
       if Color=255 then Color:=0 else Inc(Color);
       putbrush(5,5, color, visualscr);
     end;
     if kar='-' then
     begin
       if Color=0 then Color:=255 else Dec(Color);
       putbrush(5,5, color, visualscr);
     end;
     if kar='z' then
     begin
       zoom;
     end;
     if kar='s' then Save;
     if kar='l' then Load;
     if kar=#27 then Xit:=1;
     if kar=#0 then
     begin
       kar:=ReadKey;
       if kar=#59 then About;
       if kar=#60 then
       begin
         if filename<>'' then begin
           MouseHide;
           CopyScr(visualscr,virtualscr);
           CopyScr(virtualscr,visualscr);
           GetAllPalette(Palette);
           WriteXY(250, 1, red, 'Busy...', visualscr);
           SaveAreaAsPCX(Filename,Palette,1,15, MaxX,200-16);
           CopyScr(virtualscr,visualscr);
           MouseShow;
         end else Save;
       end;
       if kar=#61 then
	  load;
       if kar=#67 then
       begin
         MouseHide;
         Init;
         MouseShow;
       end;
       if kar=#66 then
         GetFont;
     end;
    END;
    CheckMouse;
   until Xit<>0;
   if VSave then
   begin
    if filename<>'' then begin
      MouseHide;
      GetAllPalette(Palette);
      WriteXY(250, 1, red, 'Busy...', visualscr);
      SaveAreaAsPCX(Filename,Palette,1,15, MaxX,200-16);
      CopyScr(virtualscr,visualscr);
      MouseShow;
    end else Save;
  end;
   ResetVirtual;
   MouseHide;
   ResetVga;
   WriteLn('*********************************************************************');
   WriteLn('*  COPYRIGHT (C) 1999 Z. Hemel and S. de Jong. ALL RIGHTS RESERVED. *');
   WriteLn('*  E-mail:    zef@zefnet.com     s.dejong@mailcity.com              *');
   WriteLn('*  Internet:  http://zefnet.com  http://zanderz.cjb.net             *');
   WriteLn('*********************************************************************');
end.