
unit Mouse;

{------------------------------------------------------------------}
{ File:    MOUSE.PAS                                               }
{ Functie: Interface tussen Turbo Pascal en Microsoft Mouse Driver }
{ Nodig:   ASMLIB (Deel 9, hoofdstuk 6.2)                          }
{ Versie:  Turbo Pascal versie 4                                   }
{ Auteur:  H.P. van Vliet                                          }
{ Gebruik: USE deze unit in uw programma. Roep alvorens de andere  }
{          procedures te gebruiken de funktie "MouseButtons" aan.  }
{          Doe dit ook als u niet geinteresseerd bent het aantal   }
{          buttons, want deze funktie initialiseert de mouse en    }
{          rapporteert of een mouse geinstalleerd is.              }
{          Toon de mouse cursor met de procedure "MouseShow", en   }
{          verberg hem met "MouseHide". Gebruik "MouseGetPosition" }
{          om de positie van de mouse en de toestand van de buttons}
{          op te vragen (zie voorbeeld TEKEN.PAS).                 }
{          U kunt ook een "eventhandler" installeren met procedure }
{          "MouseSetEventHandler" (zie tekst).                     }
{          Wanneer u in grafische mode werkt kunt u de vorm van de }
{          cursor instellen met procedure "MouseSetGraphicsCursor".}
{          Er zijn reeds acht cursorvormen gedefinieerd:           }
{           Standard   - Een pijl naar linksboven (default)        }
{           Check      - Een V-symbooltje                          }
{           Hand       - Een hand met uitgestoken wijsvinger       }
{           Cross      - Een X                                     }
{           CrossHair  - Een kruisdraad                            }
{           HourGlass  - Een zandloper                             }
{           UpperLeft  - Een linkerbovenhoek van een rechthoek     }
{           LowerRight - Een rechteronderhoek van een rechthoek    }
{------------------------------------------------------------------}

interface

uses
   Dos, AsmLib;

{-----------------------------------}
{ Symbolische namen voor de bits in }
{ de status- en masker-woorden.     }
{-----------------------------------}

const
   L_Pressed  = $01;
   R_Pressed  = $02;
   M_Pressed  = $04;
   L_Released = $08;
   R_Released = $10;
   M_Released = $20;
   MouseMoved = $40;

{----------------------------------------------------}
{ Een grafische cursor is van het type CursorShape.  }
{ Dit type bevat de volgende velden:                 }
{ ScreenMask : 16x16 bits die aangeven welk gedeelte }
{              van het scherm ongemoeid moet worden  }
{              gelaten.                              }
{ CursorMask : 16x16 bits die de vorm van de cursor  }
{              bepalen.                              }
{ Xhot, Yhot : Coordinaten van de "hotspot"; de plek }
{              die door de cursor wordt aangewezen.  }
{----------------------------------------------------}

type
   CursorShape = record
                    ScreenMask : array [0..15] of word;
                    CursorMask : array [0..15] of word;
                    Xhot, Yhot : integer;
                 end;

{-----------------------------------}
{ De acht voorgedefinieerde cursors }
{-----------------------------------}

