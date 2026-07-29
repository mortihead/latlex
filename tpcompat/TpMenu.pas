{ Compatibility shim for TurboPower's TpMenu unit.

  Строим дерево каскадных всплывающих меню (SubMenu/MenuItem/PopSubLevel -
  классический "текущий узел на вершине стека построения", как и в
  оригинале - сами вызовы не получают явного указателя на меню).
  MenuChoice рисует уровни через TpWindow, поэтому раскрывшееся дочернее
  меню корректно ложится поверх родительского, а при закрытии TpWindow
  сам восстанавливает то, что было под ним.

  Мышь не поддерживается (см. TpMouse) - вся навигация с клавиатуры:
  стрелки перемещают подсветку, Enter выбирает пункт или раскрывает
  вложенное меню, Esc завершает MenuChoice, стрелка влево - на уровень
  выше (если открыт вложенный каскад). Буквы-акселераторы (позиция
  которых передаётся в MenuItem) работают как быстрый переход. }
unit TpMenu;

{$mode tp}
{$H-}

interface

uses
  Crt, TpWindow, TpCrt, TpMouse, TpHelp;

type
  FrameArray = TpWindow.FrameArray;
  MenuColorArray = array[1..8] of Byte;
  MenuKey = Integer;
  TMenuOrient = (Vertical, Horizontal);

type
  PMenuItemRec = ^TMenuItemRec;
  PMenuNode = ^TMenuNodeRec;

  TMenuItemRec = record
    Caption: String;
    Pos, HotPos, Id: Integer;
    HelpMsg: String;
    Enabled: Boolean;
    Child: PMenuNode;
  end;

  TMenuNodeRec = record
    X, Y: Integer;
    Orient: TMenuOrient;
    Frame: FrameArray;
    Colors: MenuColorArray;
    Title: String;
    Width: Integer;
    ItemCount: Integer;
    Items: array[1..40] of TMenuItemRec;
    Parent: PMenuNode;
    ParentItemIdx: Integer;
    CurIdx: Integer;
  end;

  PMenuHandle = ^TMenuHandleRec;
  TMenuHandleRec = record
    Root: PMenuNode;
    OpenDepth: Integer;
    OpenNode: array[0..15] of PMenuNode;
    PendingSelectId: Integer;
  end;
  Menu = PMenuHandle;

var
  MenuHelpPtr: HelpHookProc;

function NewMenu(const Options: array of Byte; P: Pointer): Menu;
procedure SubMenu(X, Y, Bound: Integer; Orient: TMenuOrient;
  const Frame: FrameArray; const Colors: MenuColorArray; const Title: String);
procedure MenuItem(const ACaption: String; APos, AHotPos, AId: Integer; const AHelpMsg: String);
procedure MenuMode(A, B, C: Boolean);
procedure MenuWidth(W: Integer);
procedure MenuHeight(H: Integer);
procedure PopSubLevel;
procedure ResetMenu(M: Menu);
procedure SetMenuDelay(M: Menu; Delay: Integer);
procedure SelectMenuItem(M: Menu; Id: Integer);
procedure DisableMenuItem(M: Menu; Id: Integer);
procedure EnableMenuMouse;
procedure DisableMenuMouse;
function MenuChoice(M: Menu; var Ch: Char): MenuKey;
procedure EraseMenu(M: Menu; Dummy: Boolean);
procedure DisposeMenu(M: Menu);

implementation

var
  BuildStack: array[1..16] of PMenuNode;
  BuildTop: Integer;
  PendingHandle: PMenuHandle;

function NewMenu(const Options: array of Byte; P: Pointer): Menu;
var
  H: PMenuHandle;
begin
  New(H);
  H^.Root := nil;
  H^.OpenDepth := 0;
  H^.PendingSelectId := 0;
  PendingHandle := H;
  BuildTop := 0;
  NewMenu := H;
end;

procedure SubMenu(X, Y, Bound: Integer; Orient: TMenuOrient;
  const Frame: FrameArray; const Colors: MenuColorArray; const Title: String);
var
  N: PMenuNode;
begin
  New(N);
  N^.X := X; N^.Y := Y;
  N^.Orient := Orient;
  N^.Frame := Frame;
  N^.Colors := Colors;
  N^.Title := Title;
  N^.Width := 20;
  N^.ItemCount := 0;
  N^.Parent := nil;
  N^.ParentItemIdx := 0;
  N^.CurIdx := 1;
  if BuildTop = 0 then
  begin
    if PendingHandle <> nil then
    begin
      PendingHandle^.Root := N;
      PendingHandle := nil;
    end;
  end
  else
  begin
    N^.Parent := BuildStack[BuildTop];
    N^.ParentItemIdx := BuildStack[BuildTop]^.ItemCount;
    BuildStack[BuildTop]^.Items[BuildStack[BuildTop]^.ItemCount].Child := N;
  end;
  Inc(BuildTop);
  BuildStack[BuildTop] := N;
