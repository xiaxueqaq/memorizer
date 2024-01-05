Program Memorizer;
{$H+}{$mode objFPC}
Uses SysUtils

{$IFDEF Win32}
,Windows
{$ENDIF};

var
   n		: Longint;
   i,j,k	: Longint;
   voca,eng,chn	: Array[1..5000] of AnsiString;
   def		: Array[1..5000] of AnsiString;
   sws		: Array[1..5000,1..10] of Longint;
   sts		: Array[1..5000,1..10] of Longint;
   ptt		: Array[1..5000,1..10] of Longint;
   ptt_cnt	: Array[1..5000] of Longint;
   wa_sol	: Array['a'..'f'] of AnsiString;
   ts1,ts2	: AnsiString;
Function GetIdx(ts: AnsiString ):Longint;
var
   i : Longint;
Begin
   GetIdx:=0;
   For i:= 1 to n do If LowerCase(ts)=LowerCase(eng[i]) then Exit(i);
End;

Procedure FilterAnalysis;
var
   i,j	: Longint;
   cnt	: Longint;
   mark	: Longint;
Begin
   For i:= 1 to n do Begin
      cnt:=0;
      {For j:= 1 to Length(voca[i]) do If voca[i,j]='.' then Inc(cnt);
      If cnt=0 then WriteLn('Not enough filter @ ',i,' ', voca[i]);
      //If cnt>1 then WriteLn('Too many dots @ ',i,' ',voca[i]);}
      For j:= 1 to Length(voca[i]) do begin
	 If voca[i,j]=' ' then Begin
	    mark:=j;
	    Continue;
	 End;
	 If voca[i,j]='.' then Begin
	    eng[i]:=copy(voca[i],1,mark-1);
	    chn[i]:=copy(voca[i],mark+1,Length(voca[i])-mark);
	    Break;
	 End;	 
      End;
   End;
End;
var
   ch,sol	  : Char;
   idx		  : Longint;
   total,tries	  : Longint;
   iac		  : Boolean;
   wc		  : Longint;
   WrongVoca	  : Array[1..5000] of AnsiString;
   WrongIdx	  : Array[1..5000] of Longint;
   hc		  : Longint;
   HestVoca	  : Array[1..5000] of AnsiString;
   hestIdx	  : Array[1..5000] of Longint;
   IsInReviewList : Array[1..5000] of Boolean;
   ReviewList	  : Array[1..5000] of Longint;
   r_cnt	  : Longint;

Function RandomExcept(i,n:Longint ):Longint;
Begin
   RandomExcept:=Random(n-1)+1;
   If RandomExcept>=i then RandomExcept:=RandomExcept+1;
End;

Procedure AddWV(i :Longint ); {Add a word to Wrong Vocabulary list}
Begin
   Inc(wc);
   WrongVoca[wc]:=Voca[i];
   WrongIdx[wc]:=i;
End;

Procedure AddHV(i :Longint ); {Add a word to Hesitate Vocabulary list}
Begin
   Inc(hc);
   HestVoca[hc]:=Voca[i];
   hestIdx[hc]:=i;
End;

Procedure LoadReview(FileName :AnsiString );
var
   loadf : text;
   i : Longint;
Begin
   If not FileExists(FileName) then Exit;
   Assign(loadf,FileName);
   Reset(loadf);
   ReadLn(loadf,r_cnt);
   For i:= 1 to r_cnt do Begin
      Read(loadf,ReviewList[i]);
      IsInReviewList[ReviewList[i]]:=True;
   End;
   Close(loadf);
End;

Procedure SetReview(FileName :AnsiString );
var
   outf	: text;
   i	: Longint;
   cnt	: Longint;
   tmp	: Array[1..5000] of Longint;
Begin
   cnt:=0;
   Assign(outf,FileName);   
   If FileExists(FileName) then Begin
      Reset(outf);
      ReadLn(outf,cnt);
      For i:= 1 to cnt do Read(outf,tmp[i]);
      Close(outf);
      Assign(outf,FileName);
      ReWrite(outf);
   End
   Else ReWrite(outf);
   WriteLn(outf,hc+wc+cnt);
   For i:= 1 to cnt do Write(outf,tmp[i],' ');
   For i:= 1 to hc do Write(outf,hestIdx[i],' ');
   For i:= 1 to wc do Write(outf,wrongIdx[i],' ');
   Close(outf);
End;

Procedure ResetReview(FileName : AnsiString );
var
   outf	: text;
   i,cnt: Longint;
Begin
   Assign(outf,FileName);
   ReWrite(outf);
   {TBC}
   cnt:=0;
   For i:= 1 to n do If IsInReviewList[i] then Inc(cnt);
   WriteLn(outf,cnt);
   For i:= 1 to n do If IsInReviewList[i] then Write(outf,i,' ');
   Close(outf);
End;

Procedure ResultReport;
var
   i : Longint;
Begin
   WriteLn('Your hard work should be recognized!');
   WriteLn(tries,' attempts to ',total,' words you have done!Your accuracy rate is ',total/tries:3:3);
   If wc>0 then WriteLn('Here''re the ',wc,' words you may mismatch');
   For i:= 1 to wc do WriteLn(WrongVoca[i]);
   If hc>0 then WriteLn('Here''re the ',hc,' words you may feel confused when you face them');
   For i:= 1 to hc do WriteLn(hestVoca[i]);
   SetReview('MemorizerProfile.log');
End;

Function Test(s,t :Longint ):Boolean;
var
   time	: real;
Begin
   Test:=False;
   idx:=random(t-s+1)+s;
   WriteLn(eng[idx]);
   sol:=Char(random(6)+65);
   For ch:= 'A' to 'F' do Begin
      Write(ch,'. ');
      If sol=ch then WriteLn(chn[idx]) Else WriteLn(chn[RandomExcept(idx,n)]);
   End;
   time:=now;
   Inc(total);
   iac:=True;
   ReadLn(ch);
   ch:=UpCase(ch);
   Inc(tries);
   While (ch<>sol) and (ch<>'X') do Begin
      If iac then Begin
	 AddWV(idx);
	 iac:=False;
      End;	 
      WriteLn('WA!');
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
   End;
   If  ch='X' then Begin
      ResultReport;
      Exit(True);
   End;
   WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
   If iac and ((now-time)*86400>=7) then Begin
      AddHV(idx);
   End;
End;

Procedure RangeCheck(s,t :Longint );
var
   time	   : real;
   mapping : Array[1..5000] of Longint;
   i,j,tmp   : Longint;
Begin
   For i:= s to t do mapping[i]:=i;
   For i:= s to t-1 do Begin
      idx:=Random(t-s)+s;
      tmp:=mapping[i];
      mapping[i]:=mapping[idx];
      mapping[idx]:=tmp;
   End;
   For j := s to t do Begin
      idx:=mapping[j];
      WriteLn(eng[idx],'(',j-s+1,'/',t-s+1,')');
      sol:=Char(random(6)+65);
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then WriteLn(chn[idx]) Else WriteLn(chn[RandomExcept(idx,n)]);
      End;
      time:=now;
      Inc(total);
      iac:=True;
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
      While (ch<>sol) and (ch<>'X') do Begin
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA!');
	 ReadLn(ch);
	 ch:=UpCase(ch);
	 Inc(tries);
      End;
      If  ch='X' then Begin
	 ResultReport;
	 Exit;
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>=7) then Begin
	 AddHV(idx);
      End;
   End;
   ResultReport;
