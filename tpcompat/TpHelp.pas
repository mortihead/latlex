{ Compatibility shim for TurboPower's TpHelp unit.

  В оригинале LATLEX.HLP - это скомпилированный THELP-подобным
  компилятором бинарный файл, собранный из LATLEX.TXT. Здесь компилятор
  недоступен, поэтому ShowHelp читает и разбирает разметку LATLEX.TXT
  (!TOPIC/!PAGE/!LINE/!WIDTH) прямо во время выполнения. }
unit TpHelp;

{$mode tp}
{$H-}

interface

uses
  Crt, TpWindow, TpCrt, TpMouse;

type
  HelpColorArray = array[1..8] of Byte;
  HelpPtr = ^Integer;
  HelpHookProc = procedure(UnitCode: Byte; IdPtr: Pointer; HelpIndex: Word);

var
  HelpColors: HelpColorArray;
  HelpMore: Boolean;

function OpenHelpFile(const FileName: String; P1, P2, P3, P4: Integer;
  const Colors: HelpColorArray; var H: HelpPtr): Word;
function ShowHelp(H: HelpPtr; TopicId: Word): Boolean;
procedure CloseHelp(H: HelpPtr);
procedure EnableHelpIndex;

implementation

type
  TTopic = record
    Id: Word;
    Name: String;
    LineCount: Integer;
    Lines: array[1..200] of String;
  end;

var
  Topics: array[1..64] of TTopic;
  TopicCount: Integer;
  Loaded: Boolean;

function OpenHelpFile(const FileName: String; P1, P2, P3, P4: Integer;
  const Colors: HelpColorArray; var H: HelpPtr): Word;
var
  F: Text;
  S: String;
  IoR: Integer;
  Cur: Integer;
  P: Integer;
begin
  HelpColors := Colors;
  TopicCount := 0;
  Cur := 0;
  {$I-}
  Assign(F, FileName);
  Reset(F);
  {$I+}
  IoR := IOResult;
  if IoR <> 0 then
  begin
    New(H);
    H^ := 0;
    Loaded := False;
    OpenHelpFile := 100;
    Exit;
  end;
  while not Eof(F) do
  begin
    ReadLn(F, S);
    if (Length(S) >= 6) and (Copy(S, 1, 6) = '!TOPIC') then
    begin
      Inc(TopicCount);
      Cur := TopicCount;
      Topics[Cur].LineCount := 0;
      S := Copy(S, 7, Length(S) - 6);
      while (Length(S) > 0) and (S[1] = ' ') do
        Delete(S, 1, 1);
      P := Pos(' ', S);
      if P = 0 then
      begin
        Topics[Cur].Id := 0;
        Topics[Cur].Name := S;
      end
      else
      begin
        Val(Copy(S, 1, P - 1), Topics[Cur].Id, IoR);
        Topics[Cur].Name := Copy(S, P + 1, Length(S) - P);
      end;
    end
    else if (Length(S) >= 1) and (S[1] = ';') then
      { комментарий вне топика - пропускаем }
    else if (Length(S) >= 6) and (Copy(S, 1, 6) = '!WIDTH') then
      { ширина исходника, не используется }
    else if Cur > 0 then
    begin
      if Topics[Cur].LineCount < 200 then
      begin
        Inc(Topics[Cur].LineCount);
        Topics[Cur].Lines[Topics[Cur].LineCount] := S;
      end;
    end;
  end;
  Close(F);
  Loaded := True;
  New(H);
  H^ := 1;
  OpenHelpFile := 0;
end;

function FindTopic(TopicId: Word): Integer;
var
  i: Integer;
begin
  FindTopic := 0;
  for i := 1 to TopicCount do
    if Topics[i].Id = TopicId then
    begin
      FindTopic := i;
      Exit;
    end;
end;

const
  WinX1 = 8; WinY1 = 2; WinX2 = 72; WinY2 = 23;

function StringOfChar(Ch: Char; Count: Integer): String;
var
  i: Integer;
  S: String;
begin
  S := '';
  for i := 1 to Count do
    S := S + Ch;
  StringOfChar := S;
end;

function ShowHelp(H: HelpPtr; TopicId: Word): Boolean;
var
  Ti: Integer;
  W: WindowPtr;
  i, Row: Integer;
  Line: String;
  WinAttr, FrameAttr, HeaderAttr, TextAttrC: Byte;
begin
  if (not Loaded) or (H = nil) then
  begin
    ShowHelp := False;
    Exit;
  end;
  Ti := FindTopic(TopicId);
  if Ti = 0 then
  begin
    ShowHelp := False;
    Exit;
  end;
  WinAttr := HelpColors[1];
  FrameAttr := HelpColors[2];
  HeaderAttr := HelpColors[3];
  TextAttrC := HelpColors[1];

  HideMouse;
  FrameChars := '++++=|';
  MakeWindow(W, WinX1, WinY1, WinX2, WinY2, True, True, True,
    WinAttr, FrameAttr, HeaderAttr, ' ' + Topics[Ti].Name + ' ');
  if not DisplayWindow(W) then
  begin
    ShowHelp := False;
    Exit;
  end;

  Row := 1;
  i := 1;
  while i <= Topics[Ti].LineCount do
  begin
    Line := Topics[Ti].Lines[i];
    { в исходном LATLEX.TXT 1994 года сама разметка написана не всегда
      единообразно - например, одна из директив !LINE записана как
      !Line - поэтому сравниваем без учёта регистра. }
    if UpCase(Line) = '!PAGE' then
    begin
      FastWriteClip(' -- Enter/Esc: close, any key: next -- ',
        WinY2 - WinY1 - 1, 1, TextAttrC);
      repeat until KeyPressed;
      ReadKey;
      Window(WinX1 + 1, WinY1 + 1, WinX2 - 1, WinY2 - 1);
      ClrScr;
      Row := 1;
    end
    else if UpCase(Line) = '!LINE' then
    begin
      FastWriteClip(StringOfChar('-', WinX2 - WinX1 - 3), Row, 1, TextAttrC);
      Inc(Row);
    end
    else
    begin
      if Row <= WinY2 - WinY1 - 1 then
        FastWriteClip(Line, Row, 1, TextAttrC);
      Inc(Row);
    end;
    Inc(i);
  end;

  FastWriteClip(' -- Enter/Esc: close -- ', WinY2 - WinY1 - 1, 1, TextAttrC);
  repeat until KeyPressed;
  ReadKey;

  W := EraseTopWindow;
  DisposeWindow(W);
  ShowMouse;
  ShowHelp := True;
end;

procedure CloseHelp(H: HelpPtr);
begin
  if H <> nil then
    Dispose(H);
end;

procedure EnableHelpIndex;
begin
end;

begin
  Loaded := False;
  TopicCount := 0;
  HelpMore := True;
end.
