{ Compatibility shim for TurboPower's TpWindow unit.

  Собственный теневой буфер экрана 80x25 хранит в каждой ячейке не байт,
  а "глиф" (1-4 байта - обычный ASCII-символ либо целая UTF-8
  последовательность, например, кириллическая буква). Это принципиально,
  потому что словарные файлы и русский интерфейс содержат многобайтовые
  символы: собственный буфер Crt (ConsoleBuf) считает НЕ символы, а байты,
  и при появлении многобайтовых символов "съезжает" по колонкам - окно,
  открытое поверх такого текста, при закрытии восстановило бы экран со
  сдвигом. Все процедуры рисования (PutGlyph и то, что на нём построено
  в TpCrt) обязаны идти через этот буфер, а не напрямую через Crt.Write. }
unit TpWindow;

{$mode tp}
{$H-}

interface

uses
  Crt
  {$IFDEF UNIX}, BaseUnix{$ENDIF}
  {$IFDEF WINDOWS}, Windows{$ENDIF};

const
  ScreenW = 80;
  ScreenH = 25;

type
  FrameArray = array[1..6] of Char;

const
  NoFrame: FrameArray = '      ';
  ShadowAttr = 8; { чёрный фон, тёмно-серый "символ" тени }

type
  TCell = record
    Glyph: String[4];
    Attr: Byte;
  end;

  PWindowRec = ^TWindowRec;
  TWindowRec = record
    X1, Y1, X2, Y2: Integer;
    HasFrame, HasShadow: Boolean;
    SX1, SY1, SX2, SY2: Integer; { границы снимка, включая тень }
    Saved: array of TCell;
    SavedW: Integer;
    { Window(), активный в момент открытия этого окна - EraseTopWindow
      восстанавливает именно его, а не "интерьер того, что осталось ниже
      в стеке": это важно, потому что вызывающий код мог сам явно
      выставить Window(1,1,80,25) перед открытием временного окна (как
      делает MakeMainWindow), и после закрытия этого временного окна
      нужно вернуться туда, куда рассчитывал вызывающий код, а не туда,
      куда "по стеку" получилось бы само по себе. }
    PrevMinX, PrevMinY, PrevMaxX, PrevMaxY: Integer;
  end;
  WindowPtr = PWindowRec;

var
  FrameChars: FrameArray;
  SoundFlagW: Boolean;

{ Длина в байтах "визуального символа", начинающегося в S на позиции Pos:
  1 для ASCII, 2-4 для UTF-8 последовательности. }
function GlyphLen(const S: String; Pos: Integer): Integer;

{ Количество визуальных символов (колонок) в S: для строк со словарными
  переводами это НЕ то же самое, что Length(S), т.к. после перекодировки
  из CP866 кириллица занимает 2 байта на 1 колонку - расчёты центрирования
  текста (SetMidle/Midle), написанные в оригинале для однобайтовой кодовой
  страницы, должны использовать именно эту функцию, а не Length(). }
function VisLen(const S: String): Integer;

{ Абсолютное позиционирование курсора, в обход "экономных" относительных
  прыжков Crt.GotoXY (см. подробности у TpCrt.GotoXY). }
procedure RawGotoXY(X, Y: Integer);

{ Записать один визуальный символ Glyph в абсолютную позицию (X,Y) экрана
  и в теневой буфер, атрибутом Attr. }
procedure PutGlyph(X, Y: Integer; const Glyph: String; Attr: Byte);
function GetGlyph(X, Y: Integer): TCell;

procedure MakeWindow(var W: WindowPtr; X1, Y1, X2, Y2: Integer;
  HasFrame, HasShadow, Reserved: Boolean;
  WinAttr, FrameAttr, HeaderAttr: Byte;
  const Header: String);
function DisplayWindow(W: WindowPtr): Boolean;
function EraseTopWindow: WindowPtr;
procedure DisposeWindow(W: WindowPtr);

