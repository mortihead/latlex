{***********************************************}
{*                                             *}
{*  The  Lation Lexicon Data Unit              *}
{*  N. Bochkaryev, UFA 1993 B_N_V              *}
{*                                             *}
{***********************************************}

unit DataLex;

{$mode tp}
{$H-}

 interface

 uses DOS, Printer, Crt,
      LanLex,
      TpDos,
      TpCrt,
      TpString,
      TpWindow,
      TpMouse,
      TpEdit,
      TpCmd,
      TpMenu,
      TpHelp;

 type PlcIndex = array[4..18] of integer;
      Place    = array[1..10] of integer;
      NumString= array[1..07] of string;

 const
     ActiveFrame : FrameArray = '++++=|';
     MainFrame   : FrameArray = '######';
     ScreenFr    : FrameArray = '######';
     WindowFr    : FrameArray = '#### #';
     NoneFr    : FrameArray   = '      ';
     { маркеры курсора вокруг выбранного слова в тесте: в оригинале это
       были байты ^P/^Q (в CP866/CP437 - треугольники "►"/"◄"), но как
       управляющие символы они невидимы в современном UTF-8 терминале }
     CursorMarkL = '▶';
     CursorMarkR = '◀';
     { Colors[2] - цвет ТЕКУЩЕГО (выделенного) пункта Yes/No; было равно
       Colors[3] (обычный/фон пункта) - выделение курсором стрелками было
       технически рабочим (CurIdx менялся), но визуально неотличимо от
       обычного пункта. 116 = чёрный на белом → красный на белом, как и
       для остальных горизонтальных Yes/No-меню в этом же стиле (Colors1). }
     MColor    : MenuColorArray = (112, 116, 112, 47, 116, 119, 116, $07);
     HelpCol   : HelpColorArray = (63,  48, 63, 30, 62,63,51,112);
     HelpMonoC : HelpColorArray = ($0F,$07,$70,$70,15,$0F,0,$0F);


     MaxWindow = 8;

     RangeUp  : integer = 6;
     RangeDn  : integer = 12;
     RangeUpR : integer = 6;
     RangeDnR : integer = 12;

     Score : integer = 0;
     RAns  : integer = 0;

     H : Word = 0;

     It : MenuKey = 1;


  var i,j : integer;
      W : array[0..MaxWindow] of WindowPtr;
      M : array[0..MaxWindow] of WindowPtr;
      DownE, UpE, DownR, UpR,
      Enter, Esc, Tab : boolean;
      KeyW : Word;
      Xc  : Integer;
      IndexE : PlcIndex;
      IndexR : PlcIndex;
      PlaceE,
      PlaceR : Place;
      E,R : NumString;
      X1,X2 : integer;
      TestE : integer;
      TestR : integer;
      Bonus : integer;
      TabMode : boolean;
      TabMode2 : boolean;
      MaxWordTest : integer;
      ErrorStr : string;
      FirstPressMouse : boolean;
      FirstPressMouseR : boolean;
      MaxWordFile : LongInt;
      RandWord : integer;
      LatLexFile : String;
      TablFile   : String;
      PromptOn : boolean;
      IndexLan : String;
      Key : Char;
      ExitAway : boolean;
      RangeLf, RangeRg, RangeLfE, RangeRgE : integer;
      Level : integer;
      MaxY  : integer;
      MaxLevel : integer;
      QMenu  : Menu;
      SMenu  : Menu;
      KeyMnu : MenuKey;
      Ch     : Char;
      CursorAttr : integer;
      Big    : LongInt;
      ErrorCode : Integer;
      Status    : word;
      HelpP     : HelpPtr;
      ChWord    : byte;
      TestAttr  : byte;
      TestTextAttr : byte;
      CBAttr       : byte;
      MouseID      : integer;
      Mouse1, Mouse2,
      Mouse1_2 : Word;
      MouseIndex : string;
      TimeScore,
      Second   : word;


  function  DelSpace(WordSp : String) : String;
  procedure Time;
  function  ExitFromTest : boolean;
  function  SetMidle(XLeft : integer; E : String) : integer;
  procedure Draw;
  procedure WriteCursorE(Y : byte;Levelz:integer);
  procedure ClearCursorE(Y : byte;Levelx:integer);
  procedure WriteCursorR(Y : byte;Levelc:integer);
  procedure ClearCursorR(Y : byte;Levelv:integer);
  procedure Warning(A1, A2 : String; Left : boolean);
  procedure Show;
  procedure LeftWindow(W : String);
  procedure RighWindow(W : String);
  procedure EnableFine;
  procedure ShowError(Error : integer);
  procedure EnableScore;
  procedure ScorePlus;
  procedure ScoreMinus;
  procedure MainStatusLine;
  procedure MakeMainWindow(Wind : integer);
  procedure DisplayHelp(UnitCode : Byte; IdPtr : Pointer; HelpIndex : Word);
  {**********************************}
  function MainTest(Level : integer) : byte;
  {**********************************}
  function  LoadWords : byte;
  procedure ShowOk(X,Y : integer);
  function  LatLexFs : String;
  procedure EnableError(IO : integer);
  procedure NewLine;
  procedure NewLineH;
  function Midle(Wind : integer; Msg : String) : integer;
  procedure ErrorDir(Msg : String);
  procedure InitHelp;


implementation



 function DelSpace(WordSp : String) : String;
 var Sp : string;
 begin
  repeat
   Sp := Copy(WordSp,Length(WordSp),Length(WordSp));
    if Sp = ' ' then
    WordSp := Copy(WordSp,1,Length(WordSp)-1);
  until Sp <> ' ';
  DelSpace := WordSp;
end;

 function LatLexFs : String;
   var FileStr, PathStr, NameStr, ExtStr : String;
    begin
      FSplit(LatLexFile, PathStr, NameStr, ExtStr);
      LatLexFs := NameStr + ExtStr;
    end;

 procedure NewLine;
   begin
    TextAttr := 112;
    GoToXY(1,25);
    ClrEoL;
   end;

   procedure NewLineH;
   begin
    TextAttr := 112;
    GoToXY(1,1);
    ClrEoL;
   end;

 procedure ShowOk(X,Y : integer);
  var MKey : word;
 begin
   HideMouse;
   FastWriteClip('   Ok   ',Y,X,$2F);
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
   FastWriteClip('   Ok   ',Y,X+1,$2F);
   Delay(200);
      FastWriteClip('   Ok   ',Y,X,$2F);
      FastWriteClip('#',Y,X+8,112);
   FastWriteClip('########',Y+1,X+1,112);
   Delay(200);
   ShowMouse;
 end;

