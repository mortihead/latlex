{***********************************************}
{*                                             *}
{*   The  Lation Lexicon Menu Unit             *}
{*   N. Bochkaryev, UFA 1993 B_N_V             *}
{*                                             *}
{***********************************************}

unit MenuLex;

{$mode tp}
{$H-}

  interface

  uses
      Dos, Crt,
      LanLex,
      DataLex,
      TpString,
      TpCrt,
      TpCmd,
      TpWindow,
      TpMenu,
      TpEdit,
      TpMouse,
      TpDir,
      TpPick,
      TpDos,
      TpHelp;

  const
       Colors1 : MenuColorArray = ($70, $74, $70, $20, $74, $70, $78, $07);
       Colors2 : MenuColorArray = (31, 30, 31, 63, 30, $70, $78, $07);
       Colors3 : MenuColorArray = ($70, 127, $70, 47, 116, $70, $78, $07);
       {Mono Colors}
       ColorM1 : MenuColorArray = (15, 15, 7, 112, 15, 7, 9, 7);
       ColorM2 : MenuColorArray = (15, 15, 7, 112, 15, 7, 9, 7);
       ColorM3 : MenuColorArray = (15, 15, 7, 112, 15, 7, 9, 7);

       DeskColorAttr = 113;
       DeskMonoAttr = 112;

       DirMono  : PickColorArray = (112,112,112,112,7,112);
       DirCol   : PickColorArray = (48, 112, 112, 47, 48, 47);

       TestAttrC = 63;
       TestAttrM = 15;

       TextAttrC = 48;
       TextAttrM = 7;

       CursAttrM = 8;
       CursAttrC = 48;

       Frame1 : FrameArray = '++++=|';
       Frame2 : FrameArray = '++++-|';
       Frame0 : FrameArray = '      ';

       Explode : boolean = True;


