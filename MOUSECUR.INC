PROCEDURE CIR;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$00FF,$007F,$00FF,$11C7,
   $3B83,$7F39,$FE7C,$FE7C,$FE7C,$FF39,$FF83,$FFC7,
   $FFE0,$8040,$8080,$8100,$8300,$8080,$9100,$AA38,
   $C444,$8082,$0101,$0101,$0101,$0082,$0044,$0038);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;


PROCEDURE LIN;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$00FF,$007F,$00FF,$11BF,
   $3B1F,$7F0F,$FF87,$FFC3,$FFE1,$FFF0,$FFF8,$FFFC,
   $FFE0,$8040,$8080,$8100,$8300,$8080,$9100,$AA40,
   $C4A0,$8090,$0048,$0024,$0012,$0009,$0005,$0003);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;


PROCEDURE POINT;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$00FF,$007F,$00FF,$11FF,
   $3BFF,$7FFF,$FFCF,$FF87,$FF87,$FFCF,$FFFF,$FFFF,
   $FFE0,$8040,$8080,$8100,$8300,$8080,$9100,$AA00,
   $C400,$8000,$0030,$0048,$0048,$0030,$0000,$0000);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;


PROCEDURE RECT;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$00FF,$007F,$00FF,$11FF,
   $3A01,$7E01,$FE79,$FE79,$FE79,$FE79,$FE01,$FE01,
   $FFE0,$8040,$8080,$8100,$8300,$8080,$9100,$AA00,
   $C5FE,$8102,$0102,$0102,$0102,$0102,$0102,$01FE);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;

PROCEDURE STANDARD;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$00FF,$007F,$00FF,$11FF,
   $3BFF,$7FFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,
   $FFE0,$8040,$8080,$8100,$8300,$8080,$9100,$AA00,
   $C400,$8000,$0000,$0000,$0000,$0000,$0000,$0000);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;

PROCEDURE ERASE;

Const
  Shape :array[0..31] of Word =

  ($001F,$003F,$007F,$00FF,$01FF,$00FF,$01FF,$0B01,
   $1F01,$3F01,$7F03,$FF03,$FF03,$FF01,$FF01,$FF01,
   $FFE0,$8040,$8080,$8100,$8200,$8100,$8A00,$94FE,
   $A082,$C0BE,$80BC,$0084,$00BC,$00BE,$0082,$00FE);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;

PROCEDURE FILL;

Const
  Shape :array[0..31] of Word =

  ($003F,$007F,$00FF,$01FF,$00FF,$01FF,$03FF,$1701,
   $3F01,$7F01,$FF03,$FF03,$FF03,$FF1F,$FF1F,$FF1F,
   $FFC0,$8080,$8100,$8200,$8100,$8200,$9400,$A8FE,
   $C082,$80BE,$00BC,$0084,$00BC,$00A0,$00A0,$00E0);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;

PROCEDURE TEXT;

Const
  Shape :array[0..31] of Word =

  ($001F,$001F,$003F,$007F,$00FF,$007F,$00FF,$01FF,
   $0A00,$1E00,$3E00,$7E44,$FFC7,$FFC7,$FFC7,$FFC7,
   $FFE0,$8020,$8040,$8080,$8100,$8080,$8100,$8A00,
   $95FF,$A101,$C16D,$81AB,$0028,$0028,$0028,$0038);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;

PROCEDURE SELECT;

Const
  Shape :array[0..31] of Word =

  ($003F,$007F,$00FF,$01FF,$00FF,$01FF,$03FF,$17FF,
   $3E01,$7EFD,$FEFD,$FEFD,$FEFD,$FEFD,$FE01,$FFFF,
   $FFC0,$8080,$8100,$8200,$8100,$8200,$9400,$A800,
   $C14A,$8102,$0000,$0000,$0102,$0000,$0126,$0000);

Var
  reg :registers;

Begin
  Reg.AX := 9 ;
  Reg.BX := 0 ;
  Reg.CX := 0 ;
  Reg.ES := SEG(Shape[0]);
  Reg.DX := OFS(Shape[0]);
  Intr($33,Reg);
End;