End;

Function HellTest(s,t :Longint ):Boolean;
var
   time	: real;
Begin
   HellTest:=False;
   idx:=random(t-s+1)+s;
   WriteLn(eng[idx]);
   sol:=Char(random(6)+65);
   For ch:= 'A' to 'F' do Begin
      Write(ch,'. ');
      If sol=ch then WriteLn(chn[idx]) Else WriteLn(chn[sws[idx,Integer(ch)-64]]);
   End;
   time:=now;
   Inc(total);
   iac:=True;
   ReadLn(ch);
   ch:=UpCase(ch);
   Inc(tries);
   While (ch<>sol) and (ch<>'X') do Begin
      If iac then Begin
	 AddWV(idx);
	 iac:=False;
      End;	 
      WriteLn('WA!');
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
   End;
   If  ch='X' then Begin
      ResultReport;
      Exit(True);
   End;
   WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
   If iac and ((now-time)*86400>=7) then Begin
      AddHV(idx);
   End;
End;

Procedure RangeHellTest(s,t :Longint );
var
   time	   : real;
   mapping : Array[1..5000] of Longint;
   i,j,tmp   : Longint;
Begin
   For i:= s to t do mapping[i]:=i;
   For i:= s to t-1 do Begin
      idx:=Random(t-s)+s;
      tmp:=mapping[i];
      mapping[i]:=mapping[idx];
      mapping[idx]:=tmp;
   End;
   For j := s to t do Begin
      idx:=mapping[j];
      WriteLn(eng[idx],'(',j-s+1,'/',t-s+1,')');
      sol:=Char(random(6)+65);
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then WriteLn(chn[idx]) Else WriteLn(chn[sws[idx,Integer(ch)-64]]);
      End;
      time:=now;
      Inc(total);
      iac:=True;
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
      While (ch<>sol) and (ch<>'X') do Begin
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA! ',chn[sws[idx,Integer(ch)-64]],' means ',eng[sws[idx,Integer(ch)-64]]);
	 ReadLn(ch);
	 ch:=UpCase(ch);
	 Inc(tries);
      End;
      If  ch='X' then Begin
	 ResultReport;
	 Exit;
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>=7) then Begin
	 AddHV(idx);
      End;
   End;
   ResultReport;