procedure Time;
  var
    h, m, s, hund : Word;
    X,Y : Integer;
    Colon : String;
  function LeadingZero(w : Word) : String;
  var
    s : String;
  begin
    Str(w:0,s);
    if Length(s) = 1 then
      s := '0' + s;
    LeadingZero := s;
  end;
  begin
    TextColor(0);
    TextBackGround(15);
    X := WhereX; Y := WhereY;
    Window(1,1,80,25);
    GetTime(h,m,s,hund);
    if Odd(s) then Colon := ':'
       else if not Odd(s) then Colon := ' ';
  FastWriteClip(LeadingZero(h) + Colon + LeadingZero(m),1,75,48);
   GoToXY(X,Y);
  end;

  procedure ShowError(Error : integer);
    var  ErrorMsg : string;
   begin
     Case Error of
      2 : ErrorMsg := 'Insufficient Memory.';
      3 : ErrorMsg := 'File (' + LatLexFile + ') is not Lation Lexicon file.';
      4 : ErrorMsg := 'File (' + LatLexFile + ') not found.';
      5 : ErrorMsg := 'Unknow Window'
      end{CASE};
   Window(1,1,80,25);
   TextAttr := 07;
   ClrScr;
   NormalCursor;
   HideMouse;
   if  Error = 2 then  ClrScr;
   WriteLn('Error ',Error,'  : ',ErrorMsg);
   WriteLn;
   Halt(1);
   end;

 function ExitFromTest : boolean;
  var eX, eY : integer;
  begin
  HideMouse;
   eX := WhereX; eY := WhereY;
       { окно стало на 4 строки выше (10 -> 14), чтобы кнопки Yes/No со
         своей рамкой помещались целиком внутри диалога, не наезжая на
         его собственную нижнюю рамку - включая и тень самой кнопочной
         рамки (ещё +1 строка вниз), и с пустой строкой-отступом после
         вопроса. SubMenu(29,10,...) - координаты кнопочного окна
         абсолютные (не относительно диалога), 29 центрирует его по
         ширине, 10 - первая свободная внутренняя строка после отступа. }
       MakeWindow(W[1],18,7,61,14,True,True,True, 127, 127, 127,
			  ' the Lation Lexicon ');
       if not DisplayWindow(W[1]) then ShowError(2);
       {$R-}
	 FastWriteClip(L[36],1,Midle(43,L[36]),112);
	 QMenu := NewMenu([],nil);
	 SubMenu(29,10,22,Horizontal,ActiveFrame,MColor,'');
	 MenuWidth(2);
	    MenuMode(False,False,False);
	    MenuItem('  Yes  ',6,3,1,L[37]);
	    MenuItem('  No  ',16,3,2,L[37]);
	    PopSubLevel;
	    EnableMenuMouse;
	 ResetMenu(QMenu);
     KeyMnu := MenuChoice(QMenu, Ch);
	    DisableMenuMouse;
	if Ch = #13 then
	 Case KeyMnu of
	     1 : ExitFromTest := True;
	     2 : ExitFromTest := False
	 end{Case}
	else ExitFromTest := False;
	EraseMenu(QMenu, False);
	HideMouse;
	W[1] := EraseTopWindow; DisposeWindow(W[1]);
	 GoToXY(eX,eY);
	ShowMouse;
	end;


function SetMidle(XLeft:integer;E : string) : integer;
 var X : Integer;
 begin
 {$Q-}
 X := XLeft + (14 - VisLen(E)) div 2;
 SetMidle := X;
 {$Q+}
 end;

function Midle(Wind : integer; Msg : String) : integer;
 begin
   Midle := (Wind - VisLen(Msg)) div 2;
 end;

procedure Draw;
const

  MainWAttr = 63;
  MainFAttr = 63;
  MainHAttr = 63;

begin
    HideMouse;
       FrameChars := ActiveFrame;
       MakeWindow(W[1],3,19,26,22,True,True,True, 31, 27, 30,L[17]);
	 if not DisplayWindow(W[1]) then ShowError(2);
      FastWriteClip(L[38],1,4,27);
      FastWriteClip(L[39],2,4,27);
       Window(1,1,80,25);
       InitializeMouse; ShowMouse; MouseGoToXY(18,4);
end;

procedure WriteCursorE(Y:byte;Levelz:integer);
 var Wce : integer;
begin
  Case Levelz of
    1 : Wce := 19;
    2 : Wce := 21;
    3 : Wce := 23
  end;
  HideMouse;
  FastWriteClip(CursorMarkL, Y, Wce, CursorAttr);
  FastWriteClip(CursorMarkR, Y, Wce + 20, CursorAttr);
  { код сопоставления слов (см. вызовы X1/X2 := WhereY в MainTest) узнаёт,
    какая строка сейчас выбрана, именно через реальную позицию курсора -
    поэтому её обязательно нужно оставить здесь, а не только нарисовать
    маркеры через FastWriteClip (который координаты Crt не обновляет). }
  GoToXY(Wce, Y);
  ShowMouse;
end;

procedure ClearCursorE(Y : byte;Levelx:integer);
 var Cce : integer;
begin
  Case Levelx of
    1 : Cce := 19;
    2 : Cce := 21;
    3 : Cce := 23
  end;
  HideMouse;
  FastWriteClip(' ', Y, Cce, TestTextAttr);
  FastWriteClip(' ', Y, Cce + 20, TestTextAttr);
  GoToXY(Cce, Y);
  ShowMouse;
end;

procedure WriteCursorR(Y:byte;Levelc:integer);
 var Wcr : integer;
begin
  Case Levelc of
    1 : WcR := 41;
    2 : WcR := 43;
    3 : WcR := 45
  end;
  HideMouse;
  FastWriteClip(CursorMarkL, Y, Wcr, CursorAttr);
  FastWriteClip(CursorMarkR, Y, Wcr + 20, CursorAttr);
  GoToXY(Wcr, Y);
  ShowMouse;
end;
procedure ClearCursorR(Y : byte;Levelv:integer);
 var Ccr : integer;
begin
  Case Levelv of
    1 : CcR := 41;
    2 : CcR := 43;
    3 : CcR := 45
  end;
  HideMouse;
  FastWriteClip(' ', Y, Ccr, TestTextAttr);
  FastWriteClip(' ', Y, Ccr + 20, TestTextAttr);
  GoToXY(Ccr, Y);
  ShowMouse;
end;

procedure Warning(A1,A2 : string;Left : boolean);

label PromptOffExit;

const
  MainWAttr = 79;
  MainFAttr = 79;
  MainHAttr = 78;

var
  MaxW : integer;
  Col  : integer;
  Row  : integer;
  Q    : integer;
  Pause: integer;
begin
if not PromptOn then GoTo PromptOffExit;
{$S-,R-,V-,I-,B-,F-}
FrameChars := ActiveFrame;
ScoreMinus;
  if Left = True then begin
		       MaxW := 5;
		       Col  := 1; Row := 25; Q := 4;
		      end;
  if Left = False then begin
		       MaxW := 6;
		       Col  := 49; Row := 75; Q := 6;
		      end;
	HideMouse;
	MakeWindow(W[MaxW],Col,3,Row,7, True, True,  False,
	     MainWAttr, MainFAttr, MainHAttr, ' Error ');
  if not DisplayWindow(W[MaxW]) then ShowError(2) ;
       A1 := '-'+' '+ A1 + ' '+'- ';
       A2 := '-'+' '+ A2 + ' '+'- ';
       FastWriteClip(L[40],1,Q,75);
       FastWriteClip(A1,2,SetMidle(Q+2,A1),78);
       FastWriteClip(A2,3,SetMidle(Q+2,A2),78);
       ShowMouse;
PromptOffExit:
end;

procedure Show;
begin
 RAns := RAns + 1;
  CursorAttr := 62;
end;

procedure RighWindow(W : String);
label aWind;
var EWind : String;
    rX,rY : integer;
    lX, lY : integer;
begin
rX := WhereX;rY := WhereY;
Case Level of
     1 :   begin
	     lY := 15;
	     lX := 41;
	   end;
     2 :   begin
	     lY := 16;
	     lX := 43;
	   end;
     3 :   begin
	     lY := 17;
	     lX := 45;
	   end
end; {CASE}
HideMouse;
FastWriteClip('                    ',lY,lX,63);
  for i := 1 to MaxWordTest do
	   if Xc = PlaceR[i] then EWind := R[i];
if W = ' ' then
	      begin
		FastWriteClip('                    ',lY,lX,63);
		ShowMouse;
		GoToXY(rX,rY);
		Exit;
	      end;
FastWriteClip(EWind,lY,SetMidle(lX+4,EWind),63);
ShowMouse;
GoToXY(rX,rY);
end;

procedure LeftWindow(W : string);
Label aSD;
var SD : String;
  Sx,Sy : Integer;
  lX, lY : integer;