var
  M : Menu;
	M1 : Menu;
	M2 : Menu;
	M3 : Menu;

  Color1, Color2, Color3 : MenuColorArray;
  DeskTopAttr : integer;
  DirColor : PickColorArray;
  Ch : Char;
  KeyMnu : MenuKey;
  Rus : String;
  FileMask : String;
  a,b : integer;
  IndexInLan : String;
  OnOff : String;
  IndexPrompt : String;
  Xcursor, Ycursor : integer;



  procedure DeskTop;
  procedure MainMenu;
  procedure IOSetup;
  procedure DoDefaultCfg;
  procedure ReadConfigure;
  procedure Information;
  procedure ShowNext(X,Y : Integer);
  procedure ViewFile;
  procedure Initialize;
  procedure SaveXY;
  procedure RestoreXY;
  procedure HaltFromTest;
  procedure RevertMouse;
  procedure Compiling;

  implementation


 procedure DeskTop;
 begin
    MakeWindow(W[0],1,1,80,25, True, True, True,112, 119, 112, '');
    if not DisplayWindow(W[0]) then ShowError(2);
    Window(1,1,80,25);
    TextChar := '.';
    TextAttr := DeskTopAttr;
    ClrScr;
    TextChar := ' ';
    NewLine;
    NewLineH;
 end;

  procedure ShowNext(X,Y : integer);
  var MKey : word;
 begin
   FastWriteClip('  Next  ',Y,X,$2F);
   FastWriteClip('#',Y,X+8,112);
   FastWriteClip('########',Y+1,X+1,112);
   ShowMouse;
   repeat
     EnableEventHandling;
     MKey := ReadKeyOrButton;
   until ((Mkey = $1C0D) or
	 ((Mkey = 61184) and (MouseWhereX in [X..X+8])
			 and (MouseWhereY = Y)));
   HideMouse;
   FastWriteClip('#',Y,X+8,119);
   FastWriteClip('########',Y+1,X+1,119);
   FastWriteClip(' ',Y,X,$77);
   FastWriteClip('  Next  ',Y,X+1,$2F);
   Delay(200);
      FastWriteClip('  Next  ',Y,X,$2F);
      FastWriteClip('#',Y,X+8,112);
   FastWriteClip('########',Y+1,X+1,112);
   Delay(200);
   ShowMouse;
 end;



 procedure MainMenu;
   Var FirstLetter : integer;
 begin
  NewLine;
   GoToXY(1,1);
   ClrEol;
     TextAttr := 116;
    Write(' F1 ');
     TextAttr := 112;
     Write(L[82]);
    if ExistFile('LATLEX.HLP') then Rus := 'RUS' else Rus := 'None';
    if MouseInstalled then MouseIndex := 'Normal'
      else MouseIndex := 'None';
  SubMenu(28,5,25,Vertical,Frame1,Color1,L[0]);
    MenuMode(False, True, False);
    MenuWidth(21);
       if Engl then FirstLetter := 3
	   else FirstLetter := 4;
    MenuItem(L[1],2,FirstLetter,1,L[2]);
    MenuItem(L[3],4,4,2,L[4]);
	SubMenu(18,09,25,Horizontal,Frame1,Color2,L[67]);
	  MenuMode(True, True, False);
	  MenuWidth(41);
	    MenuItem(L[5],5,2,8,L[6]);
	    MenuItem(L[7],14,2,9,L[8]);
	    MenuItem(L[9],26,2,10,L[10]);
	    PopSubLevel;
       if Engl then FirstLetter := 4
	   else FirstLetter := 5;
    MenuItem(L[11],6,FirstLetter,3,L[12]);
    SubMenu(24,7,25,Vertical,Frame1,Color1,L[13]);
      MenuMode(True, True, False);
      MenuWidth(28);
      MenuItem(L[16] + LatLexFs, 2, 2, 6, L[18]);
      MenuItem(L[14] + Rus, 1, 2, 5, L[15]);
	 if Engl then FirstLetter := 3
	      else FirstLetter := 2;
      MenuItem(L[68] + IndexLan, 3, FirstLetter, 12, L[69]);
	     SubMenu(27,11,25,Vertical,Frame1,Color1,L[70]);
		MenuMode(True, True, False);
		MenuWidth(11);
		MenuItem(L[71], 1, 3, 13, ' ');
		MenuItem(L[72], 2, 3, 14, ' ');
	     PopSubLevel;
       MenuItem(L[75] + OnOff,4,2,14,L[76]);
	     SubMenu(32,12,25,Horizontal,Frame1,Color2, L[77]);
		MenuMode(True, True, False);
		MenuWidth(11);
		MenuItem('  On  ', 2, 3, 17, ' ');
		MenuItem('  Off ', 10, 4, 18, ' ');
	     PopSubLevel;
       MenuItem(L[103] + MouseIndex,5,2,20,L[104]);
       MenuItem(L[111],6,2,21,L[112]);
	   PopSubLevel;
      if Engl then FirstLetter := 8
	   else FirstLetter := 7;
    MenuItem(L[19],8,FirstLetter,4,L[20]);
    PopSublevel;
    DisableMenuItem(M,5);
    if not MouseInstalled then DisableMenuItem(M,20);
  ResetMenu(M);
  SetMenuDelay(M, 10);
  SelectMenuItem(M,IT);
 end;



 procedure IOSetup;
   var Escaped : boolean;
       FLatLexFile : string;
       Dir      : string;
       F        : text;
       FileStr  : NumString;
       IoR      : Integer;
       BaseDepth: Integer;
   const
       Colors : PickColorArray =  (48, 112, 112, 47, 48, 47);

   label Save;

 begin
   HideMouse;
   BaseDepth := WindowStackDepth;
   FrameChars := ActiveFrame;
   MakeWindow(W[8], 18, 3, 62, 5, True, True, True,
		   127, 127, 127, L[22]);
   if Not DisplayWindow(W[8]) then ShowError(2);
   FastWriteClip(CompleteFileName(LatLexFile), 1, 2, 112);
   MakeWindow(W[8], 16, 7, 64, 12, True, True, True,
		   127, 127, 127, '');
   if Not DisplayWindow(W[8]) then ShowError(2);
	 FastWriteClip(L[23],1,23,112);
    M2 := NewMenu([],nil);