End;


Function HellTestCHN(s,t :Longint ):Boolean;
var
   time	   : real;
   mapping : Array[1..5000] of Longint;
   i,j,tmp   : Longint;
Begin
   For i:= s to t do mapping[i]:=i;
   For i:= s to t do Begin
      j:=Random(t-s)+s;
      tmp:=mapping[j];
      mapping[j]:=mapping[i];
      mapping[i]:=tmp;
   End;
   HellTestCHN:=False;
   For i:= s to t do Begin
      idx:=mapping[i];
      WriteLn(chn[idx],'(',i-s+1,'/',t-s+1,')');
      sol:=Char(random(6)+65);
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then WriteLn(eng[idx]) Else WriteLn(eng[sts[idx,Integer(ch)-64]]);
      End;
      time:=now;
      Inc(total);
      iac:=True;
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
      While (ch<>sol) and (ch<>'X') do Begin
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA!');
	 ReadLn(ch);
	 ch:=UpCase(ch);
	 Inc(tries);
      End;
      If  ch='X' then Begin
	 ResultReport;
	 Exit(True);
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>=7) then Begin
	 AddHV(idx);
      End;
   End;
   ResultReport;
End;

Procedure PronounciationCheck(s,t	:Longint );
var
   idx	: Longint;
   time	: real;
   ts	: Ansistring;
   i,j	: Longint;
   flag	: Longint;
label
   1;   