const
   Standard : CursorShape =
     (ScreenMask : ($3FFF, $1FFF, $0FFF, $07FF, $03FF, $01FF, $00FF, $007F,
                    $003F, $001F, $01FF, $10FF, $30FF, $F87F, $F87F, $FC3F);
      CursorMask : ($0000, $4000, $6000, $7000, $7800, $7C00, $7E00, $7F00,
                    $7F80, $7FC0, $7C00, $4600, $0600, $0300, $0300, $0180);
      Xhot       : -1;
      Yhot       : -1);

   Check : CursorShape =
     (ScreenMask : ($FFF0, $FFE0, $FFC0, $FF81, $FF03, $0607, $000F, $001F,
                    $C03F, $F07F, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF);
      CursorMask : ($0000, $0006, $000C, $0018, $0030, $0060, $70C0, $1D80,
                    $0700, $0000, $0000, $0000, $0000, $0000, $0000, $0000);
      Xhot       : 6;
      Yhot       : 7);

   Hand : CursorShape =
     (ScreenMask : ($E1FF, $E1FF, $E1FF, $E1FF, $E1FF, $E000, $E000, $E000,
                    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000);
      CursorMask : ($0C00, $1200, $1200, $1200, $1200, $13B6, $1249, $1249,
                    $7249, $9001, $9001, $9001, $8001, $8001, $8001, $FFFF);
      Xhot       : 5;
      Yhot       : 0);

   Cross : CursorShape =
     (ScreenMask : ($07E0, $0180, $0000, $C003, $F00F, $C003, $0000, $0180,
                    $07E0, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF);
      CursorMask : ($0000, $700E, $1C38, $0660, $03C0, $0660, $1C38, $700E,
                    $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000);
      Xhot       : 7;
      Yhot       : 4);

   CrossHair : CursorShape =
     (ScreenMask : ($FC7F, $FC7F, $FC7F, $FC7F, $FC7F, $FC7F, $0101, $0381,
                    $0101, $FC7F, $FC7F, $FC7F, $FC7F, $FC7F, $FC7F, $FFFF);
      CursorMask : ($0000, $0100, $0100, $0100, $0100, $0100, $0000, $7C7C,
                    $0000, $0100, $0100, $0100, $0100, $0100, $0000, $0000);
      Xhot       : 7;
      Yhot       : 7);

   HourGlass : CursorShape =
     (ScreenMask : ($0000, $0000, $0000, $0000, $8001, $C003, $E007, $F00F,
                    $E007, $C003, $8001, $0000, $0000, $0000, $0000, $FFFF);
      CursorMask : ($0000, $7FFE, $6006, $300C, $1818, $0C30, $0660, $03C0,
                    $0660, $0C30, $1998, $33CC, $67E6, $7FFE, $0000, $0000);
      Xhot       : 7;
      Yhot       : 7);

   UpperLeft : CursorShape =
     (ScreenMask : ($0000, $0000, $0000, $0000, $0FFF, $0FFF, $0FFF, $0FFF,
                    $0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF, $0FFF);
      CursorMask : ($0000, $7FFE, $7FFE, $6000, $6000, $6000, $6000, $6000,
                    $6000, $6000, $6000, $6000, $6000, $6000, $6000, $0000);
      Xhot       : 1;
      Yhot       : 1);

   LowerRight : CursorShape =
     (ScreenMask : ($FFF0, $FFF0, $FFF0, $FFF0, $FFF0, $FFF0, $FFF0, $FFF0,
                    $FFF0, $FFF0, $FFF0, $FFF0, $0000, $0000, $0000, $0000);
      CursorMask : ($0000, $0006, $0006, $0006, $0006, $0006, $0006, $0006,
                    $0006, $0006, $0006, $0006, $0006, $7FFE, $7FFE, $0000);
      Xhot       : 14;
      Yhot       : 14);

   { Initialisatie }

function  MouseButtons : word;

   { Aan- en uitzetten van de cursor }

procedure MouseShow;
procedure MouseHide;
procedure MouseHideWindow(Xmin, Ymin, Xmax, Ymax : word);

   { Beperken van de bewegingsvrijheid van de muis }

procedure MouseSetWindow(Xmin, Ymin, Xmax, Ymax : word);

   { Opvragen/zetten van de status van de muis }

procedure MouseGetPosition(var Buttons, X, Y : word);
procedure MouseSetPosition(X, Y : word);
function  MouseGetCount(Button : word; var X, Y : word) : word;
procedure MouseGetMickeys(var X, Y : integer);

   { Selectie van cursortype en -vorm }

procedure MouseSetGraphicsCursor(Shape : CursorShape);
procedure MouseSetTextCursor(ScreenMask, CursorMask : word);
procedure MouseSetHardwareCursor(Start, Stop : word);

   { Installatie eventhandler procedure }

procedure MouseSetEventHandler(EventMask : word; Handler : pointer);

   { Instellen gevoeligheid }