Save:
     SubMenu(18,8,25,Vertical,Frame2,Color3,L[24]);
      MenuMode(False, False, False);
      MenuHeight(2);
      MenuItem(L[25],1,3,2,L[26]);
      MenuItem('  .VOC files   ',2,4,1,L[26]);
	ShowMouse;
	EnableMenuMouse;
        PopSubLevel;
  KeyMnu := MenuChoice(M2, Ch);
	if Ch = #13 then
	 Case KeyMnu of
	1 :  FileMask := '*.VOC';
	2 :  FileMask := '*.*'
	 end{CASE}
	else
	begin
		HideMouse;
	  DisposeMenu(M2);
	  EraseWindowsDownTo(BaseDepth);
	  ShowMouse;
	  Exit;
	 end;

	 Window(1,1,80,25);
		 NewLine;
		 FilesUpper := True;
		 ShowSizeDateTime := True;
		 DirDisplayStr := ^P + 'DIR' + ^Q;
		 HideMouse;
		 ExplodeDelay := 5;
		 Case
	       GetFileName(FileMask,$3F,19,12,22,10,DirColor,LatLexFile)
			 of
		 1 : ErrorDir('Path not found');
		 2 : ErrorDir('No matching  files');
		 3 : ErrorDir('New file');
		 4 : ErrorDir(L[27]);
		 5 : ErrorDir(L[28]);
		 152 : ErrorDir(L[29]);
		 154 : ErrorDir(L[30]);
		 158 : ErrorDir(L[31]);
		 156 : ErrorDir(L[32]);
		 161 : ErrorDir(L[33]);
		 162 : ErrorDir(L[34]);
		 end;
		 ExplodeDelay := 15;
		 ShowMouse;
		if LatLexFile = '' then GoTo Save
	 else
 begin
   ViewFile;
    M3 := NewMenu([],nil);
    ExplodeDelay := 15;
     SubMenu(40,9,25,Horizontal,Frame2,Color3,'');
      MenuMode(False, False, False);
      MenuWidth(2);
      MenuItem('  No  ',10,3,2,'');
      MenuItem('  Yes  ',1,3,1,'');
      EnableMenuMouse;
  KeyMnu := MenuChoice(M3, Ch);
	if Ch = #13 then
	 Case KeyMnu of
		 1: begin
                    HideMouse;
		    MakeWindow(W[1],26,7,53,11,True,True,True, 127, 127, 127, '');
		    if not DisplayWindow(W[1]) then ShowError(2);
		    FastWriteClip(L[35], 2, 9, 112);
		    DoDefaultCfg;
		    DisposeMenu(M3);
		    EraseWindowsDownTo(BaseDepth);
		     ShowMouse;
		      Exit;
		    end;
		 2: begin
	       DisposeMenu(M3);
	       DisposeWindow(EraseTopWindow); { закрыть окно предпросмотра ViewFile }
	       GoTo Save;
		end;
	 end{CASE}
	else
	begin
	   HideMouse;
	   DisposeMenu(M3);
	   DisposeWindow(EraseTopWindow); { закрыть окно предпросмотра ViewFile }
	      ShowMouse;
	     GoTo Save;
         end;
	end;
 end;

  procedure ViewFile;
   type NumStr = array[1..15] of string;
   var i,j : integer;
	 S : NumStr;
	 F : text;
         ErrorCode  : integer;
         NeedsConv  : boolean;
   begin
     for i := 1 to 14 do
       S[i] := ' ';
     NeedsConv := DetectFileNeedsCp866(LatLexFile);
     Assign(F,LatLexFile);
     {$I-}
     Reset(F);
     {$I+}
         ErrorCode := IoResult;
             if ErrorCode <> 0 then EnableError(ErrorCode);
	i := 1;
	  repeat
	    ReadLn(F,S[i]);
	    Inc(i);
	  until Eof(F) or (i = 15);

	 HideMouse;
	 ExplodeDelay := 0;
   MakeWindow(W[8], 3, 14, 77, 23, True, True, True,
		   31, 27, 30, ' ' + LatLexFile + ' ');
   if Not DisplayWindow(W[8]) then ShowError(2);
   for i := 1 to 8 do
     if NeedsConv then
       FastWriteClip(ForceCp866ToUtf8(S[i]),i,1,31)
     else
       FastWriteClip(S[i],i,1,31);
     FastWriteClip(^Q + '#.....................................................'+^P,9,16,49);
     FastVert(^^ + '......' + ^_,15,77,49);
     FastWriteClip(' View ',0,3,27);
     ExplodeDelay := 15;
   end;

 procedure DoDefaultCfg;
   var CfgFile : Text;
       IoR : integer;
  begin
    Assign(CfgFile,'LATLEX.CFG');
    {$I-}
    ReWrite(CfgFile);
    {I+} IoR := IOResult; if IoR <> 0 then EnableError(IoR);
      if IndexLan = 'RUS' then IndexInLan := ^R
       else if IndexLan = 'LAT' then IndexInLan := ^L;
      if PromptOn = False then begin IndexPrompt := ^Q; end
		else if PromptOn then IndexPrompt := ^P;
      WriteLn(CfgFile,' The Lation Lexicon Configuration File !!!~Бочкарев Николай B_N_V93~');
      WriteLn(CfgFile,'Ўў%UFA NEW YORK-+++++++++++++++');
      WriteLn(CfgFile,^A^B^C^D^E^G);
      Writeln(CfgFile,LatLexFile);
      WriteLn(CfgFile,IndexInLan);
      WriteLn(CfgFile,IndexPrompt);
    Close(CfgFile);
  end;

