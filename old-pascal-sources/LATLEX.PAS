{*********************************************}
{*                                           *}
{*  Lation  Lexicon  Main  Progam            *}
{*  N.Bochkaryev 1993  B_N_V, UFA            *}
{*                                           *}
{*********************************************}
program EnglishTest;

uses
     DataLex, MenuLex,  LanLex,
     TpDOS,
     TpCrt,
     TpWindow,
     TpMouse,
     TpEdit,
     TpPick,
     TpHelp,
     TpMenu;


label RepeatCfg, RepeatMenu;

begin
  PickHelpPtr := @DisplayHelp;
  MenuHelpPtr := @DisplayHelp;
  EditHelpPtr := @DisplayHelp;
  EnableHelpMouse;
  TextAttr := 7; Write('The ');
  TextAttr := 15;Write('Lation Lexicon ');
  TextAttr := 7; WriteLn(' by Bochkaryev Nikol programmed 1993, 1994(c), Version 4.0');
  SaveXY;
  Initialize;
  LatLexFile := 'NONAME.VOC';
  PromptOn := True;
  IndexLan := 'LAT';
     if ExistFile('LATLEX.CFG') then ReadConfigure
	    else   DoDefaultCfg;
     if IndexLan = 'RUS'  then Engl := False
     else if IndexLan = 'LAT' then Engl := True;
     if PromptOn then OnOff := 'On';
     if not PromptOn then OnOff := 'Off';
  InitRusLat;
  HiddenCursor;
  DeskTop;
  InitHelp;
  RepeatCfg :
  M := NewMenu([], nil);
 repeat

   MainMenu;
   RepeatMenu :
     EnableMenuMouse;
	KeyMnu := MenuChoice(M, Ch);
     DisableMenuMouse;
   if Ch = #13 then
     Case KeyMnu of
     1 : begin IT := KeyMnu; Information; GoTo RepeatMenu; end;
     6 : begin IT := KeyMnu; EraseMenu(M, False); IOsetup; GoTo RepeatCfg; end;
     8 : begin IT := KeyMnu; MaxLevel := 1; EraseMenu(M, False); end;{LEVELS}
     9 : begin IT := KeyMnu; MaxLevel := 2; EraseMenu(M, False); end;
     10: begin IT := KeyMnu; MaxLevel := 3; EraseMenu(M, False); end;
     13: begin IT := 3; EraseMenu(M, False);IndexLan := 'RUS';
	       Engl := False;
	       InitRusLat;
	       DoDefaultCfg;GoTo RepeatCfg;
	 end;
     14: begin IT := 3; EraseMenu(M, False);IndexLan := 'LAT';
	       Engl := True;
	       InitRusLat;
	       DoDefaultCfg; GoTo RepeatCfg;
	 end;
     17: begin IT := 3; EraseMenu(M, False);PromptOn := True;
	       OnOff := 'On';
	       DoDefaultCfg; GoTo RepeatCfg;
	 end;
     18: begin IT := 3; EraseMenu(M, False); PromptOn := False;
	       OnOff := 'Off';
	       DoDefaultCfg; GoTo RepeatCfg;
	 end;
     20: begin IT := 20; RevertMouse; GoTo RepeatMenu;
	 end;
     21: begin IT := 21; Compiling; GoTo RepeatMenu;
	 end;
     4 : begin  DisposeMenu(M); HaltFromTest; end {Exit}
     else begin DisposeMenu(M); HaltFromTest; end;
  end{Case}
   else if Ch = #27 then HaltFromTest
	else begin DisposeMenu(M); HaltFromTest; end;
   Draw;
   Score := 0;
   RAns  := 0;
   for Level := 1 to MaxLevel do
      begin
	  MenuHelpPtr := nil;
	if MainTest(Level) = 0 then
		   begin
		     MenuHelpPtr := @DisplayHelp;
		     GoTo RepeatCfg;
		   end;
	  MenuHelpPtr := @DisplayHelp;
      end;
 until  Level > MaxLevel;
   end.