Begin
   Repeat 
      idx:=random(t-s+1)+s;
      Write(chn[idx],'  Hint: ');      
      If ptt_cnt[idx]=1 then Begin
	 For i:= 1 to Length(eng[idx]) do Begin
	    If Random(2)=1 then Write(eng[idx,i]) Else Write('_');
	 End;
      End
      Else Begin
	 flag:=random(ptt_cnt[idx])+1;
	 For i:= 1 to ptt_cnt[idx] do Begin
	    If i<>flag then
	       For j:= ptt[idx,i] to ptt[idx,i+1]-1 do Write(eng[idx,j])
	    Else
	       For j:= ptt[idx,i] to ptt[idx,i+1]-1 do Write('_');
	 End;
      End;
      WriteLn;
      time:=now;
      Inc(total);
      Inc(tries);
      ReadLn(ts);
      iac:=True;
      ts:=LowerCase(ts);
      While (ts<>lowercase(eng[idx])) and (ts<>'x') do Begin
	 If ts='s' then Begin
	    WriteLn('Skipped! Answer:',eng[idx]);
	    If iac then Begin
	       AddWV(idx);
	       iac:=False;

	    End;
	    Goto 1;
	 End;
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA!');
	 ReadLn(ts);
	 Inc(tries);
	 ts:=lowercase(ts);
      End;
      If (ts='x') then begin
	 ResultReport;
	 Exit();
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>14) then Begin
	 AddHV(idx);
      End;
      1:
   Until False;
End;

Function DoReview:Boolean;
var
   time	: real;
   i,idx: Longint;
   ch,sol: Char;
   
Begin
   DoReview:=False;
   idx:=random(r_cnt)+1;
   WriteLn(eng[ReviewList[idx]]);
   sol:=Char(random(6)+65);
   For ch:= 'A' to 'F' do Begin
      Write(ch,'. ');
      If sol=ch then WriteLn(chn[ReviewList[idx]]) Else WriteLn(chn[sws[ReviewList[idx],Integer(ch)-64]]);
   End;
   time:=now;
   Inc(total);
   iac:=True;
   ReadLn(ch);
   ch:=UpCase(ch);
   Inc(tries);
   While (ch<>sol) and (ch<>'X') do Begin
      If iac then Begin
	 AddWV(ReviewList[idx]);
	 iac:=False;
      End;	 
      WriteLn('WA!');
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
   End;
   If  ch='X' then Begin
      ResultReport;
      ResetReview('MemorizerProfile.log');
      Exit(True);
   End;
   WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
   If iac and ((now-time)*86400>=7) then Begin
      AddHV(ReviewList[idx]);
   End
   Else Begin
      IsInReviewList[ReviewList[idx]]:=False;
   End;
End;

