{ Compatibility shim for TurboPower's TpCrt unit.

  Fast*-процедуры и ClrScr идут через теневой буфер TpWindow посимвольно
  (по "глифам", см. TpWindow.GlyphLen) - это гарантирует, что кириллица
  и другие многобайтовые UTF-8 символы занимают ровно одну колонку и не
  сбивают координаты окон при их последующем открытии/закрытии поверх
  уже написанного текста. }
unit TpCrt;

{$mode tp}
{$H-}

interface

uses
  Crt, TpWindow;

const
  { Псевдо-режимы видео, использующиеся в Initialize для выбора цветовой
    палитры. На современном терминале всегда "цветной 80x25". }
  Mono  = 7;
  BW80  = 2;
  Co80  = 3;

var
  CurrentMode: Word;
  LastMode: Word;
  { Символ, которым ClrScr заливает фон (в оригинале - управляющий байт
    прямой записи в видеопамять). }
  TextChar: Char;

procedure SelectFont8x8(Enable: Boolean);

{ Перекрываем Crt.GotoXY: сам Crt иногда экономит байты и вместо полного
  абсолютного перехода посылает короткую относительную последовательность
  (например, "влево на 1"), опираясь на собственное представление о
  текущей позиции курсора - а оно сбивается, как только через Crt.Write
  проходит многобайтовый UTF-8 символ (кириллица), потому что Crt считает
  байты, а не колонки. Эта версия всегда шлёт абсолютную позицию, поэтому
  не зависит от того, что было написано на экране раньше. }
procedure GotoXY(X, Y: Integer);

{ Записать строку S в текущем окне по координатам (Y - строка, X - столбец),
  атрибутом Attr, без переноса за границу окна и без изменения TextAttr. }
procedure FastWriteClip(const S: String; Y, X: Integer; Attr: Byte);
procedure FastWrite(const S: String; Y, X: Integer; Attr: Byte);

{ Вертикальная запись строки (посимвольно сверху вниз). }
procedure FastVert(const S: String; Y, X: Integer; Attr: Byte);

{ Сменить атрибут уже выведенных символов в строке Y, столбцы [X1..X2]
  (координаты относительно текущего окна), не трогая сами символы. }
procedure ChangeAttribute(X1, Y, X2: Integer; Attr: Byte);

procedure ClrScr;

procedure HiddenCursor;
procedure NormalCursor;

implementation

procedure SelectFont8x8(Enable: Boolean);
begin
  { На современном терминале переключение шрифта не имеет смысла. }
end;

procedure GotoXY(X, Y: Integer);
begin
  { Сначала настоящий Crt.GotoXY - он безусловно обновит свои внутренние
    CurrX/CurrY на этот же (абсолютный) адрес, даже если сама посланная
    им escape-последовательность окажется "относительной и промахнётся"
    из-за более раннего сбоя счётчика. Поэтому WhereX/WhereY после этого
    вызова снова корректны. Затем поверх шлём заведомо верный абсолютный
    переход, который чинит реальную позицию курсора на экране. }
  Crt.GotoXY(X, Y);
  TpWindow.RawGotoXY(WindMinX + X - 1, WindMinY + Y - 1);
end;

procedure FastWriteClip(const S: String; Y, X: Integer; Attr: Byte);
var
  AvailCols, AbsY, Col, Pos, GLen: Integer;
begin
  AvailCols := WindMaxX - WindMinX + 1 - (X - 1);
  if AvailCols < 0 then AvailCols := 0;
  AbsY := WindMinY + Y - 1;
  Pos := 1;
  Col := 0;
  while (Pos <= Length(S)) and (Col < AvailCols) do
  begin
    GLen := TpWindow.GlyphLen(S, Pos);
    if GLen = 0 then Break;
    TpWindow.PutGlyph(WindMinX + X - 1 + Col, AbsY, Copy(S, Pos, GLen), Attr);
    Inc(Pos, GLen);
    Inc(Col);
  end;
  GotoXY(X + Col, Y);
end;

procedure FastWrite(const S: String; Y, X: Integer; Attr: Byte);
begin
  FastWriteClip(S, Y, X, Attr);
end;

procedure FastVert(const S: String; Y, X: Integer; Attr: Byte);
var
  AbsX, Row, Pos, GLen, MaxRows: Integer;
begin
  AbsX := WindMinX + X - 1;
  MaxRows := WindMaxY - WindMinY + 1;
  Pos := 1;
  Row := 0;
  while Pos <= Length(S) do
  begin
    GLen := TpWindow.GlyphLen(S, Pos);
    if GLen = 0 then Break;
    if Y + Row > MaxRows then Break;
    TpWindow.PutGlyph(AbsX, WindMinY + Y + Row - 1, Copy(S, Pos, GLen), Attr);
    Inc(Pos, GLen);
    Inc(Row);
  end;
end;

procedure ChangeAttribute(X1, Y, X2: Integer; Attr: Byte);
var
  X, AbsX, AbsY: Integer;
  Cell: TpWindow.TCell;
begin
  AbsY := WindMinY + Y - 1;
  for X := X1 to X2 do
  begin
    AbsX := WindMinX + X - 1;
    Cell := TpWindow.GetGlyph(AbsX, AbsY);
    TpWindow.PutGlyph(AbsX, AbsY, Cell.Glyph, Attr);
  end;
end;

procedure ClrScr;
var
  X, Y: Integer;
begin
  for Y := WindMinY to WindMaxY do
    for X := WindMinX to WindMaxX do
      TpWindow.PutGlyph(X, Y, TextChar, TextAttr);
  GotoXY(1, 1);
end;

procedure HiddenCursor;
begin
  System.Write(#27'[?25l');
end;

procedure NormalCursor;
begin
  System.Write(#27'[?25h');
end;

begin
  TextChar := ' ';
  CurrentMode := Co80;
  LastMode := 0;
end.
