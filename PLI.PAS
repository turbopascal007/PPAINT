UNIT PLI;

INTERFACE

uses Vga;

procedure PLI_CreateNew(fil: string);
procedure PLI_Add(fil: string;cx,cy: integer;source: word);
procedure PLI_Load(fil: string;wich: integer;cx,cy: integer;dest: word);
procedure PLI_Play(fil: string; cx,cy,d: integer);

IMPLEMENTATION

uses Crt, Dos;

var F: file;
    PError: string;

procedure PLI_CreateNew(fil: string);
begin
  Assign(F, fil);
  Rewrite(F);
  Close(F);
end;

procedure PLI_Add(fil: string;cx,cy: integer;source: word);
var x,y: integer;
    writb: byte;
begin
  Assign(F, fil);
  {$I-} Reset(F,1); {$I+}
  if IOResult<>0 then
  begin
    PError:='File not found: '+fil;
    Exit;
  end;
  Seek(F, Filesize(F));
  for y:=15 to 199 do
    BlockWrite(F, Mem[source:(y+cy-15)*320+cx], 249);
  Close(F);
end;

procedure PLI_Load(fil: string;wich: integer;cx,cy: integer;dest: word);
var
    x,y:word;

begin
  Assign(F, fil);
  {$I-} Reset(F,1); {$I+}
  if IOResult<>0 then
  begin
    PError:='File not found: '+fil;
    Exit;
  end;
  Seek(F, (wich-1)*46065);
  for y:=15 to 199 do
    BlockRead(F, Mem[dest:(y+cy-15)*320+cx], 249);
  Close(F);
end;

procedure PLI_Play(fil: string; cx,cy,d: integer);
var count, size: integer;
begin
  Assign(F, fil);
  {$I-} Reset(F,1); {$I+}
  if IOResult <> 0 then
  begin
    PError:='File not found: '+fil;
    Exit;
  end;
  size:=FileSize(F) div 46065;
  Close(F);

  cls(0, virtualscr);
  for count:= 1 to size do
  begin
    PLI_Load(fil, count, cx, cy, virtualscr);
    CopyScr(virtualscr, visualscr);
    delay(d);
  end;
end;

end.