end;

procedure MenuItem(const ACaption: String; APos, AHotPos, AId: Integer; const AHelpMsg: String);
var
  N: PMenuNode;
  It: PMenuItemRec;
begin
  N := BuildStack[BuildTop];
  Inc(N^.ItemCount);
  It := @N^.Items[N^.ItemCount];
  It^.Caption := ACaption;
  It^.Pos := APos;
  It^.HotPos := AHotPos;
  It^.Id := AId;
  It^.HelpMsg := AHelpMsg;
  It^.Enabled := True;
  It^.Child := nil;
end;

procedure MenuMode(A, B, C: Boolean);
begin
end;

procedure MenuWidth(W: Integer);
begin
  BuildStack[BuildTop]^.Width := W;
end;

procedure MenuHeight(H: Integer);
begin
end;

procedure PopSubLevel;
begin
  if BuildTop > 0 then Dec(BuildTop);
end;

function FindItem(N: PMenuNode; Id: Integer; var Owner: PMenuNode; var Idx: Integer): Boolean;
var
  i: Integer;
begin
  FindItem := False;
  if N = nil then Exit;
  for i := 1 to N^.ItemCount do
  begin
    if N^.Items[i].Id = Id then
    begin
      Owner := N;
      Idx := i;
      FindItem := True;
      Exit;
    end;
    if N^.Items[i].Child <> nil then
      if FindItem(N^.Items[i].Child, Id, Owner, Idx) then
      begin
        FindItem := True;
        Exit;
      end;
  end;
end;

procedure ResetMenu(M: Menu);

  procedure ResetNode(N: PMenuNode);
  var
    i: Integer;
  begin
    if N = nil then Exit;
    N^.CurIdx := 1;
    for i := 1 to N^.ItemCount do
      if N^.Items[i].Enabled then
      begin
        N^.CurIdx := i;
        Break;
      end;
    for i := 1 to N^.ItemCount do
      if N^.Items[i].Child <> nil then
        ResetNode(N^.Items[i].Child);
  end;

begin
  if M = nil then Exit;
  M^.OpenDepth := 0;
  ResetNode(M^.Root);
end;

procedure SetMenuDelay(M: Menu; Delay: Integer);
begin
end;

procedure SelectMenuItem(M: Menu; Id: Integer);
begin
  if M <> nil then M^.PendingSelectId := Id;
end;

procedure DisableMenuItem(M: Menu; Id: Integer);
var
  Owner: PMenuNode;
  Idx: Integer;
begin
  if (M = nil) or (M^.Root = nil) then Exit;
  if FindItem(M^.Root, Id, Owner, Idx) then
    Owner^.Items[Idx].Enabled := False;
end;

procedure EnableMenuMouse;
begin
end;

procedure DisableMenuMouse;
begin
end;

function AttrFor(N: PMenuNode; Idx: Integer): Byte;
begin
  if not N^.Items[Idx].Enabled then
    AttrFor := N^.Colors[4]
  else if Idx = N^.CurIdx then
    AttrFor := N^.Colors[2]
  else
    AttrFor := N^.Colors[3];
end;

procedure DrawItem(N: PMenuNode; Idx: Integer);
begin
  with N^.Items[Idx] do
    if N^.Orient = Vertical then
      FastWriteClip(Caption, Pos, 2, AttrFor(N, Idx))
    else
      FastWriteClip(Caption, 1, Pos, AttrFor(N, Idx));
end;

function NodeHeight(N: PMenuNode): Integer;
var
  i, H: Integer;
begin
  if N^.Orient = Horizontal then
    NodeHeight := 3
  else
  begin
    H := 2;
    for i := 1 to N^.ItemCount do
      if N^.Items[i].Pos + 2 > H then H := N^.Items[i].Pos + 2;
    NodeHeight := H;
  end;
end;

{ MenuWidth, заданный в исходнике, иногда меньше, чем реально нужно для
  размещения пунктов (например, "MenuWidth(2)" для горизонтального меню
  Yes/No, у которого пункты стоят на колонках 1 и 10) - в оригинале это,
  видимо, не имело значения, но в нашей реализации слишком узкое окно
  даёт вырожденную (отрицательной ширины) внутреннюю область и полностью
  ломает координаты всего, что рисуется внутри. Поэтому берём максимум
  из заданной ширины и реально необходимой по пунктам. }
