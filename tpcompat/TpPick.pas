{ Compatibility shim for TurboPower's TpPick unit: в этом проекте из него
  нужен только указатель на обработчик контекстной помощи. }
unit TpPick;

{$mode tp}
{$H-}

interface

uses
  TpHelp;

var
  PickHelpPtr: HelpHookProc;

implementation

begin
  PickHelpPtr := nil;
end.
