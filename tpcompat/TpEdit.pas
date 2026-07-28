{ Compatibility shim for TurboPower's TpEdit unit: здесь только YesOrNo
  (простое окошко подтверждения Y/N) и служебные переменные. }
unit TpEdit;

{$mode tp}
{$H-}

interface

uses
  Crt, TpWindow, TpCrt, TpMouse, TpHelp;

var
  HideCursorInReadChar: Boolean;
  EditHelpPtr: HelpHookProc;

function YesOrNo(const Msg: String; Y, X: Integer; Attr: Byte; Dummy: Char): Boolean;

implementation

function YesOrNo(const Msg: String; Y, X: Integer; Attr: Byte; Dummy: Char): Boolean;
var
  W: WindowPtr;
  WX1, WY1, WX2, WY2: Integer;
  c: Char;
  Prompt: String;
begin
  Prompt := Msg + '  (Y/N)';
  WX1 := X - 2;
  if WX1 < 1 then WX1 := 1;
  WY1 := Y - 1;
  if WY1 < 1 then WY1 := 1;
  WX2 := WX1 + Length(Prompt) + 3;
  if WX2 > 80 then
  begin
    WX2 := 80;
    WX1 := WX2 - Length(Prompt) - 3;
  end;
  WY2 := WY1 + 2;
  if WY2 > 25 then
  begin
    WY2 := 25;
    WY1 := WY2 - 2;
  end;

  HideMouse;
  FrameChars := '++++=|';
  MakeWindow(W, WX1, WY1, WX2, WY2, True, True, True, Attr, Attr, Attr, '');
  if not DisplayWindow(W) then
  begin
    YesOrNo := False;
    Exit;
  end;
  FastWriteClip(Prompt, 1, 2, Attr);

  if HideCursorInReadChar then HiddenCursor;
  repeat
    repeat until KeyPressed;
    c := UpCase(ReadKey);
  until c in ['Y', 'N', #13, #27];
  if HideCursorInReadChar then NormalCursor;
  if c = #27 then c := 'N';
  if c = #13 then c := 'Y';
  YesOrNo := (c = 'Y');

  W := EraseTopWindow;
  DisposeWindow(W);
  ShowMouse;
end;

begin
  HideCursorInReadChar := False;
  EditHelpPtr := nil;
end.