begin
sX := WhereX;sY := WhereY;
Case Level of
     1 :   begin
	     lY := 15;
	     lX := 19;
	   end;
     2 :   begin
	     lY := 16;
	     lX := 21;
	   end;
     3 :   begin
	     lY := 17;
	     lX := 23;
	   end
end; {CASE}
HideMouse;
FastWriteClip('                   ',lY,lX,63);
  for i := 1 to MaxWordTest do
	   if Xc = PlaceE[i] then SD := E[i];
 if W = ' ' then begin
	      FastWriteClip('                   ',lY,lX,63);
	      ShowMouse;
	      GoToXY(sX,sY);
	      Exit;
	    end;
FastWriteClip(SD,lY,SetMidle(LX+4,SD),63);
ShowMouse;
GoToXY(sX,sY);
end;


procedure EnableFine;
 var LevelStr : string[10]; Zero : integer;
     BonusStr, TotalStr, AllStr,
     AnsStr, RAnsStr, RAnsPrStr : String[10];
     NotAns : string;
     MaxI : integer;
     StrS : String;
begin
  if (IndexE[MaxY] = 0) and (IndexE[MaxY + 1]= 0) and
     (IndexE[MaxY + 2]= 0) and (IndexE[MaxY + 3]= 0) and
     (IndexE[MaxY + 4]= 0) and (IndexE[MaxY + 5]= 0) and
     (IndexE[MaxY + 6]= 0) then
       begin
	 ClearCursorE(Xc,Level); ClearCursorR(Xc,Level);
	 if Level < MaxLevel then
	   begin
		Case Level of
		   1:  LevelStr := L[100];
		   2:  LevelStr := L[101];
		   3:  LevelStr := L[102]
		end; {Case}
	     Str(Bonus,BonusStr);
	     Str(Score,TotalStr);
	       Score := Score + Bonus;  { *** Assign end level ***}
	     Str(Score,AllStr);
	       FrameChars := ActiveFrame;
	       HideMouse;
	       MakeWindow(W[7],24,6,56,17, True, True,  False,
			   $7F,$7F , $7F, L[43]);
	       if not DisplayWindow(W[7]) then ShowError(2);
		   FastWriteClip(L[49] + LevelStr + L[44],2,
				 Midle(32, (L[49] + LevelStr + L[44])),$70);
		   FastWriteClip(L[45],3,Midle(32,L[45]),$70);
		   FastWriteClip(L[46] + TotalStr,4,Midle(32,(L[46] + TotalStr)),112);
		   FastWriteClip(L[47] + BonusStr,5,Midle(32,L[47] + BonusStr),112);
		   FastWriteClip('------------- ',6,Midle(32,'------------- '),112);
		   FastWriteClip(L[48] + AllStr,7,Midle(32,L[48] + AllStr),112);
		   Window(1,1,80,25);
		   ShowOk(36,15);
		    W[7] := EraseTopWindow; DisposeWindow(W[7]);
	   end;
   if Level = MaxLevel then
     begin
	if RAns < 0 then RAns := 0;
       Str(7 * Maxlevel,AnsStr);Str(RAns,RAnsStr);
       Str(Score,TotalStr);Score := Score + Bonus;
       Str(Score,AllStr);
       Zero := Round((RAns * 100)/(7 * MaxLevel));
       if Zero < 0 then Zero := 0;
       Str(Zero,RAnsPrStr);
	FrameChars := ActiveFrame;
	HideMouse;
	 MakeWindow(W[7],24,6,54,19, True, True,  False,
			$7F,$7F , $7F, L[43]);
	 if not DisplayWindow(W[7]) then ShowError(2);
	   FastWriteClip('+---------------------+',1,4,$74);
	   FastWriteClip('|                     |',2,4,$74);
	   FastWriteClip('|                     |',3,4,$74);
	   FastWriteClip('|                     |',4,4,$74);
	   FastWriteClip('+---------------------+',5,4,$74);
	   FastWriteClip(L[49],2,Midle(30,L[49]),$70);
	   FastWriteClip('Lation Lexicon Test',3,6,$70);
	   FastWriteClip(L[45],4,Midle(30,L[45]),$70);
	   FastWriteClip(L[46] + AllStr,6,Midle(30,L[46] + AllStr),112);
	    if Engl = False then
	     begin
	       StrS := Copy(AnsStr,Length(AnsStr),Length(AnsStr) - 1);
		 if StrS = '1' then L[51] := ' пару';
	       StrS := Copy(RAnsStr,Length(RAnsStr) - 1,Length(RAnsStr));
		if StrS = '1' then L[54] := ' пару слов';
		if (StrS = '2') or (StrS = '3') or (StrS = '4') then
		  L[54] := ' пары слов';
		if (StrS = '5') or (StrS = '6') or (StrS = '7')
		or (StrS = '8') or (StrS = '9') or (StrS = '0') then
		  L[54] := ' пар слов';
		end;
	   FastWriteClip(L[50] + AnsStr + L[51],7,
			 Midle(30,L[50] + AnsStr + L[51]),112);
	   FastWriteClip(L[52],8,Midle(30,L[52]),112);
	   FastWriteClip(L[53] + RAnsStr + L[54],9,
			 Midle(30,L[53] + RAnsStr + L[54]),112);
	   FastWriteClip(RAnsPrStr + '%',10,Midle(30,RAnsPrStr + '%'),116);
       Window(1,1,80,25);
       ShowOk(35,17); HideMouse;
       Case Level of
	 1: MaxI := 3;
	 2: MaxI := 4;
	 3: MaxI := 5;
	end;{CASE}
       for i := 1 to MaxI do
       begin
	    W[i] := EraseTopWindow; DisposeWindow(W[i]);
       end;
   end;
  ExitAway := True;
 end;
