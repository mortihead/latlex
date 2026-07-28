{ Compatibility shim for TurboPower's TpDir unit (список файлов / выбор
  файла по маске). Настроечные переменные (FilesUpper, ShowSizeDateTime,
  DirDisplayStr, ExplodeDelay) в оригинале управляли визуальными эффектами
  проводника TPro; здесь принимаются, но не влияют на поведение. }
unit TpDir;

{$mode tp}
{$H-}

interface

uses
  Crt, Dos, TpWindow, TpCrt, TpMouse;

type
  PickColorArray = array[1..6] of Byte;

var
  FilesUpper: Boolean;
  ShowSizeDateTime: Boolean;
  DirDisplayStr: String;
  ExplodeDelay: Integer;

function GetFileName(const Mask: String; Attr: Byte; X, Y, W, H: Integer;
  const Colors: PickColorArray; var Selected: String): Integer;

implementation

const
  MaxFiles = 200;

function GetFileName(const Mask: String; Attr: Byte; X, Y, W, H: Integer;
  const Colors: PickColorArray; var Selected: String): Integer;
var
  Names: array[1..MaxFiles] of String;
  Count, Sel, Top, VisRows: Integer;
  S: SearchRec;
  Win: WindowPtr;
  Key: Word;
  Done: Boolean;

  procedure Redraw;
  var
    r: Integer;
  begin
    Window(Win^.X1 + 1, Win^.Y1 + 1, Win^.X2 - 1, Win^.Y2 - 1);
    ClrScr;
    for r := 0 to VisRows - 1 do
      if Top + r <= Count then
      begin
        if Top + r = Sel then
          FastWriteClip(' ' + Names[Top + r], r + 1, 1, Colors[4])
        else
          FastWriteClip(' ' + Names[Top + r], r + 1, 1, Colors[1]);
      end;
  end;

begin
  Count := 0;
  FindFirst(Mask, AnyFile - VolumeID - Directory, S);
  while (DosError = 0) and (Count < MaxFiles) do
  begin
    Inc(Count);
    Names[Count] := S.Name;
    FindNext(S);
  end;
  FindClose(S);

  if Count = 0 then
  begin
    Selected := '';
    GetFileName := 2;
    Exit;
  end;

  HideMouse;
  FrameChars := '++++=|';
  MakeWindow(Win, X, Y, X + W, Y + H, True, True, True,
    Colors[1], Colors[2], Colors[3], ' ' + Mask + ' ');
  if not DisplayWindow(Win) then
  begin
    Selected := '';
    GetFileName := 5;
    Exit;
  end;

  VisRows := H - 1;
  if VisRows < 1 then VisRows := 1;
  Sel := 1;
  Top := 1;
  Done := False;
  Redraw;
  repeat
    repeat until KeyPressed;
    Key := ReadKeyOrButton;
    if (Key = $4800) and (Sel > 1) then
    begin
      Dec(Sel);
      if Sel < Top then Top := Sel;
      Redraw;
    end
    else if (Key = $5000) and (Sel < Count) then
    begin
      Inc(Sel);
      if Sel > Top + VisRows - 1 then Top := Sel - VisRows + 1;
      Redraw;
    end
    else if Key = 7181 then
    begin
      Selected := Names[Sel];
      Done := True;
    end
    else if Key = $011B then
    begin
      Selected := '';
      Done := True;
    end;
  until Done;

  Win := EraseTopWindow;
  DisposeWindow(Win);
  ShowMouse;
  GetFileName := 0;
end;

begin
  FilesUpper := False;
  ShowSizeDateTime := False;
  DirDisplayStr := '';
  ExplodeDelay := 0;
end.