procedure ReadConfigure;
 var CfgFile : Text;
	   S : String;
	Ctrl : String;

 label ExRead;
  begin
     Assign(CfgFile,'LATLEX.CFG');
     {$I-}
     Reset(CfgFile);
     {$I+}
	if IOResult <> 0 then Exit;
	if IOResult = 0 then
	begin
	   ReadLn(CfgFile,Ctrl);
	       if Ctrl <>  ' The Lation Lexicon Configuration File !!!~Бочкарев Николай B_N_V93~'
		     then GoTo ExRead;
	   Reset(CfgFile);
	   ReadLn(CfgFile,S);
	   ReadLn(CfgFile,S);
	   ReadLn(CfgFile,S);
	   ReadLn(CfgFile,LatLexFile);
	   ReadLn(CfgFile,IndexInLan);
	   ReadLn(CfgFile,IndexPrompt);
	  Close(CfgFile);
      If IndexInLan = ^R  then begin IndexLan := 'RUS'; end
	   else If IndexInLan = ^L  then IndexLan := 'LAT';
	if IndexPrompt = ^P  then begin PromptOn := True; end
	    else if IndexPrompt = ^Q then PromptOn := False;
	end;
   ExRead:
  end;

  procedure Information;
  label TimeExit;
    begin
      HideMouse;
      MakeWindow(W[7],23,4,57,18, True, True,  False,
		 $7F,$7F , $7F, ' Information ');
     if not DisplayWindow(W[7]) then ShowError(2);
     FastWriteClip('+----------------+',2,8,127);
     FastWriteClip('| Lation Lexicon |',3,8,127);
     FastWriteClip('+----------------+',4,8,127);
     FastWriteClip('Версия 4.0, Уфа, 1993, 94',6,5,112);
     FastWriteClip('Самоучитель английского языка ',8,3,112);
     FastWriteClip('(c) Николай Бочкарев',10,8,112);

	TimeExit:
	Window(1,1,80,25);
	ShowMouse;
	ShowOk(36,16);
	 HideMouse;
	 W[7] := EraseTopWindow;
	 DisposeWindow(W[7]);
	 ShowMouse;
    end;
