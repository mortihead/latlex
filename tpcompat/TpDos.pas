{ Compatibility shim for TurboPower's TpDos unit, реализован поверх FPC. }
unit TpDos;

{$mode tp}
{$H-}

interface

uses
  SysUtils;

var
  { В оригинале управляет обработкой Ctrl-Break; здесь не используется,
    но переменная должна существовать, т.к. на неё есть присваивание. }
  CheckBreak: Boolean;

function ExistFile(const FileName: String): Boolean;
function CompleteFileName(const FileName: String): String;

{ Старые словарные файлы (*.VOC), доставшиеся от DOS-версии программы,
  обычно записаны в кодировке CP866. Если строка не является корректным
  UTF-8, она интерпретируется как CP866 и перекодируется; уже валидный
  UTF-8 возвращается без изменений (так современные словари не портятся). }
function Cp866ToUtf8(const S: String): String;

{ Определять кодировку по одному короткому слову ненадёжно: несколько
  байт CP866 иногда случайно образуют структурно "валидную" UTF-8
  последовательность (ложное срабатывание, видно как "кракозябры").
  Поэтому для файлов решение принимается один раз по солидному куску
  данных - на такой выборке случайное совпадение практически невероятно. }
function DetectFileNeedsCp866(const FileName: String): Boolean;
function ForceCp866ToUtf8(const S: String): String;

implementation

const
  Cp866ToUnicode: array[0..255] of Word = (
    0, 1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23,
    24, 25, 26, 27, 28, 29, 30, 31,
    32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47,
    48, 49, 50, 51, 52, 53, 54, 55,
    56, 57, 58, 59, 60, 61, 62, 63,
    64, 65, 66, 67, 68, 69, 70, 71,
    72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87,
    88, 89, 90, 91, 92, 93, 94, 95,
    96, 97, 98, 99, 100, 101, 102, 103,
    104, 105, 106, 107, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119,
    120, 121, 122, 123, 124, 125, 126, 127,
    1040, 1041, 1042, 1043, 1044, 1045, 1046, 1047,
    1048, 1049, 1050, 1051, 1052, 1053, 1054, 1055,
    1056, 1057, 1058, 1059, 1060, 1061, 1062, 1063,
    1064, 1065, 1066, 1067, 1068, 1069, 1070, 1071,
    1072, 1073, 1074, 1075, 1076, 1077, 1078, 1079,
    1080, 1081, 1082, 1083, 1084, 1085, 1086, 1087,
    9617, 9618, 9619, 9474, 9508, 9569, 9570, 9558,
    9557, 9571, 9553, 9559, 9565, 9564, 9563, 9488,
    9492, 9524, 9516, 9500, 9472, 9532, 9566, 9567,
    9562, 9556, 9577, 9574, 9568, 9552, 9580, 9575,
    9576, 9572, 9573, 9561, 9560, 9554, 9555, 9579,
    9578, 9496, 9484, 9608, 9604, 9612, 9616, 9600,
    1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095,
    1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103,
    1025, 1105, 1028, 1108, 1031, 1111, 1038, 1118,
    176, 8729, 183, 8730, 8470, 164, 9632, 160
  );

function IsValidUtf8(const S: String): Boolean;
var
  i, Cont, Pos: Integer;
  b: Byte;
begin
  IsValidUtf8 := True;
  Pos := 1;
  while Pos <= Length(S) do
  begin
    b := Ord(S[Pos]);
    if b < $80 then
      Cont := 0
    else if (b and $E0) = $C0 then
      Cont := 1
    else if (b and $F0) = $E0 then
      Cont := 2
    else if (b and $F8) = $F0 then
      Cont := 3
    else
    begin
      IsValidUtf8 := False;
      Exit;
    end;
    for i := 1 to Cont do
    begin
      if (Pos + i > Length(S)) or ((Ord(S[Pos + i]) and $C0) <> $80) then
      begin
        IsValidUtf8 := False;
        Exit;
      end;
    end;
    Inc(Pos, Cont + 1);
  end;
end;

function UnicodeToUtf8Char(Code: Word): String;
begin
  if Code < $80 then
    UnicodeToUtf8Char := Chr(Code)
  else if Code < $800 then
    UnicodeToUtf8Char := Chr($C0 or (Code shr 6)) +
      Chr($80 or (Code and $3F))
  else
    UnicodeToUtf8Char := Chr($E0 or (Code shr 12)) +
      Chr($80 or ((Code shr 6) and $3F)) +
      Chr($80 or (Code and $3F));
end;

function ExistFile(const FileName: String): Boolean;
var
  F: File;
begin
  {$I-}
  Assign(F, FileName);
  Reset(F);
  Close(F);
  {$I+}
  ExistFile := (IOResult = 0);
end;

function CompleteFileName(const FileName: String): String;
begin
  CompleteFileName := ExpandFileName(FileName);
end;

function ForceCp866ToUtf8(const S: String): String;
var
  i: Integer;
  R: String;
begin
  R := '';
  for i := 1 to Length(S) do
    R := R + UnicodeToUtf8Char(Cp866ToUnicode[Ord(S[i])]);
  ForceCp866ToUtf8 := R;
end;

function Cp866ToUtf8(const S: String): String;
begin
  if IsValidUtf8(S) then
    Cp866ToUtf8 := S
  else
    Cp866ToUtf8 := ForceCp866ToUtf8(S);
end;

function DetectFileNeedsCp866(const FileName: String): Boolean;
const
  SampleSize = 4096;
var
  F: File;
  Buf: array[0..SampleSize - 1] of Byte;
  Got: Integer;
  S: String;
  i: Integer;
begin
  DetectFileNeedsCp866 := False;
  {$I-}
  Assign(F, FileName);
  Reset(F, 1);
  {$I+}
  if IOResult <> 0 then Exit;
  BlockRead(F, Buf, SampleSize, Got);
  Close(F);
  S := '';
  for i := 0 to Got - 1 do
    S := S + Chr(Buf[i]);
  DetectFileNeedsCp866 := not IsValidUtf8(S);
end;

end.