Function DoReview_Revised():Boolean;
var
   idx,mode,flag,i,j:Longint;
   sol:Char;
   time: Double;
   Function Generate_Idx(): Longint;
   Begin
      Exit(ReviewList[Random(r_cnt)+1]);
   End;
   Procedure WaitForCorrectAnswer;
   var
      f	 : Boolean;
      //ch : Char;
   Begin
      f:=False;
      Repeat
	 If not f then Begin
	    f:=True;
	 End
	 Else Begin
	    WriteLn('WA!');
	    Case mode of
	       1:WriteLn(chn[sws[idx,Integer(ch)-64]],' means ',eng[sws[idx,Integer(ch)-64]]);
	       2,3:WriteLn(eng[sts[idx,Integer(ch)-64]],' means ',chn[sts[idx,Integer(ch)-64]]);
	    End;
	 End;
         ReadLn(ch);
         ch:=Upcase(ch);
	   
      Until (ch='X') or (ch=sol);
   End;
   Procedure ExTimeFeedback;
   Begin
      If ch<>'X' then 
         WriteLn('AC in ',(now-time)*86400:3:3,'s ' )
      Else Begin
         ResultReport;
      End;
   End;
   Procedure DoReview_ETC();
{   var
      ch : Char;}
   Begin
      WriteLn(eng[idx]);
      For ch:= 'A' to 'F' do Begin
         Write(ch,'. ');
         If sol=ch then WriteLn(chn[idx]) Else WriteLn(chn[sws[idx,Integer(ch)-64]]);
      End;
      Time:=Now;
      WaitForCorrectAnswer;
      ExTimeFeedBack;
   End;
   Procedure DoReview_CTE();
   Begin
      WriteLn(chn[idx]);
      For ch:= 'A' to 'F' do Begin
         Write(ch,'. ');
	 If sol=ch then WriteLn(eng[idx]) Else WriteLn(eng[sts[idx,Integer(ch)-64]]);
      End;
      Time:=Now;
      WaitForCorrectAnswer;
      ExTimeFeedBack;
   End;
   Procedure DoReview_DTW();
   var
      i,j : Longint;
   Begin
      For j:= 1 to Length(def[idx]) do If def[idx,j]=':' then Break;
      For j:= j+1 to Length(def[idx]) do Begin
	 Write(def[idx,j]);
	 If (j>200) and (def[idx,j]=' ') then Begin
	    Write('...');
	    Break;
	 End;	 
      End;
      WriteLn;
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then WriteLn(eng[idx]) Else WriteLn(eng[sts[idx,Integer(ch)-64]]);
      End;	   
      Time:=Now;
      WaitForCorrectAnswer;
      ExTimeFeedBack;
   End;
   Procedure DoReview_PC;
   var
      ts  : AnsiString;
      i,j : Longint;
   Begin
      ts:='';
      Write(chn[idx],'  Hint: ');      
      If ptt_cnt[idx]=1 then Begin
	 For i:= 1 to Length(eng[idx]) do Begin
	    If Random(2)=1 then Write(eng[idx,i]) Else Write('_');
	 End;
      End
      Else Begin
	 flag:=random(ptt_cnt[idx])+1;
	 For i:= 1 to ptt_cnt[idx] do Begin
	    If i<>flag then
	       For j:= ptt[idx,i] to ptt[idx,i+1]-1 do Write(eng[idx,j])
	    Else
	       For j:= ptt[idx,i] to ptt[idx,i+1]-1 do Write('_');
	 End;
      End;
      WriteLn;
      Time:=Now;
      Repeat
	 ReadLn(ts);
	 ts:=LowerCase(ts);
	 If ts='x' then Begin
	   ch:='X';
	   Break;
	 End;
	 If ts='s' then Begin
	    WriteLn('Skipped! Answer: ',eng[idx]);
	    Break;
	 End;
	 If ts<>eng[idx] then WriteLn('WA!');
      Until ts=eng[idx];
      ExTimeFeedback;	   
   End;
Begin
   ch:='Y';
//   While ch<>'X' do Begin
      idx:=generate_idx();
      sol:=Char(random(6)+65);
      mode:=random(4)+1;
      Case mode of
          1:DoReview_ETC;
          2:DoReview_CTE;
          3:DoReview_DTW;
          4:DoReview_PC;
      End;
//   End;
   Exit(False);
End;

Procedure DefinitionToVocabulary(s,t :Longint );
var
   time	   : real;
   mapping : Array[1..5000] of Longint;
   i,j,tmp   : Longint;
Begin
   For i:= s to t do mapping[i]:=i;
   For i:= s to t do Begin
      j:=Random(t-s)+s;
      tmp:=mapping[j];
      mapping[j]:=mapping[i];
      mapping[i]:=tmp;
   End;
   For i:= s to t do Begin
      idx:=mapping[i];
      For j:= 1 to Length(def[idx]) do If def[idx,j]=':' then Break;
      For j:= j+1 to Length(def[idx]) do Begin
	 Write(def[idx,j]);
	 If (j>200) and (def[idx,j]=' ') then Begin
	    Write('...');
	    Break;
	 End;	 
      End;
      WriteLn('(',i-s+1,'/',t-s+1,')');
      sol:=Char(random(6)+65);
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then WriteLn(eng[idx]) Else WriteLn(eng[sts[idx,Integer(ch)-64]]);
      End;
      time:=now;
      Inc(total);
      iac:=True;
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
      While (ch<>sol) and (ch<>'X') do Begin
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA!');
	 ReadLn(ch);
	 ch:=UpCase(ch);
	 Inc(tries);
      End;
      If  ch='X' then Begin
	 ResultReport;
	 Exit;
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>=15) then Begin
	 AddHV(idx);
      End;
   End;
   ResultReport;