procedure MouseSetSensitivity(Horizontal, Vertical : word);
procedure MouseSetThreshold(Speed : word);

{------------------------------------------------------------------------}

implementation

var
   Regs        : Registers;     { Processor registers voor INT 33h }
   MouseDriver : pointer;       { Adres mouse driver               }
   OldExitProc : pointer;       { Adres vorige exit procedure      }

function
   MouseButtons : word;

   { Initialiseert de mousedriver, en retourneert het aantal buttons }
   { op de mouse. Wanneer geen mousedriver is geinstalleerd wordt 0  }
   { geretourneerd.                                                  }

   begin
      Regs.AX := 0;                       { FC = 0: Reset driver }
      Regs.BX := 0;
      Intr($33, Regs);

      if Regs.AX = $FFFF then                { Mouse is aanwezig }
         MouseButtons := Regs.BX
      else                                   { Mouse niet geinstalleerd }
         MouseButtons := 0;

      Regs.AX := 13;                      { FC = 13: Light pen emulation off }
      Intr($33, Regs);
   end;

procedure
   MouseShow;

   { Verhoogt de cursorvlag met 1, en toont de cursor wanneer }
   { het resultaat 0 is. De cursorvlag kan nooit groter dan 0 }
   { worden.                                                  }

   begin
      Regs.AX := 1;                       { FC = 1: Show cursor }
      Intr($33, Regs);
   end;

procedure
   MouseHide;

   { Verlaagt de cursorvlag met 1, en verbergt de cursor.   }
   { NB. Wanneer deze procedure 2 maal achter elkaar wordt  }
   {     aangeroepen, moet MouseShow ook twee maal worden   }
   {     aangeroepen om de cursor weer te tonen (de cursor- }
   {     vlag is dan immers -2 geworden).                   }

   begin
      Regs.AX := 2;                       { FC = 2: Hide cursor }
      Intr($33, Regs);
   end;

procedure
   MouseHideWindow(Xmin, Ymin, Xmax, Ymax : word);

   { Verlaagt de cursorvlag met 1, en verbergt de cursor indien }
   { de cursor binnen het opgegeven window valt (of zodra de    }
   { cursor erbinnen komt).                                     }

   begin
      Regs.AX := 16;                      { FC = 16: Conditional off }
      Regs.CX := Xmin;
      Regs.DX := Ymin;
      Regs.SI := Xmax;
      Regs.DI := Ymax;
      Intr($33, Regs);
   end;

procedure
   MouseSetWindow(Xmin, Ymin, Xmax, Ymax : word);

   { Beperkt de beweging van de mouse tot het opgegeven window.  }
   { Wanneer de cursor buiten het window staat wordt deze er-    }
   { binnen geplaatst. Wanneer Xmin > Xmax of Ymin > Ymax worden }
   { deze coordinaten automatisch verwisseld.                    }

   begin
      Regs.AX := 7;                       { FC = 7: Set horizontal range }
      Regs.CX := Xmin;
      Regs.DX := Xmax;
      Intr($33, Regs);

      Regs.AX := 8;                       { FC = 8: Set vertical range }
      Regs.CX := Ymin;
      Regs.DX := Ymax;
      Intr($33, Regs);
   end;

procedure
   MouseGetPosition(var Buttons, X, Y : word);

   { Vraagt de huidige positie van de cursor en de toestand van }
   { de buttons op. De toestand van de buttons wordt aangegeven }
   { door de bits L_Pressed, R_Pressed en M_Pressed.            }

   begin
      Regs.AX := 3;                       { FC = 3: Get position & buttons }
      Intr($33, Regs);

      Buttons := Regs.BX;
      X := Regs.CX;
      Y := Regs.DX;
   end;

procedure
   MouseSetPosition(X, Y : word);

   { Verplaatst de mouse cursor naar de opgegeven coordinaten.   }
   { Gebruik deze procedure uiterst spaarzaam, want de gebruiker }
   { verplaatst de cursor liever zelf!                           }

   begin
      Regs.AX := 4;                       { FC = 4: Set position }
      Regs.CX := X;
      Regs.DX := Y;
      Intr($33, Regs);
   end;