function NodeWidth(N: PMenuNode): Integer;
var
  i, W, Need: Integer;
begin
  W := N^.Width;
  for i := 1 to N^.ItemCount do
  begin
    Need := N^.Items[i].Pos + VisLen(N^.Items[i].Caption);
    if Need > W then W := Need;
  end;
  NodeWidth := W;
end;

procedure DrawNode(N: PMenuNode);
var
  Win: WindowPtr;
  i: Integer;
  HasVisibleFrame: Boolean;
begin
  FrameChars := N^.Frame;
  { тень имеет смысл только у окна с видимой рамкой (как в оригинале -
    "приподнятая" рамка отбрасывает тень); у полностью прозрачного меню
    (все символы рамки - пробелы, как NoneFr для кнопок Yes/No) тень
    рисуется как ничем не обоснованное цветное пятно рядом с текстом. }
  HasVisibleFrame := (N^.Frame[1] <> ' ') or (N^.Frame[6] <> ' ');
  MakeWindow(Win, N^.X, N^.Y, N^.X + NodeWidth(N) - 1, N^.Y + NodeHeight(N) - 1,
    True, HasVisibleFrame, True, N^.Colors[3], N^.Colors[1], N^.Colors[7], N^.Title);
  DisplayWindow(Win);
  for i := 1 to N^.ItemCount do
    DrawItem(N, i);
end;

function FirstEnabled(N: PMenuNode): Integer;
var
  i: Integer;
begin
  FirstEnabled := 1;
  for i := 1 to N^.ItemCount do
    if N^.Items[i].Enabled then
    begin
      FirstEnabled := i;
      Exit;
    end;
end;

{ Пункты добавляются в MenuItem не обязательно по возрастанию Pos
  (например, в подменю "Environment" пункт с Pos=2 добавлен раньше
  пункта с Pos=1), поэтому перемещение курсора должно идти по реальной
  визуальной позиции пункта, а не по порядку вставки в массив. }
function FindByPos(N: PMenuNode; CurIdx: Integer; Forward: Boolean): Integer;
var
  i, Best, BestPos, CurPos: Integer;
begin
  CurPos := N^.Items[CurIdx].Pos;
  Best := CurIdx;
  if Forward then BestPos := MaxInt else BestPos := -MaxInt;
  for i := 1 to N^.ItemCount do
    if N^.Items[i].Enabled and (i <> CurIdx) then
    begin
      if Forward and (N^.Items[i].Pos > CurPos) and (N^.Items[i].Pos < BestPos) then
      begin
        Best := i;
        BestPos := N^.Items[i].Pos;
      end;
      if (not Forward) and (N^.Items[i].Pos < CurPos) and (N^.Items[i].Pos > BestPos) then
      begin
        Best := i;
        BestPos := N^.Items[i].Pos;
      end;
    end;
  if Best = CurIdx then
  begin
    { дошли до края - оборачиваемся на противоположный конец }
    if Forward then BestPos := MaxInt else BestPos := -MaxInt;
    for i := 1 to N^.ItemCount do
      if N^.Items[i].Enabled and (i <> CurIdx) then
      begin
        if Forward and (N^.Items[i].Pos < BestPos) then
        begin
          Best := i;
          BestPos := N^.Items[i].Pos;
        end;
        if (not Forward) and (N^.Items[i].Pos > BestPos) then
        begin
          Best := i;
          BestPos := N^.Items[i].Pos;
        end;
      end;
  end;
  FindByPos := Best;
end;

function MenuChoice(M: Menu; var Ch: Char): MenuKey;
var
  Key: Word;
  Quit: Boolean;
  ResultId: Integer;
  Owner: PMenuNode;
  Idx, i: Integer;
  Cur: PMenuNode;
  Letter: Char;

  procedure OpenChain(Target: PMenuNode);
  var
    Chain: array[0..15] of PMenuNode;
    n, k: Integer;
    p: PMenuNode;
  begin
    n := 0;
    p := Target;
    while p <> nil do
    begin
      Chain[n] := p;
      Inc(n);
      p := p^.Parent;
    end;
    { в каждом родителе подсвечиваем именно тот пункт, из которого
      раскрывается вложенный каскад к цели - иначе после возврата на
      уровень выше подсветка осталась бы на дефолтном первом пункте,
      никак не связанном с только что открытым вложенным меню }
    for k := 0 to n - 2 do
      Chain[k + 1]^.CurIdx := Chain[k]^.ParentItemIdx;
    for k := n - 1 downto 0 do
    begin
      Inc(M^.OpenDepth);
      M^.OpenNode[M^.OpenDepth] := Chain[k];
      DrawNode(Chain[k]);
    end;
  end;