end;


  procedure EnableScore;
  var esX, esY : integer;
      Hour, Minute, Sec100 : word;
  begin
    GetTime(Hour, Minute, Second, Sec100);
    if Odd(Second) and (Bonus>0) then
		     begin
		       if TimeScore <> Second then
			 begin
			   Dec(Bonus);
			   TimeScore := Second;
			 end;
		     end;
    TextColor(14);TextBackGround(1);
    esX := WhereX; esY := WhereY;
    GoToXY(18,20);Write(Score:3);
    GoToXY(18,21);Write(Bonus:3);
    GoToXY(esX,esY);
  end;
  procedure ScorePlus;
   begin
    Score := Score + 5;
   end;
  procedure ScoreMinus;
   begin
    Score := Score - 5;
   end;

   procedure MainStatusLine;
     begin
       if MouseInstalled then
       FastWriteClip(' '+L[59],1,1,$70);
       GoToXY(1,25);
       TextAttr := 116; Write(' F1 '); TextAttr := 112; Write(L[82]);
       TextAttr := 116; Write('  F2 '); TextAttr := 112; Write(L[83]);
       TextAttr := 116; Write('  Esc '); TextAttr := 112; Write(L[55]);
       TextAttr := 116; Write(' Tab '); TextAttr := 112; Write(L[56]);
       TextAttr := 116; Write('  Enter '); TextAttr := 112; Write(L[57]);
       TextAttr := 116; Write('  '^X^Y' '); TextAttr := 112; Write(L[58]);
	 {if MouseInstalled then  begin
       TextAttr := 112; Write(' ' + L[59]);  end;}

     end;
  procedure HelpLine;
     begin
       Window(1,1,80,25);
       GoToXY(1,25);
       TextAttr := 116; Write(' F1 '); TextAttr := 112; Write(L[97]);
       TextAttr := 116; Write('  Alt-F1 '); TextAttr := 112; Write(L[98]);
       TextAttr := 116; Write('  Esc '); TextAttr := 112; Write(L[99]);
     end;

   procedure MakeMainWindow(Wind : integer);
    const
       MainWAttr = 63;
       MainFAttr = 63;
       MainHAttr = 63;
    var Xlo, Ylo, Xhi, Yhi : integer;
     begin

      HideMouse;
      Case Wind of
	1 : begin
	      Xlo := 18; Ylo := 4;
	      Xhi := 62; Yhi := 16;
	    end;
	2 : begin
	      Xlo := 20; Ylo := 5;
	      Xhi := 64; Yhi := 17;
	    end;
	3 : begin
	      Xlo := 22; Ylo := 6;
	      Xhi := 66; Yhi := 18;
	    end
	else ShowError(5);
	  end;{Case}
    FrameChars := MainFrame;
    MakeWindow(M[Wind],XLo,YLo,XHi,YHi,True,True,True,TestAttr,TestAttr, TestAttr, '');
	 if not DisplayWindow(M[Wind]) then ShowError(2);
	   FastWriteClip('#-------------------------------------------#',10,0,TestAttr);
	   FastWriteClip('#############################################',12,0,TestAttr);
	      for i := 0 to 12 do
	   FastWriteClip('#',i,22,TestAttr);
	 Window(1,1,80,25);
	 ShowMouse;
     end;

 procedure ErrorDir(Msg : String);
  begin
    {$R-}
    HideMouse;
   Window(1,1,80,25);
   NewLine;
   GotoXY(1,25);
   TextAttr := 112; Write(' Press '); TextAttr := 116; Write('Enter');
   TextAttr := 112; Write(' or click mouse to countinue');
   MakeWindow(W[8], 20, 10, 60, 16, True, True, True,
	      127, 127, 127, L[21]);
    if Not DisplayWindow(W[8]) then ShowError(2);
    ShowMouse;
    FastWriteClip(Msg,2,((40-Length(Msg)) div 2),112);
    Window(1,1,80,25);
	  ShowOk(36,14);
	    HideMouse;
	    NewLine;
	    W[1] := EraseTopWindow;  DisposeWindow(W[1]);
	    ShowMouse;
  end;

  procedure DisplayHelp(UnitCode : Byte; IdPtr : Pointer; HelpIndex : Word);
    {-Display context sensitive help}
  begin
    {do nothing if help index is illegal}
    if HelpIndex <> 0 then begin
      if not ShowHelp(HelpP, HelpIndex) then
	Write(^G);
    end;
  end;

{************************************************************************}

function MainTest(Level : integer) : byte;

label  MenuCon, Tab1, Tab2, Tab3, Tab4, Tab5,
		   Tab11,Tab22,Tab33,Tab44,
		   MouseEx, MouseRx;

var DelWordR, DelWordE  : integer;

procedure SetCoordinateE;
var SetE : integer;
begin
  Case Level of
    1: SetE := 6;
    2: SetE := 7;
    3: SetE := 8;
    end;

Randomize;
PlaceE[1] := Random(7)+ SetE;
repeat PlaceE[2] := Random(7)+SetE; until (PlaceE[2] <> PlaceE[1]);
repeat PlaceE[3] := Random(7)+SetE; until (PlaceE[3] <> PlaceE[1]) and
				      (PlaceE[3] <> PlaceE[2]);
repeat PlaceE[4] := Random(7)+SetE; until (PlaceE[4] <> PlaceE[1]) and
				      (PlaceE[4] <> PlaceE[2]) and
				      (PlaceE[4] <> PlaceE[3]);
repeat PlaceE[5] := Random(7)+ SetE; until (PlaceE[5] <> PlaceE[1]) and
					(PlaceE[5] <> PlaceE[2]) and
					(PlaceE[5] <> PlaceE[3]) and
					(PlaceE[5] <> PlaceE[4]);
repeat PlaceE[6] := Random(7)+ SetE; until (PlaceE[6] <> PlaceE[1]) and
					(PlaceE[6] <> PlaceE[2]) and
					(PlaceE[6] <> PlaceE[3]) and
					(PlaceE[6] <> PlaceE[4]) and
					(PlaceE[6] <> PlaceE[5]);

repeat PlaceE[7] := Random(7)+ SetE; until (PlaceE[7] <> PlaceE[1]) and
					(PlaceE[7] <> PlaceE[2]) and
					(PlaceE[7] <> PlaceE[3]) and
					(PlaceE[7] <> PlaceE[4]) and
					(PlaceE[7] <> PlaceE[5]) and
					(PlaceE[7] <> PlaceE[6]);

end;





procedure SetCoordinateR;
var SetR : integer;
begin
	Case Level of
	1: SetR := 6;
	2: SetR := 7;
	3: SetR := 8;
	end;
repeat PlaceR[1] := Random(7)+ SetR; until PlaceR[1] <> PlaceE[1];
repeat PlaceR[2] := Random(7)+ SetR; until (PlaceR[2] <> PlaceR[1]) and
				      (PlaceR[2] <> PlaceE[2]);
repeat PlaceR[3] := Random(7)+ SetR; until (PlaceR[3] <> PlaceR[1]) and
				      (PlaceR[3] <> PlaceR[2]) and
				      (PlaceR[3] <> PlaceE[3]);
repeat PlaceR[4] := Random(7)+ SetR; until (PlaceR[4] <> PlaceR[1]) and
				      (PlaceR[4] <> PlaceR[2]) and
				      (PlaceR[4] <> PlaceR[3]) and
				      (PlaceR[4] <> PlaceE[4]);
repeat PlaceR[5] := Random(7)+ SetR; until (PlaceR[5] <> PlaceR[1]) and
				      (PlaceR[5] <> PlaceR[2]) and
				      (PlaceR[5] <> PlaceR[3]) and
				      (PlaceR[5] <> PlaceE[5]) and
				      (PlaceR[5] <> PlaceR[4]);
repeat PlaceR[6] := Random(7)+ SetR; until (PlaceR[6] <> PlaceR[1]) and
				      (PlaceR[6] <> PlaceR[2]) and
				      (PlaceR[6] <> PlaceR[3]) and
				      (PlaceR[6] <> PlaceR[4]) and
				      (PlaceR[6] <> PlaceR[5]) and
				      (PlaceR[6] <> PlaceE[6]);
repeat PlaceR[7] := Random(7)+ SetR; until (PlaceR[7] <> PlaceR[1]) and
				       (PlaceR[7] <> PlaceR[2]) and
				       (PlaceR[7] <> PlaceR[3]) and
				       (PlaceR[7] <> PlaceR[4]) and
				       (PlaceR[7] <> PlaceR[5]) and
				       (PlaceR[7] <> PlaceR[6]);

end;


procedure WriteEnWords;
 var Duble : integer;
     Xw : integer;
begin
  Case Level of
    1: Xw := 23;
    2: Xw := 25;
    3: Xw := 27
    end;
  TextAttr := TestTextAttr;
  for i := 1 to MaxWordTest do
  begin
  Duble := 0;
  if Length(E[i]) mod 2 = 0 then Duble := 1;
   FastWrite(E[i],PlaceE[i],SetMidle(Xw-Duble,E[i]),TestTextAttr);
  end;
end;
procedure WriteRusWords;
  var Xwr : integer;
begin
  Case Level of
    1: Xwr := 45;
    2: Xwr := 47;
    3: Xwr := 49
    end;
  TextAttr := TestTextAttr;
  for i := 1 to MaxWordTest do
    FastWrite(R[i], PlaceR[i], SetMidle(Xwr,R[i]), TestTextAttr);
end;