End;

Procedure VocabularyToDefinition(s,t :Longint );
var
   time	   : real;
   mapping : Array[1..5000] of Longint;
   i,j,tmp   : Longint;
Begin
   For i:= s to t do mapping[i]:=i;
   For i:= s to t do Begin
      j:=Random(t-s)+s;
      tmp:=mapping[j];
      mapping[j]:=mapping[i];
      mapping[i]:=tmp;
   End;
   For i:= s to t do Begin
      idx:=mapping[i];
      WriteLn(eng[idx]);
      WriteLn('(',i-s+1,'/',t-s+1,')');
      sol:=Char(random(6)+65);
      For ch:= 'A' to 'F' do Begin
	 Write(ch,'. ');
	 If sol=ch then Begin
	    For j:= 1 to Length(def[idx]) do If def[idx,j]=':' then Break;
	    For j:= j+1 to Length(def[idx]) do Begin
	       Write(def[idx,j]);
	       If (j>200) and (def[idx,j]=' ') then Begin
		  Write('...');
		  Break;
	       End;	 
	    End;
	    WriteLn;
	 End
	 Else Begin
	    tmp:=sts[idx,Integer(ch)-64];
	    For j:= 1 to Length(def[tmp]) do If def[tmp,j]=':' then Break;
	    For j:= j+1 to Length(def[tmp]) do Begin
	       Write(def[tmp,j]);
	       If (j>200) and (def[tmp,j]=' ') then Begin
		  Write('...');
		  Break;
	       End;	 
	    End;
	    WriteLn;
	 End;
      End;
      time:=now;
      Inc(total);
      iac:=True;
      ReadLn(ch);
      ch:=UpCase(ch);
      Inc(tries);
      While (ch<>sol) and (ch<>'X') do Begin
	 If iac then Begin
	    AddWV(idx);
	    iac:=False;
	 End;	 
	 WriteLn('WA!');
	 ReadLn(ch);
	 ch:=UpCase(ch);
	 Inc(tries);
      End;
      If  ch='X' then Begin
	 ResultReport;
	 Exit;
      End;
      WriteLn('AC! in ',(now-time)*86400:3:3,' s',tries,' attempt(s) to ',total,' word(s)');
      If iac and ((now-time)*86400>=25) then Begin
	 AddHV(idx);
      End;
   End;
   ResultReport;
End;


var
   mode	   : Longint;
   mds,mdt : Longint;
   {$IFDEF Win32}
   hConsoleOutput:THandle;
   {$ENDIF}