begin
  if M^.OpenDepth = 0 then
  begin
    if (M^.PendingSelectId <> 0) and FindItem(M^.Root, M^.PendingSelectId, Owner, Idx) then
    begin
      Owner^.CurIdx := Idx;
      OpenChain(Owner);
    end
    else
      OpenChain(M^.Root);
    M^.PendingSelectId := 0;
  end;

  Quit := False;
  ResultId := 0;
  repeat
    Cur := M^.OpenNode[M^.OpenDepth];
    repeat until KeyPressed;
    Key := ReadKeyOrButton;

    if (Key = $4800) or (Key = $4B00) then { Up / Left }
    begin
      i := FindByPos(Cur, Cur^.CurIdx, False);
      Idx := Cur^.CurIdx;
      Cur^.CurIdx := i;
      DrawItem(Cur, Idx);
      DrawItem(Cur, Cur^.CurIdx);
    end
    else if (Key = $5000) or (Key = $4D00) then { Down / Right }
    begin
      i := FindByPos(Cur, Cur^.CurIdx, True);
      Idx := Cur^.CurIdx;
      Cur^.CurIdx := i;
      DrawItem(Cur, Idx);
      DrawItem(Cur, Cur^.CurIdx);
    end
    else if Key = 7181 then { Enter }
    begin
      if Cur^.Items[Cur^.CurIdx].Child <> nil then
      begin
        Inc(M^.OpenDepth);
        M^.OpenNode[M^.OpenDepth] := Cur^.Items[Cur^.CurIdx].Child;
        DrawNode(M^.OpenNode[M^.OpenDepth]);
      end
      else
      begin
        ResultId := Cur^.Items[Cur^.CurIdx].Id;
        Ch := #13;
        Quit := True;
      end;
    end
    else if Key = $011B then { Esc: подняться на уровень выше, если открыт
                               вложенный каскад, иначе выйти из MenuChoice }
    begin
      if M^.OpenDepth > 1 then
      begin
        DisposeWindow(EraseTopWindow);
        Dec(M^.OpenDepth);
      end
      else
      begin
        ResultId := Cur^.Items[Cur^.CurIdx].Id;
        Ch := #27;
        Quit := True;
      end;
    end
    else if (Key = $3B00) and Assigned(MenuHelpPtr) then { F1 }
      MenuHelpPtr(0, nil, Cur^.Items[Cur^.CurIdx].Id)
    else if (Key and $FF) <> 0 then
    begin
      Letter := UpCase(Chr(Key and $FF));
      for i := 1 to Cur^.ItemCount do
        if Cur^.Items[i].Enabled and (Cur^.Items[i].HotPos <= Length(Cur^.Items[i].Caption))
          and (UpCase(Cur^.Items[i].Caption[Cur^.Items[i].HotPos]) = Letter) then
        begin
          Idx := Cur^.CurIdx;
          Cur^.CurIdx := i;
          DrawItem(Cur, Idx);
          DrawItem(Cur, Cur^.CurIdx);
          if Cur^.Items[i].Child <> nil then
          begin
            Inc(M^.OpenDepth);
            M^.OpenNode[M^.OpenDepth] := Cur^.Items[i].Child;
            DrawNode(M^.OpenNode[M^.OpenDepth]);
          end
          else
          begin
            ResultId := Cur^.Items[i].Id;
            Ch := #13;
            Quit := True;
          end;
          Break;
        end;
    end;
  until Quit;
  MenuChoice := ResultId;
end;

procedure EraseMenu(M: Menu; Dummy: Boolean);
var
  W: WindowPtr;
begin
  if M = nil then Exit;
  while M^.OpenDepth > 0 do
  begin
    W := EraseTopWindow;
    DisposeWindow(W);
    Dec(M^.OpenDepth);
  end;
end;

procedure FreeNode(N: PMenuNode);
var
  i: Integer;
begin
  if N = nil then Exit;
  for i := 1 to N^.ItemCount do
    if N^.Items[i].Child <> nil then
      FreeNode(N^.Items[i].Child);
  Dispose(N);
end;

procedure DisposeMenu(M: Menu);
begin
  if M = nil then Exit;
  EraseMenu(M, False);
  FreeNode(M^.Root);
  Dispose(M);
end;

begin
  MenuHelpPtr := nil;
  BuildTop := 0;
  PendingHandle := nil;
end.