procedure Initialize;
begin
  CheckBreak := False;
  Case CurrentMode of
    0..1 : TextMode(CurrentMode+2);
    else
      if Hi(LastMode) <> 0 then
	  SelectFont8x8(False);
    end;
    Case CurrentMode of
       Mono, BW80 :
	  begin
	    HelpColors := HelpMonoC;
	    Color1 := ColorM1;
	    Color2 := ColorM2;
	    Color3 := ColorM3;
	    DeskTopAttr := DeskMonoAttr;
	    DirColor := DirMono;
	    TestAttr := TestAttrM;
	    TestTextAttr := TextAttrM;

	  end
      else begin
	     HelpColors := HelpCol;
	     Color1 := Colors1;
	     Color2 := Colors2;
	     Color3 := Colors3;
	     DeskTopAttr := DeskColorAttr;
	     DirColor := DirCol;
	     TestAttr := TestAttrC;
	     TestTextAttr := TextAttrC;
	   end;
    end;
      Mouse1 := MouseLft;
      Mouse2 := MouseRt;
      Mouse1_2 := MouseBoth;
end;

  procedure SaveXY;
    begin
      Xcursor := WhereX;
      YCursor := WhereY;
    end;
  procedure RestoreXY;
     begin
       GoToXY(Xcursor,Ycursor);
     end;

procedure HaltFromTest;
 var MaxI : integer;
begin
HideMouse;
for i := 1 to 3 do
 begin
     W[i] := EraseTopWindow; DisposeWindow(W[i]);
 end;
       CloseHelp(HelpP);
       NormalCursor;
       TextAttr := $07;
       RestoreXY;
       WriteLn('Thank''s for you, for a PLAY !');
       Halt(1);
