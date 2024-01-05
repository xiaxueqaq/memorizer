Program WordPartition;
Const
   lvl_recession : double = 22.71;//22.71=27*0.8413
   maxlength		  = 20;
   eps			  = 1e-6;
Type
   pdouble = ^double;

var
   n,i,j    : Longint;
   eng	    : Array[1..1080000] of AnsiString;
   cnt	    : Array['A'..'Z','@'..'Z','@'..'Z','@'..'Z'] of Longint;
   ps	    : Array['A'..'Z','@'..'Z','@'..'Z','@'..'Z'] of Double;
   total    : Longint;
   t_cnt    : Longint;
   test_set : Array[1..5000] of AnsiString;
   err	    : text;

Function IsVowel(ch :Char ):Boolean;
Begin
   IsVowel:=False;
   If (ch='A') or (ch='E') or (ch='I') or (ch='O') or (ch='U') or (ch='Y') then IsVowel:=True;
End;

Procedure PossibilityCalc;
var
   i,j	       : Longint;
   c1,c2,c3,c4 : Char;
Begin
   For i:= 1 to n do {if (i<>253) and (i<>1551) and
      (i<>1173) and (i<>1545) and (i<>1847) and (i<>1853) and (i<>2613) and (i<>2970) and (i<>3209) and
      (i<>3446) and (i<>3448) and (i<>3559) and (i<>3593) and (i<>3607) then }Begin
      For j:= 1 to Length(eng[i]) do Begin
	 If j<=Length(eng[i])-3 then Inc(cnt[eng[i,j],eng[i,j+1],eng[i,j+2],eng[i,j+3]]);
	 If j<=Length(eng[i])-2 then Inc(cnt[eng[i,j],eng[i,j+1],eng[i,j+2],'@']);
	 If j<=Length(eng[i])-1 then Inc(cnt[eng[i,j],eng[i,j+1],'@','@']);
	 Inc(cnt[eng[i,j],'@','@','@']);
      End;
   End;
   For c1:= 'A' to 'Z' do
      For c2:= '@' to 'Z' do
	 For c3:= '@' to 'Z' do
	    For c4:= '@' to 'Z' do Begin
	       ps[c1,c2,c3,c4]:=cnt[c1,c2,c3,c4]/lvl_recession;
	       If IsVowel(c1) and IsVowel(c3) then ps[c1,c2,c3,c4]:=0;
	       If IsVowel(c2) and IsVowel(c4) then ps[c1,c2,c3,c4]:=0;
	       If IsVowel(c1) and IsVowel(c4) then ps[c1,c2,c3,c4]:=0;
	       If (not(IsVowel(c1))) and (not(IsVowel(c2))) and (not(IsVowel(c3))) and (not(IsVowel(c4))) then ps[c1,c2,c3,c4]:=0;
	    End;
   For c1:= 'A' to 'Z' do
      For c2:= '@' to 'Z' do
	 For c3:= '@' to 'Z' do ps[c1,c2,c3,'@']:=ps[c1,c2,c3,'@']/lvl_recession;
   For c1:= 'A' to 'Z' do
      For c2:= '@' to 'Z' do ps[c1,c2,'@','@']:=ps[c1,c2,'@','@']/lvl_recession;
   For c1:= 'A' to 'Z' do ps[c1,'@','@','@']:=ps[c1,'@','@','@']/lvl_recession;

End;
var
   Exp	      : Array[1..maxlength,1..maxlength] of Double;
   OptimumCut : Array[1..maxlength,1..maxlength] of Longint;
   ts	      : AnsiString;
Procedure DFS(s,t: Longint );
var
   i : Longint;
Begin
   If Exp[s,t]<>0 then Exit;
   If (s=t) then Begin
      Exp[s,t]:=ps[ts[s],'@','@','@'];
      Exit;
   End;
   If (s+1=t) then Begin
      exp[s,t]:=ps[ts[s],ts[s+1],'@','@'];      
   End;
   If (s+2=t) then Begin
      exp[s,t]:=ps[ts[s],ts[s+1],ts[s+2],'@'];
   End;
   If (s+3=t) then Begin
      exp[s,t]:=ps[ts[s],ts[s+1],ts[s+2],ts[s+3]];
   End;
   For i:= s to t-1 do Begin
      DFS(s,i);DFS(i+1,t);
      If exp[s,i]*exp[i+1,t]>exp[s,t] then Begin
	 exp[s,t]:=exp[s,i]*exp[i+1,t];
	 OptimumCut[s,t]:=i;
      End;
   End;   