function SortWords : byte;
 label RepeatPrint;
 var Sa, Sb, Sc : integer;
   sX, sY : integer;
  begin
    HideMouse;
     sX := WhereX; sY := WhereY;
       { см. комментарий у ExitFromTest - окно выше (11 -> 15: +1 строка
         отступа, +3 строки кнопочной рамки, +1 строка её тени), кнопки
         получили свою рамку и отдельную строку-отступ после текста. }
       MakeWindow(W[1],15,7,65,15,True,True,True, 127, 127, 127,
			  ' the Lation Lexicon ');
       if not DisplayWindow(W[1]) then ShowError(2);
       {$R-}
	 FastWriteClip(L[84],1,Midle(50,L[84]),112);
	 FastWriteClip(L[85],2,Midle(50,L[85]),112);
	 SMenu := NewMenu([],nil);
	 SubMenu(29,11,22,Horizontal,ActiveFrame,MColor,'');
	 MenuWidth(2);
	    MenuMode(False,False,False);
	    MenuItem('  Yes  ',6,3,1,L[37]);
	    MenuItem('  No  ',16,3,2,L[37]);
	    PopSubLevel;
	    EnableMenuMouse;
	 ResetMenu(SMenu);
     KeyMnu := MenuChoice(SMenu, Ch);
	    DisableMenuMouse;
	if Ch = #13 then
	 Case KeyMnu of
	     1 : ;
	     2 : begin
		  EraseMenu(SMenu, False);
		  W[1] := EraseTopWindow;
		  DisposeWindow(W[1]);
		  DisableMenuMouse;
		  ShowMouse;
		  SortWords := 1;
		   GoToXY(sX,sY);
		  Exit;
		 end;
	 end{Case}
	else begin
	       EraseMenu(SMenu, False);
	       W[1] := EraseTopWindow;
	       DisposeWindow(W[1]);
	       DisableMenuMouse;
	       ShowMouse;
	       SortWords := 1;
		GoToXY(sX,sY);
	       Exit;
	     end;
	EraseMenu(SMenu, False);
	HideMouse;
	W[1] := EraseTopWindow; DisposeWindow(W[1]);
    Case Level of
      1 : begin Sa:= 23; Sb :=  6; Sc := 45; end;
      2 : begin Sa:= 25; Sb :=  7; Sc := 47; end;
      3 : begin Sa:= 27; Sb :=  8; Sc := 49; end;
    else WriteLn('procedure SortWords : Error in level')
    end;
    Window(1,1,80,25);
    TextAttr := 63;
    Window(Sa-4,Sb,Sa+16,Sb+7);
    ClrScr;   Window(1,1,80,25);
    Window(Sc-4,Sb,Sc+16,Sb+7);
    ClrScr;
    Window(1,1,80,25);
    for i := 1 to 7 do
      begin
	FastWriteClip(E[i], Sb - 1 + i,SetMidle(Sa,E[i]),63);
	FastWriteClip(R[i], Sb - 1 + i,SetMidle(Sc,R[i]),63);
      end;
      NewLine;
      FastWriteClip(L[86],25, 1, 112);
      ShowMouse;
      EnableEventHandling;
	repeat
	  Time;
	until KeyPressed or MousePressed;
      KeyW := ReadKeyOrButton;
      HideMouse;
      MakeWindow(W[1],23,7,57,11,True,True,True, 127, 127, 127,
			  ' the Lation Lexicon ');
       if not DisplayWindow(W[1]) then ShowError(2);
	RepeatPrint:
	  Window(1,1,80,25);
	  NewLineH;
	  NewLine;
	   LeftWindow(' ');
	   RighWindow(' ');
	  FastWriteClip(L[90],25,1,112);
       if YesOrNo(L[89],9,Midle(80,L[89]),112,' ') then
	     begin
		{$I-}
		WriteLn(Lst,'********************************************');
		{$I+} ErrorCode := IoResult;
		   if ErrorCode <> 0 then begin
			      NewLine;
			      EnableError(ErrorCode);
			      GoTo RepeatPrint;  end;
		WriteLn(Lst,'*             Lation Lexicon               *');
		WriteLn(Lst,'********************************************');
	       for i := 1 to MaxWordTest do
		WriteLn(Lst,E[i]:19,'   -   ',R[i]);
		WriteLn(Lst,'********************************************');
		W[1] := EraseTopWindow; DisposeWindow(W[1]);
	     end
	 else
	  begin
	   W[1] := EraseTopWindow; DisposeWindow(W[1]);
	  end;
		  NewLine; NewLineH;
		  Case Level of
		   1: j := 2;
		   2: j := 3;
		   3: j := 4
		  end;{CASE}
		 for i := 1 to j do
		begin
		 W[1] := EraseTopWindow;
		 DisposeWindow(W[1]);
		end;
	 SortWords := 0;
    ShowMouse;
  end;

procedure MoveDownE;
 label ExitD;
 begin
	   ClearCursorE(Xc,Level);
	   for i := 1 to MaxWordTest do
	   if (IndexE[Xc+1] = 0) and (Xc < RangeDn) then Xc := Xc + 1;
	   if Xc < RangeDn   then begin Xc := Xc + 1; GoTo ExitD; end;
	   if Xc = RangeDn-1 then begin Xc := RangeDn;GoTo ExitD; end;
	   if Xc = RangeDn   then Xc := RangeUp;
	   ExitD:WriteCursorE(Xc,Level);
	   LeftWindow(' ');
	   X1 := Xc;
 end;
 procedure MoveUpE;
  Label ExitU;
   begin
	   ClearCursorE(Xc,Level);
	   if (Xc = RangeUp)  then
	    begin
	     if IndexE[RangeDn] = 0 then
	      repeat
		RangeDn := RangeDn - 1;
		Xc := RangeDn;
	      until IndexE[RangeDn] <> 0;
	      if IndexE[RangeDn] = 1 then
		Xc := RangeDn;
	      GoTo ExitU;
	     end;
	   for i := 1 to MaxWordTest do
	   if  (IndexE[Xc-1] = 0)  then Xc := Xc - 1;
	   if Xc > RangeUp   then begin Xc := Xc - 1; GoTo ExitU; end;
	   if Xc = RangeUp-1 then begin Xc := RangeUp;GoTo ExitU; end;
	   if Xc = RangeUp   then       Xc := RangeDn;
	   ExitU:WriteCursorE(Xc,Level);
	   LeftWindow(' ');
    end;

 procedure MoveDownR;
  Label ExitQ;
 	   begin
	   ClearCursorR(Xc,Level);
	   for i := 1 to MaxWordTest do
	   if (IndexR[Xc+1] = 0) and (Xc < RangeDnR) then Xc := Xc + 1;
	   if Xc < RangeDnR   then begin Xc := Xc + 1; GoTo ExitQ; end;
	   if Xc = RangeDnR-1 then begin Xc := RangeDnR;GoTo ExitQ; end;
	   if Xc = RangeDnR   then Xc := RangeUpR;
	   ExitQ:WriteCursorR(Xc,Level);
	   RighWindow(' ');
	   end;
 procedure MoveUpR;
  Label ExitZ;
   begin
	   ClearCursorR(Xc,Level);
	   if (Xc = RangeUpR)  then
	    begin
	     if IndexR[RangeDnR] = 0 then
	      repeat
		RangeDnR := RangeDnR - 1;
		Xc := RangeDnR;
	      until IndexR[RangeDnR] <> 0;
	      if IndexR[RangeDnR] = 1 then
		Xc := RangeDnR;
	      GoTo ExitZ;
	    end;
	   for i := 1 to MaxWordTest do
	   if  (IndexR[Xc-1] = 0)  then Xc := Xc - 1;
	   if Xc > RangeUpR   then begin Xc := Xc - 1; GoTo ExitZ; end;
	   if Xc = RangeUpR-1 then begin Xc := RangeUpR;GoTo ExitZ; end;
	   if Xc = RangeUpR   then       Xc := RangeDnR;
	   ExitZ:WriteCursorR(Xc,Level);
	   RighWindow(' ');
   end;

 procedure EnableBad;

  Label PromptOffExit;

 begin
  HideMouse;
    RighWindow(' '); LeftWindow(' ');
	    for i := 1 to MaxWordTest do
	       begin
		if TestE = i then Warning(E[i],R[i],True);
		if TestR = i then Warning(R[i],E[i],False);
	       end;
		 Big := 1;
		 RAns := RAns - 1;
	    if not PromptOn then GoTo PromptOffExit;
		EnableEventHandling;
		 repeat
		  Big := Big + 1;
		  Time;
		 until (Big = 70000) or KeyPressed or MousePressed;
		  StuffString('L');
		  ChWord := ReadKeyOrButton;
	       HideMouse;
		W[1] := EraseTopWindow; DisposeWindow(W[1]);
		W[1] := EraseTopWindow; DisposeWindow(W[1]);
	       ShowMouse;
	    PromptOffExit:
  ShowMouse;
     if TabMode then
	       begin
		repeat
		 Xc := RangeUpR;
		 if IndexR[Xc] = 0 then RangeUp := RangeUp + 1;
		until IndexR[Xc] <> 0;
		CursorAttr := 48;
		  WriteCursorR(Xc,Level);
		  RighWindow('');
	       end;
      if not TabMode  then
	       begin
		repeat
		 Xc := RangeUp;
		 if IndexE[Xc] = 0 then RangeUpR := RangeUpR + 1;
		until IndexE[Xc] <> 0;
		CursorAttr := 48;
		  WriteCursorE(Xc,Level);
		  LeftWindow('');
	       end;