end;

 procedure RevertMouse;

 label VisibleEx;
   var Quit : boolean;
       Ch : word;
       Visible : boolean;
       VisibleChar : Char;
       s : string;
  begin
     Visible := True;
     Quit := False;
     HideMouse;
      MakeWindow(W[7],23,13,55,19, True, True,  False,
		   $7F,$7F , $7F, L[41]);
	       if not DisplayWindow(W[7]) then ShowError(2);
	    FastWriteClip(L[42],2,3,48);
	 NormalCursor;
    HideMouse;
   FastWriteClip('   Ok   ',4,12,$2F);
   FastWriteClip('#',4,12+8,112);
   FastWriteClip('########',5,13,112);
   ShowMouse;

	 TextAttr := 63;
	 GoToXY(5,2);
	 repeat
	   EnableEventHandling;
	   Ch := ReadKeyOrButton;
	     if Ch = 14624 then
		 begin
		    if Visible then begin
				      VisibleChar := 'X';
				      Visible := False;
				      GoTo VisibleEx;
				     end;
		    if not Visible then begin
					 VisibleChar := ' ';
					 Visible := True;
				       end;
		    VisibleEx :
		    HideMouse;
		    FastWriteClip(VisibleChar,2,5,63);
		    ShowMouse;
		  end;
	     if (Ch = 7181) or (Ch = MouseLft)  then
	       begin
		  HideMouse;
		   FastWriteClip(' ',4,20,119);
		   FastWriteClip('         ',5,12,119);
		   FastWriteClip(' ',4,12,$77);
		   FastWriteClip('   Ok   ',4,13,$2F);
		   Delay(200);
		   FastWriteClip('   Ok   ',4,12,$2F);
		   FastWriteClip('#',4,20,112);
		   FastWriteClip('########',5,13,112);
		   Delay(200);
		   ShowMouse;
		    if VisibleChar = 'X' then
		      begin
			Mouse2 := MouseLft;
			Mouse1 := MouseRt;
			Mouse1_2 := MouseBoth;
			  HideMouse;
			  W[1] := EraseTopWindow; DisposeWindow(W[1]);
			  ShowMouse;
			 Exit;
		      end;
		    if VisibleChar = ' ' then
		     begin
		       Mouse1 := MouseLft;
		       Mouse2 := MouseRt;
		       Mouse1_2 := MouseBoth;
			 HideMouse;
			 W[1] := EraseTopWindow; DisposeWindow(W[1]);
			 ShowMouse;
			 Exit;
		      end;
		       Mouse1 := MouseLft;
		       Mouse2 := MouseRt;
		       Mouse1_2 := MouseBoth;
			 W[1] := EraseTopWindow; DisposeWindow(W[1]);
			 HideMouse;
			 ShowMouse;
			 Exit;
	       end
	 until Quit;
 end;
 procedure Compiling;

       var
	  FileVoc : text;
	  FileTbl : file of LongInt;
	  i, j,x : integer;
	  St : String;
	  VocStr, TblStr : string[80];
	  OtherStr : string;
	  VocFileSt: string;
	  VocSt    : string;
	  Dir      : string;
	  IOr      : integer;
	  aFileStr, aPathStr, aNameStr, aExtStr : String;
	  S : SearchRec;
	  SizeStr : string;
	  Key : word;

  procedure WriteTbl(Tblf : string; VocF : string);
    var St : String;
	IndB, IndS : LongInt;
	iSt : String;
     begin
       Assign(FileTbl, Tblf);
       Assign(FileVoc, Vocf);
	ReWrite(FileTbl);
	  {$I-}
	  Reset(FileVoc);
	  {$I+}
	  if IOResult <> 0 then begin
		 IOr := IoResult;
		   ErrorDir(L[110]);
		   Exit;
		 end;
	  IndB := 1; IndS := 0;
	  Seek(FileTbl,1);
	  while not EoF(FileVoc) do
	     begin
	       ReadLn(FileVoc, St);
	       Write(FileTbl,IndB);
	       Inc(IndB,Length(St)+2);
	       Str(IndS,iSt);
	       FastWriteClip(iSt,3,20,112);
	       Inc(IndS);
	     end;
	   Write(FileTbl,IndB);
	   Seek(FileTbl,0);
	   Write(FileTbl,IndS);
	   Close(FileTbl);
	   Close(FileVoc);
     end;
   const
       Colors : PickColorArray =  (48, 112, 112, 47, 48, 47);
 begin
   NewLine;
    FilesUpper := True;
     ShowSizeDateTime := True;
	 DirDisplayStr := ^P + 'DIR' + ^Q;
		HideMouse;
		ExplodeDelay := 5;
		 Case
	       GetFileName('*.VOC',$3F,19,12,22,10,DirColor,VocFileSt)
			 of
		 1 : ErrorDir('Path not found');
		 2 : ErrorDir('No matching  files');
		 3 : ErrorDir('New file');
		 4 : ErrorDir(L[27]);
		 5 : ErrorDir(L[28]);
		 152 : ErrorDir(L[29]);
		 154 : ErrorDir(L[30]);
		 158 : ErrorDir(L[31]);
		 156 : ErrorDir(L[32]);
		 161 : ErrorDir(L[33]);
		 162 : ErrorDir(L[34]);
		 end;
		 ExplodeDelay := 15;
		 ShowMouse;
		if VocFileSt = '' then Exit;
	     FrameChars := ActiveFrame;
	     HideMouse;
	     MakeWindow(W[1],21,14,57,20,True,True,True, 127, 127, 127, ' Компиляция ');
	   if not DisplayWindow(W[1]) then ShowError(2);
	    FSplit(VocFileSt, aPathStr, aNameStr, aExtStr);
	   if Length(VocFileSt) > 20 then VocSt := aNameStr + aExtStr
		  else VocSt := VocFileSt;
	   FastWriteClip(' Компиляция :  '+ VocSt,1,1,112);
	   FastWriteClip('Всего',2,20,112);
	   FastWriteClip(' Линии компиляции',3,1,112);
	   FastWriteClip('       Подождите пожалуста         ',5,1,31);
	   TblStr := aNameStr + '.TBL';
	   WriteTbl(TblStr,VocFileSt);
	   FindFirst(TblStr,AnyFile,S);
	   Str(S.Size,SizeStr);
	   ShowMouse;
	   FastWriteClip(' Размер '+TblStr +' : '+SizeStr+' bytes',4,1,112);
	   FastWriteClip('       Нажмите любую клавишу       ',5,1,31);
	   EnableEventHandling;
	   Key := ReadKeyOrButton;
	   HideMouse;
	   W[1] := EraseTopWindow; DisposeWindow(W[1]);
	   ShowMouse;
 end;
end.