End;

var
   bsrr_cnt : Longint;
   bsrr	    : Array[1..maxlength] of Longint;

Procedure BSR(l,r :Longint );{Best Solution Restructure}
var
   i : Longint;
Begin
   If OptimumCut[l,r]=0 then Begin
      //For i:= l to r do Write(ts[i]);
      Inc(bsrr_cnt);
      bsrr[bsrr_cnt]:=l;
      //Write(' ');
      Exit;
   End;
   BSR(l,OptimumCut[l,r]);
   BSR(OptimumCut[l,r]+1,r);
End;

Function GetPointer(l,r	:Longint ):pdouble;
var
   tmpstr : AnsiString;
   i	  : Longint;
Begin
   tmpstr:='';
   For i:= l to r do
      tmpstr:=tmpstr+ts[i];
   For i:= 1 to 4-(r-l+1) do tmpstr:=tmpstr+'@';
   GetPointer:=@ps[tmpstr[1],tmpstr[2],tmpstr[3],tmpstr[4]];
   //WriteLn('Adjust ',tmpstr);   
End;

Procedure AdjustPs(source,target : pdouble);
Begin
   If target^>eps then Begin
      source^:=source^/2;
      target^:=target^+source^;
   End;
End;

Procedure Solve;
var
   i,j : Longint;
Begin
   For i:= 1 to maxlength do
      For j:= 1 to maxlength do Begin
	 exp[i,j]:=0;
	 OptimumCut[i,j]:=0;
      End;
   bsrr_cnt:=0;
   
   DFS(1,Length(ts));
   BSR(1,Length(ts));
   bsrr[bsrr_cnt+1]:=Length(ts)+1;
   //WriteLn;
   i:=1;
   While i<= bsrr_cnt do Begin      
      If (bsrr[i]=Length(ts)) and (ts[bsrr[i]]='E') then Begin
	 Dec(bsrr_cnt);
	 AdjustPs(GetPointer(bsrr[i-1],bsrr[i]-1),GetPointer(bsrr[i-1],bsrr[i]));
	 Break;
      End;
      If (bsrr[i]<>1) and IsVowel(ts[bsrr[i]]) and (not IsVowel(ts[bsrr[i]-1])) then Begin
	 AdjustPs(GetPointer(bsrr[i-1],bsrr[i]-1),GetPointer(bsrr[i-1],bsrr[i]));
	 AdjustPs(GetPointer(bsrr[i],bsrr[i+1]-1),GetPointer(bsrr[i]+1,bsrr[i+1]-1));
	 Dec(bsrr[i]);
      End;
      If (bsrr[i]<>1) and IsVowel(ts[bsrr[i]-1]) and (ts[bsrr[i]]='A') then Begin
	 For j:= i to bsrr_cnt do bsrr[j]:=bsrr[j+1];
	 Dec(bsrr_cnt);
      End;
      If (bsrr[i]<>1) and IsVowel(ts[bsrr[i]-1]) and (ts[bsrr[i]]='E') then Begin
	 For j:= i to bsrr_cnt do bsrr[j]:=bsrr[j+1];
	 Dec(bsrr_cnt);
      End;
      If (bsrr[i]<>Length(ts)) and ((ts[bsrr[i]]='M') or (ts[bsrr[i]]='N')) and (not IsVowel(ts[bsrr[i]+1])) then Begin
	 AdjustPs(GetPointer(bsrr[i-1],bsrr[i]-1),GetPointer(bsrr[i-1],bsrr[i]));
	 AdjustPs(GetPointer(bsrr[i],bsrr[i+1]-1),GetPointer(bsrr[i]+1,bsrr[i+1]-1));
	 Inc(bsrr[i]);
      End;
      If (bsrr[i]<>1) and (ts[bsrr[i]]='H') and ((ts[bsrr[i]-1]='C') or (ts[bsrr[i]-1]='G') or (ts[bsrr[i]-1]='P') or (ts[bsrr[i]-1]='S') or (ts[bsrr[i]-1]='T') or (ts[bsrr[i]-1]='W')) then Begin

	 AdjustPs(GetPointer(bsrr[i-1],bsrr[i]-1),GetPointer(bsrr[i-1],bsrr[i]));
	 AdjustPs(GetPointer(bsrr[i],bsrr[i+1]-1),GetPointer(bsrr[i]+1,bsrr[i+1]-1));
	 Dec(bsrr[i]);
      End;
						    
	 
      Inc(i);
   End;
   For i:= 1 to bsrr_cnt-1 do Begin
      For j:= bsrr[i] to bsrr[i+1]-1 do Write(err,ts[j]); Write(err,' ');
   End;
   For j:= bsrr[bsrr_cnt] to Length(ts) do Write(err,ts[j]);WriteLn(err);
   Write(bsrr_cnt,' ');
   For i:= 1 to bsrr_cnt do Write(bsrr[i],' '); WriteLn;