end;
 procedure AssignShow;
 begin
  Show;
  LeftWindow(' ');
  HideMouse;
  FastWriteClip('                   ', X1, DelWordE, TestTextAttr);
  FastWriteClip('                   ', X2, DelWordR, TestTextAttr);
  ShowMouse;
  IndexE[X1] := 0;IndexR[X2] := 0;
 end;

label ExAway, TestExit;


begin
   Case Level of
     1 :  begin
	      RangeUp := 6; RangeUpR := 6;
	      RangeDn := 12; RangeDnR := 12;
	      Xc := 6;
	      RangeLf := 19; RangeRg := 39;
	      RangeLfE := 41; RangeRgE := 61;
	      DelWordE := 20; DelWordR := 42;
	      MaxY := 6;
	   end;
     2 :  begin
	      RangeUp := 7; RangeUpR := 7;
	      RangeDn := 13; RangeDnR := 13;
	      Xc := 7;
	      RangeLf := 21; RangeRg := 41;
	      RangeLfE := 43; RangeRgE := 63;
	      DelWordE := 22; DelWordR := 44;
	      MaxY := 7;
	   end;
     3 :  begin
	      RangeUp := 8; RangeUpR := 8;
	      RangeDn := 14; RangeDnR := 14;
	      Xc := 8;
	      RangeLf := 23; RangeRg := 43;
	      RangeLfE := 45; RangeRgE := 65;
	      DelWordE := 24; DelWordR := 46;
	      MaxY := 8;
	   end;
    end; {CASE}
   MainTest := 2;
   HiddenCursor;
   NewLine;
   NewLineH;
   MakeMainWindow(Level);
   if LoadWords = 0 then
       begin
	 MainTest := 0;
	 Exit;
       end;
   CursorAttr := 62;
   SetCoordinateR; SetCoordinateE;
     WriteEnWords;   WriteRusWords;
     MainStatusLine;
 WriteCursorE(RangeUp,Level);
 TabMode := False;
 TabMode2:= False;
 H := 0;
 Bonus := 35;
 FirstPressMouse  := False;
 FirstPressMouseR := False;
 ExitAway := False;
repeat
Tab4: Time;
 EnableScore;
    begin
    LeftWindow('');
    EnableEventHandling;
    EnableHelpIndex;
    repeat Time; EnableScore;  until KeyPressed or MousePressed;
     KeyW := ReadKeyOrButton;
	  if  (KeyW = $5000) and (Xc <= RangeDn) then  MoveDownE;
	  if  (KeyW = $4800) and (Xc >= RangeUp)  then  MoveUpE;
       if KeyW = 3849 then
MouseEx:  begin {Tab}
	     if TabMode then GoTo Tab3;
	       LeftWindow(' ');
	       TabMode := True;
	      GoTo Tab1;
Tab3:     end;
	if KeyW = $3B00 then
	       begin
		 EnableHelpMouse;
		  NewLine;
		  HelpLine;
		   if not ShowHelp(HelpP,21) then
		     ErrorDir(L[91]);
		 DisableHelpMouse;
		  NewLine;
		  MainStatusLine;
	       end;
	if (KeyW = $3C00) or (KeyW = Mouse1_2) { F2 } then
		begin
		 if SortWords = 0
		   then begin
			  MainTest := 0;
			  Exit;
			end;
		end;
	if KeyW = Mouse1 {LeftMOUSE} then
	       begin
		 if (MouseWhereX in [RangeLf..RangeRg]) and
		    (MouseWhereY = Xc) and FirstPressMouse then
			begin
			  FirstPressMouse := False;
			  GoTo Tab44;
			end;
		 if ((MouseWhereY in [RangeUp..RangeDn]) and
		     (MouseWhereX in [RangeLf..RangeRg]))  then
			begin
			  if IndexE[MouseWhereY] = 0 then GoTo Tab4;
			  FirstPressMouse := True;
			  ClearCursorE(Xc,Level);
			  Xc := MouseWhereY;
			  WriteCursorE(Xc,Level);
			  LeftWindow('');
			  GoTo Tab4;
			end;
		 if (MouseWhereY in [RangeUp..RangeDn]) and
		     (MouseWhereX in [RangeLfE..RangeRgE]) then  GoTo MouseEx;
		     {Mouse Tab}
	       end;

	if KeyW = 7181 {Enter} then