Begin
   {$IFDEF Win32}
   hConsoleOutput:=GetStdHandle(STD_OUTPUT_HANDLE);
   SetConsoleTextAttribute(hConsoleOutput,BACKGROUND_RED or BACKGROUND_GREEN or BACKGROUND_BLUE);
   {$ENDIF}
   
   WriteLn('Copyright (c) 2017 xiaxueqaq @ BUAA Zhizhen College, All Rights Reserved');
   Randomize;
   LoadReview('MemorizerProfile.log');
   Assign(Input,'CET4voca.txt');
   Reset(Input);
   ReadLn(n);
   For i:= 1 to n do Begin
      ReadLn(voca[i]);
   End;
   FilterAnalysis;
   {Assign(Output,'CET4_voca.txt');
   ReWrite(Output);
   i:=1;
   While i<=n do Begin
      If eng[i]<>eng[i+1] then WriteLn(voca[i])
	 Else Begin
	    WriteLn(voca[i],chn[i+1]);
	    Inc(i);
	 End;
      Inc(i);
   End;
   Close(Output);
   Assign(Output,'');
   ReWrite(Output);
   For i:= 1 to n-1 do If eng[i]=eng[i+1] then WriteLn('Duplicate Words: ',eng[i],' @ ',i);
   Close(Output);}   
   
   Close(Input);
   Assign(Input,'English_Definition_Modified.txt');
   Reset(Input);
   For i:= 1 to n do ReadLn(def[i]);
   Close(Input);
   Assign(Input,'CET4SM.txt');
   Reset(Input);
   For i:= 1 to n do ReadLn(sws[i,1],sws[i,2],sws[i,3],sws[i,4],sws[i,5],sws[i,6]);
   Close(Input);
   Assign(Input,'CET4SM_CN.txt');
   Reset(Input);
   For i:= 1 to n do ReadLn(sts[i,1],sts[i,2],sts[i,3],sts[i,4],sts[i,5],sts[i,6]);
   Close(Input);
   Assign(Input,'CET4VocaPartition.txt');
   Reset(Input);
   For i:= 1 to n do Begin
      Read(ptt_cnt[i]);
      For j:= 1 to ptt_cnt[i] do Read(ptt[i,j]);
      ptt[i,ptt_cnt[i]+1]:=Length(eng[i])+1;
      ReadLn;
   End;
   Close(Input);
   total:=0;
   tries:=0;
   wc:=0;
   hc:=0;
   Assign(Input,'');
   Reset(Input);
   WriteLn('1:  Easy English To Chinese;');
   //WriteLn('2:  Easy English To Chinese(ranged);');
   //WriteLn('3:  Easy English To Chinese(All In A Range)');
   WriteLn('4:  Hard English To Chinese');
   //WriteLn('5:  Hard English To Chinese(ranged)');
   WriteLn('6:  Hard English To Chinese From xxxx to yyyy in Dictionary Order');
   WriteLn('7:  Chinese To English');
   WriteLn('8:  Pronunciation Check');
   WriteLn('9:  Find Word Of A Definition');
   //WriteLn('10: Find The Definition Of A Word');
   WriteLn('11: Review Mode');

   ReadLn(mode);
   Case mode of
     1	: Repeat
	     ;
	  Until Test(1,n);
      2	: Begin
	     WriteLn('Hidden Function, may cause confusion: Easy English To Chinese(ranged)');
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     Repeat
	     Until Test(mds,mdt);
	  End;
      3	: Begin
	     WriteLn('Hidden Function, may cause confusion: Easy English To Chinese(All In A Range)');
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     //ReadLn(m3s,m3t);
	     RangeCheck(mds,mdt);
	  End;
      4	: Begin
	     Repeat
	     Until HellTest(1,n);
	  End;
      5	: Begin
	     WriteLn('Hidden Function, may cause confusion: Hard English To Chinese(ranged)');
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     Repeat
	     Until HellTest(mds,mdt);
	  End;
      6	: Begin
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     //ReadLn(m6s,m6t);
	     RangeHellTest(mds,mdt);
	  End;
      7	: Begin
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     HellTestCHN(mds,mdt);
	  End;
      8	: Begin
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);	     
	     PronounciationCheck(mds,mdt);
	  End;
      9	: Begin
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     DefinitionToVocabulary(mds,mdt);
	  End;
      10: Begin
	     WriteLn('Hidden Function, may cause confusion: Find The Definition Of A Word');	     
	     WriteLn('Please input the word you start with:');
	     ReadLn(ts1);
	     mds:=GetIdx(ts1);
	     WriteLn('Please input the word you stop at');
	     ReadLn(ts2);
	     mdt:=GetIdx(ts2);
	     VocabularyToDefinition(mds,mdt);
	  End;
      11: Begin
	     {Repeat
	     Until DoReview;}
	     While True do DoReview_Revised;
	  End;
   End;
   ReadLn;
   {Assign(Output,'CET4VocaCHN.txt');
   ReWrite(Output);
   For i:= 1 to n do WriteLn(Chn[i]);
   Close(Output);}
   {$IFDEF Win32}
   hConsoleOutput:=GetStdHandle(STD_OUTPUT_HANDLE);
   SetConsoleTextAttribute(hConsoleOutput,FOREGROUND_BLUE or FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY);
   {$ENDIF}
   Close(Input);
End.