{ Текущая "высота" стека открытых окон и принудительное закрытие всех
  окон вплоть до ранее сохранённой высоты. Используется там, где число
  окон, реально открытых на разных путях выполнения (Esc/ошибки/успех),
  трудно держать синхронизированным вручную - надёжнее закрыть "всё лишнее
  сверх того, что было до начала операции", чем считать вызовы по одному. }
function WindowStackDepth: Integer;
procedure EraseWindowsDownTo(Depth: Integer);

implementation

var
  Shadow: array[1..ScreenH, 1..ScreenW] of TCell;
  WinStack: array[1..64] of WindowPtr;
  WinStackTop: Integer;

function GlyphLen(const S: String; Pos: Integer): Integer;
var
  b: Byte;
  L: Integer;
begin
  if (Pos < 1) or (Pos > Length(S)) then
  begin
    GlyphLen := 0;
    Exit;
  end;
  b := Ord(S[Pos]);
  if b < $80 then L := 1
  else if (b and $E0) = $C0 then L := 2
  else if (b and $F0) = $E0 then L := 3
  else if (b and $F8) = $F0 then L := 4
  else L := 1;
  if Pos + L - 1 > Length(S) then L := Length(S) - Pos + 1;
  GlyphLen := L;
end;

function VisLen(const S: String): Integer;
var
  Pos, Cnt, GLen: Integer;
begin
  Pos := 1;
  Cnt := 0;
  while Pos <= Length(S) do
  begin
    GLen := GlyphLen(S, Pos);
    if GLen = 0 then Break;
    Inc(Pos, GLen);
    Inc(Cnt);
  end;
  VisLen := Cnt;
end;

{ Пишем напрямую в файловый дескриптор 1, в обход Crt.Write. Crt.Write
  считает каждый переданный байт "символом" для своей внутренней логики
  переноса по границе окна - переданная ему длинная escape-последовательность
  позиционирования выглядела бы как длинная строка текста и могла бы
  спровоцировать нежелательный перенos/прокрутку. Управляющие
  последовательности (позиционирование курсора, цвет) должны быть Crt
  вообще не видны. }
{$IFDEF WINDOWS}
var
  StdOutHandle: THandle;
{$ENDIF}

procedure RawWrite(const S: String);
{$IFDEF WINDOWS}
var
  Written: DWORD;
{$ENDIF}
begin
  if Length(S) = 0 then Exit;
  {$IFDEF UNIX}
  FpWrite(1, S[1], Length(S));
  {$ENDIF}
  {$IFDEF WINDOWS}
  WriteFile(StdOutHandle, S[1], Length(S), Written, nil);
  {$ENDIF}
end;

{ Crt.GotoXY иногда посылает не полную абсолютную последовательность
  позиционирования, а короткую относительную (например, "на 1 влево"),
  опираясь на собственное представление о текущей позиции курсора. Это
  представление сбивается, как только через Crt.Write проходит
  многобайтовый UTF-8 символ (Crt считает байты, а не колонки), и после
  этого относительные прыжки Crt начинают промахиваться. Чтобы рисование
  окон и текста было надёжным независимо от того, что перед этим писалось
  на экран, позиционируем курсор напрямую абсолютной ANSI CUP
  последовательностью, в обход Crt.GotoXY и Crt.Write целиком. }
procedure RawGotoXY(X, Y: Integer);
var
  xs, ys: String;
begin
  Str(Y, ys);
  Str(X, xs);
  RawWrite(#27'[' + ys + ';' + xs + 'H');
end;

function AttrToSGR(Attr: Byte): String;
const
  AnsiTbl: array[0..7] of Char = ('0', '4', '2', '6', '1', '5', '3', '7');
var
  Fg, Bg: Byte;
  S: String;
begin
  Fg := Attr and $0F;
  Bg := (Attr shr 4) and $0F;
  S := #27'[0';
  if Fg > 7 then S := S + ';1';
  if (Bg and 8) <> 0 then S := S + ';5';
  S := S + ';3' + AnsiTbl[Fg and 7];
  S := S + ';4' + AnsiTbl[Bg and 7];
  S := S + 'm';
  AttrToSGR := S;
end;

procedure PutGlyph(X, Y: Integer; const Glyph: String; Attr: Byte);
begin
  if (X < 1) or (X > ScreenW) or (Y < 1) or (Y > ScreenH) then Exit;
  Shadow[Y, X].Glyph := Glyph;
  Shadow[Y, X].Attr := Attr;
  RawGotoXY(X, Y);
  RawWrite(AttrToSGR(Attr));
  RawWrite(Glyph);
end;

function GetGlyph(X, Y: Integer): TCell;
begin
  if (X < 1) or (X > ScreenW) or (Y < 1) or (Y > ScreenH) then
  begin
    GetGlyph.Glyph := ' ';
    GetGlyph.Attr := 0;
    Exit;
  end;
  GetGlyph := Shadow[Y, X];
end;

procedure FillAbs(X1, Y1, X2, Y2: Integer; const Ch: String; Attr: Byte);
var
  X, Y: Integer;
begin
  for Y := Y1 to Y2 do
    for X := X1 to X2 do
      PutGlyph(X, Y, Ch, Attr);
end;

procedure SetActiveWindow(W: WindowPtr);
begin
  if (W <> nil) and W^.HasFrame then
    Window(W^.X1 + 1, W^.Y1 + 1, W^.X2 - 1, W^.Y2 - 1)
  else if W <> nil then
    Window(W^.X1, W^.Y1, W^.X2, W^.Y2)
  else
    Window(1, 1, ScreenW, ScreenH);
end;

procedure MakeWindow(var W: WindowPtr; X1, Y1, X2, Y2: Integer;
  HasFrame, HasShadow, Reserved: Boolean;
  WinAttr, FrameAttr, HeaderAttr: Byte;
  const Header: String);
var
  SX1, SY1, SX2, SY2: Integer;
  X, Y, i, HeaderX, Col, GLen: Integer;
begin
  New(W);
  W^.X1 := X1; W^.Y1 := Y1; W^.X2 := X2; W^.Y2 := Y2;
  W^.HasFrame := HasFrame;
  W^.HasShadow := HasShadow;
  W^.PrevMinX := WindMinX; W^.PrevMinY := WindMinY;
  W^.PrevMaxX := WindMaxX; W^.PrevMaxY := WindMaxY;

  SX1 := X1; SY1 := Y1; SX2 := X2; SY2 := Y2;
  if HasShadow then
  begin
    if SX2 + 2 <= ScreenW then SX2 := SX2 + 2 else SX2 := ScreenW;
    if SY2 + 1 <= ScreenH then SY2 := SY2 + 1 else SY2 := ScreenH;
  end;
  W^.SX1 := SX1; W^.SY1 := SY1; W^.SX2 := SX2; W^.SY2 := SY2;
  W^.SavedW := SX2 - SX1 + 1;
  SetLength(W^.Saved, (SX2 - SX1 + 1) * (SY2 - SY1 + 1));

  for Y := SY1 to SY2 do
    for X := SX1 to SX2 do
      W^.Saved[(Y - SY1) * W^.SavedW + (X - SX1)] := GetGlyph(X, Y);

  Window(1, 1, ScreenW, ScreenH);

  if HasShadow then
  begin
    for Y := Y1 + 1 to Y2 + 1 do
      if Y <= ScreenH then
        for X := X2 + 1 to X2 + 2 do
          if X <= ScreenW then
            PutGlyph(X, Y, ' ', ShadowAttr);
    if Y2 + 1 <= ScreenH then
      for X := X1 + 2 to X2 + 2 do
        if X <= ScreenW then
          PutGlyph(X, Y2 + 1, ' ', ShadowAttr);
  end;

  if HasFrame then
    FillAbs(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, ' ', WinAttr)
  else
    FillAbs(X1, Y1, X2, Y2, ' ', WinAttr);

  if HasFrame then
  begin
    PutGlyph(X1, Y1, FrameChars[1], FrameAttr);
    PutGlyph(X2, Y1, FrameChars[3], FrameAttr);
    PutGlyph(X1, Y2, FrameChars[2], FrameAttr);
    PutGlyph(X2, Y2, FrameChars[4], FrameAttr);
    for X := X1 + 1 to X2 - 1 do
    begin
      PutGlyph(X, Y1, FrameChars[5], FrameAttr);
      PutGlyph(X, Y2, FrameChars[5], FrameAttr);
    end;
    for Y := Y1 + 1 to Y2 - 1 do
    begin
      PutGlyph(X1, Y, FrameChars[6], FrameAttr);
      PutGlyph(X2, Y, FrameChars[6], FrameAttr);
    end;
    if Header <> '' then
    begin
      HeaderX := X1 + ((X2 - X1 + 1) - VisLen(Header)) div 2;
      if HeaderX < X1 + 1 then HeaderX := X1 + 1;
      i := 1;
      Col := 0;
      while i <= Length(Header) do
      begin
        GLen := GlyphLen(Header, i);
        if GLen = 0 then Break;
        if HeaderX + Col < X2 then
          PutGlyph(HeaderX + Col, Y1, Copy(Header, i, GLen), HeaderAttr);
        Inc(i, GLen);
        Inc(Col);
      end;
    end;
  end;
end;

function DisplayWindow(W: WindowPtr): Boolean;
begin
  if W = nil then
  begin
    DisplayWindow := False;
    Exit;
  end;
  Inc(WinStackTop);
  WinStack[WinStackTop] := W;
  SetActiveWindow(W);
  DisplayWindow := True;
end;

function EraseTopWindow: WindowPtr;
var
  W: WindowPtr;
  X, Y: Integer;
  Cell: TCell;
begin
  if WinStackTop = 0 then
  begin
    EraseTopWindow := nil;
    Exit;
  end;
  W := WinStack[WinStackTop];
  Dec(WinStackTop);
  Window(1, 1, ScreenW, ScreenH);
  for Y := W^.SY1 to W^.SY2 do
    for X := W^.SX1 to W^.SX2 do
    begin
      Cell := W^.Saved[(Y - W^.SY1) * W^.SavedW + (X - W^.SX1)];
      PutGlyph(X, Y, Cell.Glyph, Cell.Attr);
    end;
  Window(W^.PrevMinX, W^.PrevMinY, W^.PrevMaxX, W^.PrevMaxY);
  EraseTopWindow := W;
end;

procedure DisposeWindow(W: WindowPtr);
begin
  if W <> nil then
  begin
    SetLength(W^.Saved, 0);
    Dispose(W);
  end;
end;

function WindowStackDepth: Integer;
begin
  WindowStackDepth := WinStackTop;
end;

procedure EraseWindowsDownTo(Depth: Integer);
begin
  while WinStackTop > Depth do
    DisposeWindow(EraseTopWindow);
end;

{$IFDEF WINDOWS}
const
  VtProcessingFlag = $0004; { ENABLE_VIRTUAL_TERMINAL_PROCESSING }
var
  ConsoleMode: DWORD;
{$ENDIF}
begin
  FrameChars := '++++-|';
  SoundFlagW := False;
  WinStackTop := 0;
  {$IFDEF WINDOWS}
  { Классическая консоль Windows по умолчанию не понимает ANSI/VT
    escape-последовательности - без этого флага весь вывод превратится
    в мусор из управляющих кодов. Windows Terminal их включает сам,
    но обычный conhost.exe (cmd.exe) - только по явному запросу. }
  StdOutHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  if GetConsoleMode(StdOutHandle, ConsoleMode) then
    SetConsoleMode(StdOutHandle, ConsoleMode or VtProcessingFlag);
  {$ENDIF}
end.