Tab44:	   begin
	     if TabMode and (not TabMode2) then
	       begin
		 ClearCursorE(Xc,Level);
		 X1 := WhereY;
		  for i := 1 to MaxWordTest do
		      if X1 = PlaceE[i] then TestE := i;
		 if TestE = TestR then
		    begin
		       AssignShow; ScorePlus; EnableScore;   EnableFine;
		       if ExitAway then GoTo ExAway;
		    repeat
		       Xc := RangeUpR;
		       if IndexR[Xc] = 0  then RangeUpR := RangeUpR + 1;
		    until IndexR[Xc] <> 0;
		    Xc := RangeUpR;
		   RighWindow(' ');
		   LeftWindow(' ');
		  WriteCursorR(Xc,Level);
		end;
	     if TestE <> TestR then
		 begin
		    EnableBad;
		     if not PromptOn then ScoreMinus;
		    CursorAttr := 48;
		 end;
	    GoTo Tab5;
	    end;
	    TabMode2 := False;
	   X1 := WhereY;
	   for i := 1 to MaxWordTest do
	       if X1 = PlaceE[i] then TestE := i;
	   Tab1:
	   ClearCursorE(Xc,Level);
	   if TestE <> TestR then
	   Xc := RangeUpR;
	   if IndexR[Xc] = 0 then
	  repeat
	      Xc := RangeUpR;
	      if IndexR[Xc] = 0  then RangeUpR := RangeUpR + 1;
	  until IndexR[Xc] <> 0;
	   Xc := RangeUpR; WriteCursorR(Xc,Level);
	   RighWindow('');
	   DisableEventHandling;
 Tab5: repeat
	 EnableEventHandling;
	 repeat Time; EnableScore;  until KeyPressed or MousePressed;
       KeyW := ReadKeyOrButton;
	     RighWindow('');
	     if (KeyW = 20480) and (Xc <= RangeDnR) then  MoveDownR;
	     if (KeyW = 18432) and (Xc >= RangeUpR) then  MoveUpR;
		if KeyW = $3B00   then    {<F1>}
		     begin
		       NewLine;
		       HelpLine;
		       EnableHelpMouse;
			 if not ShowHelp(HelpP,21)
			   then ErrorDir(L[91]);
		       DisableHelpMouse;
		       MainStatusLine;

		     end;
		if (KeyW = $3C00) or (KeyW = Mouse1_2) {<F2>} then
		  begin
		    if SortWords = 0
		      then begin
			  MainTest := 0;
			  Exit;
			end;
		  end;
       if (KeyW = $011B) or (KeyW = Mouse2) then
	if ExitFromTest then
		begin
		  HideMouse;
		  NewLine; NewLineH;
		  Case Level of
		   1: j := 2;
		   2: j := 3;
		   3: j := 4
		  end;{CASE}
		 for i := 1 to j do
		begin
		 W[1] := EraseTopWindow;
		 DisposeWindow(W[1]);
		end;
	 MainTest := 0;
	 Exit;
	end;
  RighWindow('');
	if KeyW = Mouse1 {LeftMOUSE} then
	       begin
		 if (MouseWhereX in [RangeLfE..RangeRgE]) and
		    (MouseWhereY = Xc) and FirstPressMouseR then
			begin
			  FirstPressMouseR := False;
			  GoTo Tab33;
			end; {Mouse Enter}
		 if ((MouseWhereY in [RangeUpR..RangeDnR]) and
		     (MouseWhereX in [RangeLfE..RangeRgE])) then
			begin
			  if IndexR[MouseWhereY] = 0 then GoTo Tab5;
			  FirstPressMouseR := True;
			  ClearCursorR(Xc,Level);
			  Xc := MouseWhereY;
			  WriteCursorR(Xc,Level);
			  RighWindow('');
			  GoTo Tab5;
			end;  {Mouse MoveCursor}
		 if (MouseWhereY in [RangeUp..RangeDn]) and
		     (MouseWhereX in [RangeLf..RangeRg]) then  GoTo MouseRx;
		     {Mouse Tab}
	       end;

       if KeyW = 3849 {TAB} then
MouseRx: begin
	  if TabMode then
	   begin
	    RighWindow(' ');
	    TabMode := False;
	    ClearCursorR(Xc,Level);
	    Xc := RangeUp;
	   if IndexE[Xc] = 0 then
	  repeat
	      Xc := RangeUp;
	      if IndexE[Xc] = 0  then RangeUp := RangeUp + 1;
	  until IndexE[Xc] <> 0;
	  Xc := RangeUp; WriteCursorE(Xc,Level);
	  GoTo Tab4;
	   end;
	 Tab11:
	 end;
      until KeyW = 7181;
Tab33:	   X2 := WhereY;
	   for i := 1 to MaxWordTest do
	       if X2 = PlaceR[i] then TestR := i;
	   ClearCursorR(Xc,Level);
	   if TabMode then GoTo Tab2;
	   if TestE = TestR then
		begin
		 AssignShow;
		 ScorePlus;
		 EnableScore;
		 EnableFine;
		 if ExitAway then GoTo ExAway;
		Tab2:
	    if TabMode then RighWindow('');
		repeat
		   Xc := RangeUp;
		   if IndexE[Xc] = 0  then RangeUp := RangeUp + 1;
		until IndexE[Xc] <> 0;
		Xc := RangeUp;
		WriteCursorE(Xc,Level);
		   if TabMode then Goto Tab4;
		RighWindow(' ');
		LeftWindow(' ');
		end;
	   if TabMode then Goto Tab4;
    if TestE <> TestR then
	  begin
	    EnableBad;
	    if not PromptOn then ScoreMinus;
	    CursorAttr := 48;
	  end;
       end;
    end;
 ExAway:
 if (KeyW = $011B) or (KeyW = Mouse2) then
   if ExitFromTest then
      begin
	 HideMouse;
	 NewLine; NewLineH;
	 Case Level of
	   1: j := 2;
	   2: j := 3;
	   3: j := 4
	 end;{CASE}
	 for i := 1 to j do
		begin
		  W[1] := EraseTopWindow;
		  DisposeWindow(W[1]);
		end;
	 MainTest := 0;
	 ShowMouse;
	 Exit;
	end;
 until ExitAway;
 TestExit:
end;

function LoadWords : byte;
 label Retry, lbExit;

 type
     NumStr = array[-100..100] of integer;
     VOC = Char;
     TBL = LongInt;

 var
     FileVoc  : file of Voc;
     FileTbl  : file of Tbl;

     i, j, x  : Integer;
     rA, rR   : String;
     wX,wY    : integer;
     PerCent  : Integer;
     MaxI     : integer;
     FirstStr : string;
     Other    : NumStr;
     a,b : integer;
     ErrWind : array[0..MaxWindow] of WindowPtr;
     IoR : integer;
     PathStr, NameStr, ExtStr : String;
     St : String;
     NeedsConv : boolean;

 function ReadFile(Prm : integer) : string;
   var A, B, C : LongInt;
       Ch : Char;
       S : String;
       k : integer;
   begin
     S := '';
     Seek(FileTbl,Prm-1);
     {$I-}
     Read(FileTbl,A,B);
      {$I+}
      IoR := IoResult;
	if IoR <> 0 then EnableError(IoR);
      C := B - A - 2;
      Seek(FileVoc,A-1);
	for k := 1 to C do
	    begin
	       {$I-}
	      Read(FileVoc,Ch);
	       {$I+}
	       IoR := IoResult;
		 if IoR <> 0 then EnableError(IoR);

	      S := S + Ch;
	    end;
       ReadFile := S;
   end;

var TblS , VocS : SearchRec;
    VocDateTime, TblDateTime : integer;