function
   MouseGetCount(Button : word; var X, Y : word) : word;

   { Retourneert het aantal keren dat de in "Button" opgegeven }
   { button werd ingedrukt/losgelaten sinds de laatste aanroep }
   { van deze funktie. Tevens wordt in "X" en "Y" verteld op   }
   { welke positie de button het laatst werd ingedrukt/losge-  }
   { laten. Met de parameter "Button" wordt de gewenste info   }
   { gespecificeerd:                                           }
   { L_Pressed  = aantal keren linker    button ingedrukt      }
   { M_Released = aantal keren middelste button losgelaten     }
   {     etc.                                                  }

   const
      ButCode : array [L_Pressed..M_Pressed] of shortint =
                (0, 1, -1, 2);

   begin
      if Button < L_Released then
      begin
         Regs.AX := 5;                    { FC = 5: Get press info }
         Regs.BX := ButCode[Button];
      end
      else
      begin
         Regs.AX := 6;                    { FC = 6: Get release info }
         Regs.BX := ButCode[Button shr 3];
      end;

      Intr($33, Regs);

      MouseGetCount := Regs.BX;
      X := Regs.CX;
      Y := Regs.DX;
   end;

procedure
   MouseGetMickeys(var X, Y : integer);

   { Vraagt de relatieve verplaatsing (in mickeys) op ten   }
   { opzichte van de vorige aanroep van deze procedure.     }
   { NB. Deze procedure behoeft in normale programma's niet }
   {     gebruikt te worden en is alleen voor de volledig-  }
   {     heid in deze unit opgenomen.                       }

   begin
      Regs.AX := 11;                      { FC = 11: Read mickey counters }
      Intr($33, Regs);
      X := Regs.CX;
      Y := Regs.DX;
   end;

procedure
   MouseSetGraphicsCursor(Shape : CursorShape);

   { Geeft de te gebruiken grafische cursor door aan de }
   { mouse-driver. De cursor wordt alleen getoond als   }
   { de cursorvlag 0 is (zie "MouseShow" en "MouseHide")}

   begin
      Regs.AX := 9;                       { FC = 9: Set graphics cursor }
      Regs.BX := Shape.Xhot;
      Regs.CX := Shape.Yhot;
      Regs.DX := Ofs(Shape);
      Regs.ES := Seg(Shape);
      Intr($33, Regs);
   end;

procedure
   MouseSetTextCursor(ScreenMask, CursorMask : word);

   { Stelt de mousedriver in op een software tekst-cursor }
   { en geeft de aard van die cursor door. Meestal wordt  }
   { een inverterend blok gebruikt (ScreenMask=$77FF,     }
   { CursorMask=$7700).                                   }

   begin
      Regs.AX := 10;                      { FC = 10: Set text cursor }
      Regs.BX := 0;                       { Subfunction 0: software cursor }
      Regs.CX := ScreenMask;
      Regs.DX := CursorMask;
      Intr($33, Regs);
   end;

procedure
   MouseSetHardwareCursor(Start, Stop : word);

   { Stelt de mousedriver in op de hardware tekst-cursor }
   { en geeft de grootte van die cursor door. Een knip-  }
   { perend blok ontstaat met Start=0, Stop=31.          }

   begin
      Regs.AX := 10;                      { FC = 10: Set text cursor }
      Regs.BX := 1;                       { Subfunction 1: hardware cursor }
      Regs.CX := Start;
      Regs.DX := Stop;
      Intr($33, Regs);
   end;

{$F+}
procedure
   UserHandler(Event, Buttons, X, Y : word);

   { Hulpprocedure ten behoeve van eventhandlers. Deze  }
   { procedure wordt nooit echt aangeroepen, maar wordt }
   { met Proc_Redirect gebruikt om een procedure in de  }
   { applikatie aan te roepen.                          }

   begin
   end;
{$F-}

procedure
   MouseEventHandler(AX, BX, CX, DX, SI, DI, DS, ES, BP : word);

   interrupt;

   { Deze procedure wordt door de mouse-driver aangeroepen }
   { wanneer er een geselecteerd mouse-event optreed. De   }
   { aanroep gebeurt met een FAR CALL, maar de parameters  }
   { (positie v.d. mouse, aard v.h. event) worden in de    }
   { registers AX t/m DI doorgegeven. Bovendien wijst DS   }
   { naar het datasegment van de mousedriver. Daarom is    }
   { deze procedure als interrupt-procedure uitgevoerd.    }
   { Aan het einde van de procedure moeten we echter een   }
   { RETF uitvoeren i.p.v. een IRET!                       }
   { De codering van de events die door de mousedriver     }
   { wordt gehanteerd is niet consequent. Daarom vertalen  }
   { we de eventcode (in AX) naar onze eigen code.         }

   var
      Event : word;

   begin
      Event := 0;

      {------------------------------------}
      { Vertaal de event-code bit-voor-bit }
      {------------------------------------}

      if (AX and 1) <> 0 then
         Inc(Event, MouseMoved);
      if (AX and 2) <> 0 then
         Inc(Event, L_Pressed);
      if (AX and 4) <> 0 then
         Inc(Event, L_Released);
      if (AX and 8) <> 0 then
         Inc(Event, R_Pressed);
      if (AX and 16) <> 0 then
         Inc(Event, R_Released);
      if (AX and 32) <> 0 then
         Inc(Event, M_Pressed);
      if (AX and 64) <> 0 then
         Inc(Event, M_Released);

      {---------------------------------------------}
      { Roep de eventhandler van de applikatie aan. }
      {---------------------------------------------}

      UserHandler(Event, BX, CX, DX);

      {---------------------------------------------}
      { Keer terug naar de mousedriver met een RETF }
      {---------------------------------------------}

      inline($89/$EC/       { MOV   SP,BP }
             $5D/           { POP   BP    }
             $07/           { POP   ES    }
             $1F/           { POP   DS    }
             $5F/           { POP   DI    }
             $5E/           { POP   SI    }
             $5A/           { POP   DX    }
             $59/           { POP   CX    }
             $5B/           { POP   BX    }
             $58/           { POP   AX    }
             $CB);          { RETF        }
   end;

procedure
   MouseSetEventHandler(EventMask : word; Handler : pointer);

   { Met deze procedure kan een procedure in de applikatie }
   { worden aangewezen die moet worden aangeroepen wanneer }
   { er iets aan de toestand van de mouse verandert. Met   }
   { de parameter "EventMask" wordt aangegeven in welke    }
   { gebeurtenissen we geinteresseerd zijn:                }
   { L_Pressed   - Het indrukken van de linker    button   }
   { L_Released  - Het loslaten  van de linker    button   }
   { R_Pressed   - Het indrukken van de rechter   button   }
   { R_Released  - Het loslaten  van de rechter   button   }
   { M_Pressed   - Het indrukken van de middelste button   }
   { M_Released  - Het loslaten  van de middelste button   }
   { MouseMoved  - Beweging van de mouse                   }
   { De parameter "Handler" is een pointer naar een pro-   }
   { cedure die vier parameters van het type word verwacht:}
   {                                                       }
   {   procedure Handler(Event, Buttons, X, Y : word);     }
   {                                                       }
   { Deze procedure wordt bij de gewenste gebeurtenis(sen) }
   { aangeroepen. Parameter "Event" geeft aan welke ge-    }
   { beurtenis optrad (zelfde codering als "EventMask"),   }
   { "Buttons" geeft de toestand van de buttons, en "X" en }
   { "Y" geven de coordinaten van de mouse.                }
   { NB. Procedure "Handler" moet met het far calling model}
   {     gecompileerd zijn ( (*F+*) directive ).           }

   begin
      Regs.AX := 12;                      { FC = 12: Set subroutine }
      Regs.CX := 0;

      {-----------------------------------}
      { Vertaal de codering van de events }
      {-----------------------------------}

      if (EventMask and MouseMoved) <> 0 then
         Inc(Regs.CX, 1);
      if (EventMask and L_Pressed) <> 0 then
         Inc(Regs.CX, 2);
      if (EventMask and L_Released) <> 0 then
         Inc(Regs.CX, 4);
      if (EventMask and R_Pressed) <> 0 then
         Inc(Regs.CX, 8);
      if (EventMask and R_Released) <> 0 then
         Inc(Regs.CX, 16);
      if (EventMask and M_Pressed) <> 0 then
         Inc(Regs.CX, 32);
      if (EventMask and M_Released) <> 0 then
         Inc(Regs.CX, 64);

      {--------------------------------------------------}
      { Installeer "MouseEventHandler" als eventhandler. }
      {--------------------------------------------------}

      Regs.DX := Ofs(MouseEventHandler);
      Regs.ES := Seg(MouseEventHandler);
      Intr($33, Regs);

      {--------------------------------------------------}
      { Zorg dat "MouseEventHandler" de in "Handler" op- }
      { gegeven procedure aanroept in plaats van de pro- }
      { cedure "UserHandler".                            }
      {--------------------------------------------------}

      Proc_Redirect(@UserHandler, Handler);
   end;

procedure
   MouseSetSensitivity(Horizontal, Vertical : word);

   { Stel de horizontale en verticale gevoeligheid van de   }
   { mouse in in eenheden van mickeys per 8 pixels. De      }
   { default gevoeligheid is 8 horizontaal en 16 verticaal. }
   { Hoe kleiner de waarden, hoe gevoeliger de mouse.       }

   begin
      Regs.AX := 15;                      { FC = 15: Set mickey/pixel ratio }
      Regs.CX := Horizontal;
      Regs.DX := Vertical;
      Intr($33, Regs);
   end;

procedure
   MouseSetThreshold(Speed : word);

   { Stelt de "dubbele-snelheid drempel" in. Dit is de  }
   { snelheid (in mickeys per seconde) waarbij de mouse }
   { ineens twee maal zo gevoelig wordt.                }

   begin
      Regs.AX := 19;                      { FC = 19: Set double speed thresh }
      Regs.DX := Speed;
      Intr($33, Regs);
   end;

procedure
   DummyDriver;

   interrupt;

   { Deze dummy mousedriver wordt geinstalleerd wanneer er geen }
   { echte mousedriver in het systeem aanwezig is.              }

   begin
      { Doe niets }
   end;

{$F+}
procedure
   MouseExitProc;

   { Deze exit-procedure reset de mousedriver (zodat geen   }
   { eventhandler meer wordt aangeroepen), en deinstalleert }
   { eventueel de dummy mousedriver.                        }

   begin
      Regs.AX := 0;                   { FC = 0: Reset driver }
      Intr($33, Regs);

      if MouseDriver = nil then
         SetIntVec($33, nil);         { Ontkoppel dummy driver }

      ExitProc := OldExitProc;
   end;
{$F-}

begin
   {---------------------------------------------------------}
   { Initialisatie van de unit. Kijk of er een mouse driver  }
   { aanwezig is. Is dit niet het geval, installeer dan een  }
   { dummy driver. Op die manier behoeven we niet in iedere  }
   { procedure te testen of een mousedriver bestaat alvorens }
   { INT 33h uit te voeren. We zouden van de dummy driver    }
   { ook een mouse-emulator kunnen maken.                    }
   {---------------------------------------------------------}

   GetIntVec($33, MouseDriver);
   if MouseDriver = nil then
      SetIntVec($33, @DummyDriver);

   {-------------------------------------------------------}
   { Installeer een exit-procedure om de rommel achter ons }
   { op te ruimen.                                         }
   {-------------------------------------------------------}

   OldExitProc := ExitProc;
   ExitProc := @MouseExitProc;
end.