{ Compatibility shim for TurboPower's TpMouse unit.

  В терминале честную поддержку мыши (позиционирование, отдельные кнопки)
  сделать нормально нельзя, а игра и не требует этого - в оригинале она
  полностью работоспособна и с клавиатуры (autor сам отключал пункт меню
  мыши, если MouseInstalled = False). Поэтому здесь мышь всегда считается
  не установленной, а ReadKeyOrButton всегда возвращает обычную клавишу.

  Коды клавиш собраны в формате (скан-код shl 8) or ASCII - как их отдавал
  BIOS INT16h на реальном DOS и как их проверяет прикладной код
  (например, $011B - Esc, 7181 - Enter, $4800/$5000 - стрелки, 3849 - Tab). }
unit TpMouse;

{$mode tp}
{$H-}

interface

uses
  Crt;

const
  MouseLft  : Word = 61184;
  MouseRt   : Word = 61185;
  MouseBoth : Word = 61186;

var
  MouseInstalled: Boolean;
  MouseIndex: string;

procedure InitializeMouse;
procedure ShowMouse;
procedure HideMouse;
procedure MouseGoToXY(X, Y: Integer);
function MouseWhereX: Integer;
function MouseWhereY: Integer;
function MousePressed: Boolean;
procedure EnableEventHandling;
procedure DisableEventHandling;
procedure EnableHelpMouse;
procedure DisableHelpMouse;
procedure StuffString(const S: String);
function ReadKeyOrButton: Word;

implementation

var
  Pending: String;

procedure InitializeMouse;
begin
end;

procedure ShowMouse;
begin
end;

procedure HideMouse;
begin
end;

procedure MouseGoToXY(X, Y: Integer);
begin
end;

function MouseWhereX: Integer;
begin
  MouseWhereX := 0;
end;

function MouseWhereY: Integer;
begin
  MouseWhereY := 0;
end;

function MousePressed: Boolean;
begin
  MousePressed := False;
end;

procedure EnableEventHandling;
begin
end;

procedure DisableEventHandling;
begin
end;

procedure EnableHelpMouse;
begin
end;

procedure DisableHelpMouse;
begin
end;

procedure StuffString(const S: String);
begin
  Pending := Pending + S;
end;

function ReadKeyOrButton: Word;
var
  c: Char;
begin
  if Pending <> '' then
  begin
    c := Pending[1];
    Delete(Pending, 1, 1);
  end
  else
    c := ReadKey;
  case c of
    #0:
      ReadKeyOrButton := Word(Ord(ReadKey)) shl 8;
    #13:
      ReadKeyOrButton := (28 shl 8) or 13;
    #27:
      ReadKeyOrButton := (1 shl 8) or 27;
    #9:
      ReadKeyOrButton := (15 shl 8) or 9;
  else
    ReadKeyOrButton := Ord(c);
  end;
end;

begin
  MouseInstalled := False;
  MouseIndex := 'None';
  Pending := '';
end.