begin
  LoadWords  := 1;
  HideMouse;
  PerCent := 14;
  Retry:
  MaxWordTest := 7;
  Randomize;
    FSplit(LatLexFile,PathStr,NameStr,ExtStr);
     TablFile := PathStr + NameStr + '.TBL';
   if not ExistFile(LatLexFile) then    {File  .VOC not FOUND ???}
     begin
       FrameChars := ActiveFrame;
       MakeWindow(ErrWind[1],22,7,58,12,True,True,True, 79, 79, 78, L[60]);
       if not DisplayWindow(ErrWind[1]) then ShowError(2);
	    {$R-}
       FastWriteClip(L[61] + LatLexFs + L[62],
		       1, Midle(36, L[61] + LatLexFs + L[62]),78);
	     FastWriteClip(L[73],2,
		  Midle(36,L[73]),79);
	     FastWriteClip(L[74],3,
		  Midle(36,L[74]),79);
       if YesOrNo('Retry (Y/N)',11,36,79,' ') then
	 begin
	     ErrWind[1] := EraseTopWindow;
	     DisposeWindow(ErrWind[1]);
	   GoTo Retry;
	 end
	else begin
	     ErrWind[1] := EraseTopWindow;
	     DisposeWindow(ErrWind[1]);
	 Case Level of
		 1: MaxI := 2;
		 2: MaxI := 3;
		 3: MaxI := 4
	 end;{Case}
	 for i := 1 to MaxI do
	   begin
	    ErrWind[i] := EraseTopWindow;
	    DisposeWindow(ErrWind[i]);
	  end;
	 LoadWords := 0;
	 Exit;
    end; {"N" Retry}
  end;   {file not found ?}

   if not ExistFile(TablFile) then    {File  .TBL not FOUND ???}
     begin
       FrameChars := ActiveFrame;
       MakeWindow(ErrWind[1],22,7,58,11,True,True,True, 79, 79, 78, L[60]);
       if not DisplayWindow(ErrWind[1]) then ShowError(2);
	    {$R-}
       FastWriteClip(L[105]+LatLexFs+L[106],1,
	    Midle(36,L[105]+LatLexFs+L[106]),78);
       FastWriteClip(TablFile,2,Midle(36,TablFile),79);
       if YesOrNo('Retry (Y/N)',10,35,79,' ') then
	 begin
	     ErrWind[1] := EraseTopWindow;
	     DisposeWindow(ErrWind[1]);
	   GoTo Retry;
	 end
	else begin
	     ErrWind[1] := EraseTopWindow;
	     DisposeWindow(ErrWind[1]);
	 Case Level of
		 1: MaxI := 2;
		 2: MaxI := 3;
		 3: MaxI := 4
	 end;{Case}
	 for i := 1 to MaxI do
	   begin
	    ErrWind[i] := EraseTopWindow;
	    DisposeWindow(ErrWind[i]);
	  end;
	 LoadWords := 0;
	 Exit;
    end; {"N" Retry}
  end;   {file not found ?}

      Assign(FileTbl,TablFile);
      Assign(FileVoc,LatLexFile);
      {$I-}
      Reset(FileTbl);
      {$I+}
      IoR := IoResult;
	if IoR <> 0 then EnableError(IoR);
      {$I-}
      Reset(FileVoc);
      {$I+}
      IoR := IoResult;
	if IoR <> 0 then EnableError(IoR);
      {$I-}
      FindFirst(TablFile,Archive,TblS);
      FindFirst(LatlexFile,Archive,VocS);
	{WriteLn('TBL: ',TablFile ,' ',Tbls.Time);
	WriteLn('VOC: ',LatlexFile,' ',VocS.TIME);
	Halt(1);}
	if TblS.Time < VocS.Time then
	    begin
		 FrameChars := ActiveFrame;
	     MakeWindow(ErrWind[1],22,7,58,13,True,True,True, 127, 127, 127, ' Предупреждение ');
	   if not DisplayWindow(ErrWind[1]) then ShowError(2);
	    {$R-}
	     FastWriteClip('     Несоответсвие версий файлов:',1,1,112);
	     FastWriteClip('      библиотеки и его таблицы',2,1,112);
	     ShowOk(14,4);
	     ErrWind[1] := EraseTopWindow;
	     DisposeWindow(ErrWind[1]);
	 Case Level of
		 1: MaxI := 2;
		 2: MaxI := 3;
		 3: MaxI := 4
	 end;{Case}
	 for i := 1 to MaxI do
	   begin
	    ErrWind[i] := EraseTopWindow;
	    DisposeWindow(ErrWind[i]);
	  end;
	 LoadWords := 0;
	 Exit;
	    end;{ ******* MISTMATC **********}
      Read(FileTbl,MaxWordFile);
      {$I+}
      IoR := IoResult;
	if IoR <> 0 then EnableError(IoR);
 FrameChars := ActiveFrame;
       HideMouse;
	MakeWindow(ErrWind[3],22,7,57,11,True,True,True, 127, 127, 127, ' Loadind ');
	 if not DisplayWindow(ErrWind[3]) then ShowError(2);
		      FastWriteClip(L[65] + LatLexFs, 1,
			  Midle(33,L[65] + LatLexFs),112);
		      Window(1,1,80,25);
		      FastWriteClip('........................',9,28,112);
		      TextAttr := 116; GoToXY(33,10); Write('  ',0);
		      TextAttr := 112; Write(L[66]);
		      GoToXY(28,9); Write('###');
      NeedsConv := DetectFileNeedsCp866(LatLexFile);
      for i := 1 to MaxWordTest do
	Other[i] := 0;
	  i := 1;
	  a := 1;
	  CheckBreak := False;
	      repeat
		RandWord := Random(MaxWordFile);
		Other[i] := RandWord;
	      until ((Other[i] <> Other[i-1]) and
	   (Other[i] <> Other[i-2]) and
	   (Other[i] <> Other[i-3]) and
	   (Other[i] <> Other[i-4]) and
	   (Other[i] <> Other[i-5]) and
	   (Other[i] <> Other[i-6]) and
	   (Other[i] <> Other[i-7]) and
	   (Other[i] <> Other[i-8])) or
	     (i >= MaxWordTest+1);
		   for i := 1 to MaxWordTest do
		     begin
		       { ReadFile(Prm) индексирует .TBL со сдвигом на 2 (Prm=2
		         соответствует первому слову в файле - Prm=0 приводит к
		         ошибке чтения, Prm=1 даёт пустую строку), поэтому диапазон
		         случайного номера тоже сдвинут на 2. }
		       X := Random(MaxWordFile) + 2;
			rA := ReadFile(X);
			 Write('###');
			 TextAttr := 116;
			 wX := WhereX; wY := WhereY; GoToXY(33,10);Write(PerCent:3);
			 GoToXY(wX,wY); TextAttr := 112;
			PerCent := PerCent + 14;
			E[i] := Copy(rA,1,24); R[i] := Copy(rA,25,50);
			E[i] := DelSpace(E[i]);R[i] := DelSpace(R[i]);
			 if (Length(E[i]) > 19) or (Length(R[i]) > 19) then  Dec(i);
			 if NeedsConv then
			   begin
			     E[i] := ForceCp866ToUtf8(E[i]);
			     R[i] := ForceCp866ToUtf8(R[i]);
			   end;
		     end;


      for i := 4 to 18 do
       begin IndexE[i] := 1; IndexR[i] := 1; end;
       TextAttr := 116; GoToXY(33,10); Write(100);
       ErrWind[3] := EraseTopWindow; DisposeWindow(ErrWind[3]);
       ShowMouse;
       LoadWords := 1;
       {$I-}
       Close(FileVoc);
	{$I+}
	IoR := IoResult;
	  if IoR <> 0 then EnableError(IoR);
       {$I-}
       Close(FileTbl);
	{$I+}
	IoR := IoResult;
	  if IoR <> 0 then EnableError(IoR);
end;
  procedure EnableError(IO : integer);
    var Msg : string;
    s : string;
  begin
   Str(IO,s);
   Case Io of
     100 : Msg := L[107];
     2   : Msg := L[108];
     4   : Msg := L[109];
     5   : Msg := L[110];
     150 : Msg := L[80];
     152 : Msg := L[29];
     154 : Msg := L[30];
     156 : Msg := L[32];
     158 : Msg := L[31];
     159 : Msg := L[87];
     160 : Msg := L[88];
     161 : Msg := L[33];
     162 : Msg := L[34]
    else Msg := L[81] + ' (' + s + ')';
   end;{CASE}
     {$R-}
    HideMouse;
   FrameChars := ActiveFrame;
   SoundFlagW := True;
   MakeWindow(W[8], 20, 10, 60, 16, True, True, True,
     127, 127, 127,L[21]);
    if Not DisplayWindow(W[8]) then ShowError(2);
    ShowMouse;
    FastWriteClip(Msg,2,((40-Length(Msg)) div 2),112);
    Window(1,1,80,25);
    ShowOk(36,14);
    HideMouse;
    W[1] := EraseTopWindow;  DisposeWindow(W[1]);
    ShowMouse;
    SoundFlagW := False;
  end;

 procedure InitHelp;
 begin
    HelpMore := True;
   Status := OpenHelpFile('LATLEX.HLP', 16, 4, 19, 2, HelpColors, HelpP);
     if Status <> 0 then
	Case Status of
	  002 : ErrorDir(L[91]);
	  100 : ErrorDir(L[92]);
	  106 : ErrorDir(L[93]);
	  203 : ErrorDir(L[94])
	 else ErrorDir(L[95]+ '(H)')
	end; {Case}
 end;

 end.