End;

Procedure RawMaterialProcess(txt :AnsiString );
var
   ch : Char;
   f  : Boolean;
Begin
   Assign(Input,txt);
   Reset(Input);
   Assign(Output,'NewMaterial.txt');
   //ReWrite(Output);
   Append(Output);
   While not eof(input) do Begin
      While not eoln(input) do Begin
	 Read(ch);
	 If ((ch>='A') and (ch<='Z')) or ((ch>='a') and (ch<='z')) then Begin
	    Write(ch);
	    f:=true;
	 End
	 Else if f then Begin
	    WriteLn;
	    f:=False;
	 End;
      End;
      ReadLn;
   End;
   Close(Output);
   Close(Input);
End;

Procedure SavePossibility(txt :AnsiString );
var
   c1,c2,c3,c4 : Char;
Begin
   Assign(output,txt);
   ReWrite(output);
   For c1:= 'A' to 'Z' do
      For c2:= '@' to 'Z' do
	 For c3:= '@' to 'Z' do
	    For c4:= '@' to 'Z' do
	       Write(ps[c1,c2,c3,c4]:5:5,' ');
   Close(Output);
End;

Procedure LoadPossibility(txt :AnsiString );
var
   c1,c2,c3,c4 : Char;
Begin
   Assign(Input,txt);
   Reset(Input);
   
   For c1:= 'A' to 'Z' do
      For c2:= '@' to 'Z' do
	 For c3:= '@' to 'Z' do
	    For c4:= '@' to 'Z' do
	       Read(ps[c1,c2,c3,c4]);
   Close(Input);
End;

var
   c1,c2 : Char;
Begin
   Assign(err,'wordpartition.log');
   ReWrite(err);
   {Assign(Input,'NewMaterial.txt');
   Reset(Input);
   ReadLn(n);
   total:=0;
   For i:= 1 to n do Begin
      ReadLn(eng[i]);
      eng[i]:=UpCase(eng[i]);
      Inc(total,Length(eng[i]));
   End;
   PossibilityCalc;
   
   Close(Input);}
   LoadPossibility('Possibility.txt');
   {For c1:= 'A' to 'Z' do Write(c1,ps[c1,'@','@','@']:5:5);
   WriteLn;
   For c1:= 'A' to 'Z' do Begin
      For c2:= 'A' to 'Z' do Write(c1,c2,ps[c1,c2,'@','@']:5:5,' ');
      WriteLn;
   End;}
   n:=3619;
   Assign(Input,'CET4VocaPartition.txt');
   Reset(Input);
   For i:= 1 to n do Begin
      ReadLn(test_set[i]);
   End;
   Close(Input);
   //RawMaterialProcess('bible.txt');
   Assign(Input,'CET4VocaEng.txt');
   Reset(Input);
   Assign(Output,'CET4VocaPartition.txt');
   //Assign(Output,'');
   ReWrite(Output);
   ReadLn(t_cnt);
   For i:= 1 to t_cnt do Begin      
      ReadLn(ts);
      if (i<>253) and (i<>1551) and
      (i<>1173) and (i<>1545) and (i<>1847) and (i<>1853) and (i<>2613) and (i<>2970) and (i<>3209) and
      (i<>3446) and (i<>3448) and (i<>3559) and (i<>3593) and (i<>3607) then Begin
	 ts:=UpCase(ts);
	 Solve;
      End
      Else WriteLn(test_set[i]);
      
   End;
   {Assign(Input,'');
   Reset(Input);
   Assign(Output,'');
   ReWrite(Output);
   ReadLn(ts);
   ts:=UpCase(ts);
   Solve;
   //WriteLn(ps['B','L','U','E'],cnt['B','L','U','E']);}
   
   {test here}
   Close(Output);
   Close(Input);
   SavePossibility('Possibility.txt');
   Close(err);
End.
