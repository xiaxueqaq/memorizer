Program STA;
Const
   ins	    = 1;
   rep	    = 1;
   del	    = 1;
var
   dp	    : Array[0..50,0..50] of Longint;
   dist,idx : Array[1..5000] of Longint;
   voca	    : Array[1..5000] of AnsiString;
   sws	    : Array[1..5000,1..10] of Longint;
   i,j,n    : Longint;
   target   : Longint;
   ch,ch2   : AnsiChar;
   vis	    : Array[1..5000] of Boolean;
Procedure Calc(x,y: Longint );
var
   i,j: Longint;
Begin
   dp[0,0]:=0;
   For i:= 1 to Length(voca[x]) do dp[i,0]:=i*ins;
   For i:= 1 to Length(voca[y]) do dp[0,i]:=i*del;
   For i:= 1 to Length(voca[x]) do
      For j:= 1 to Length(voca[y]) do Begin
	 dp[i,j]:=MaxLongint;
	 If dp[i,j]>dp[i-1,j]+ins then dp[i,j]:=dp[i-1,j]+ins;
	 If dp[i,j]>dp[i,j-1]+del then dp[i,j]:=dp[i,j-1]+del;
	 If voca[x,i]=voca[y,j] then
	    If dp[i,j]>dp[i-1,j-1] then dp[i,j]:=dp[i-1,j-1]
	       Else
	       Else If dp[i,j]>dp[i-1,j-1]+rep then dp[i,j]:=dp[i-1,j-1]+rep;
	    
      End;
   dist[y]:=dp[Length(voca[x]),Length(voca[y])];
End;
Procedure Sort(l,r :Longint );
var
   t,i,j : Longint;
Begin
   If (l>=r) then Exit;
   i:=l-1;
   For j:= l to r-1 do Begin
      if Dist[j]<=Dist[r] then Begin
	 Inc(i);
	 t:=Dist[j];
	 Dist[j]:=Dist[i];
	 Dist[i]:=t;
	 t:=idx[i];
	 idx[i]:=idx[j];
	 idx[j]:=t;	 
      End;
   End;
   t:=Dist[r];
   Dist[r]:=Dist[i+1];
   Dist[i+1]:=t;
   t:=idx[r];
   idx[r]:=idx[i+1];
   idx[i+1]:=t;
   Sort(l,i);
   Sort(i+2,r);
End;
Procedure StringSort(x,l,r :Longint );
var
   i,j : Longint;
   t   : AnsiChar;
Begin
   If (l>=r) then Exit;
   i:=l-1;
   For j:= l to r-1 do Begin
      if Ord(Voca[x,j])<=Ord(Voca[x,r]) then Begin
	 Inc(i);
	 t:=Voca[x,j];
	 Voca[x,j]:=Voca[x,i];
	 Voca[x,i]:=t;
      End;
   End;
   t:=Voca[x,r];
   Voca[x,r]:=Voca[x,i+1];
   Voca[x,i+1]:=t;
   StringSort(x,l,i);
   StringSort(x,i+2,r);
End;
Procedure Solve(x  : Longint );
var
   i,j : Longint;
Begin
   For i:= 1 to n do Begin
      dist[i]:=MaxLongint;
      idx[i]:=i;
   End;
   For i:= 1 to n do Calc(x,i);
   Sort(1,n);
End;
function IsHZ(ch: AnsiChar): boolean; 
begin   
   If Ord(ch)<=127 then Begin
      Exit(False)
   End
   Else Exit(True);
end;
Function max(a,b :Longint ):Longint;
Begin
   If a>b then Exit(a) else Exit(b);
End;
var
   dcnt,swcnt : Longint;
Begin
   Assign(Input,'CET4VocaCHN.txt');;
   Reset(Input);
   ReadLn(n);
   For i:= 1 to n do Begin
      voca[i]:='';
      While not eoln(Input) do Begin
	 Read(ch);
	 Write(ch);
	 If IsHZ(ch) then voca[i]:=voca[i]+ch;
      End;
      //StringSort(i,1,Length(voca[i]));
      ReadLn;
      WriteLn(voca[i]);
   End;
   Close(Input);
   Assign(Input,'CET4SM.txt');
   Reset(Input);
   For i:= 1 to n do ReadLn(sws[i,1],sws[i,2],sws[i,3],sws[i,4],sws[i,5],sws[i,6]);
   Close(Input);
   {Assign(Output,'CET4VocaCHN.txt');
   ReWrite(Output);
   For i:= 1 to n do WriteLn(voca[i]);
   Close(Output);}
   Assign(Input,'');
   Reset(Input);
   Assign(Output,'CET4SM_CN.txt');
   ReWrite(Output);   
   For i:= 1 to n do Begin
      swcnt:=1;
      dcnt:=2;
      For j:= 1 to 5000 do Vis[j]:=False;
      Solve(i);
      j:=2;
      For j:= 2 to 7 do Begin
	 While vis[idx[dcnt]] do Inc(dcnt);
	 If dist[dcnt]<= max(Length(voca[i]),Length(voca[idx[dcnt]])) div 2 then Begin	    
	    Write(idx[dcnt],' ');
	    vis[idx[dcnt]]:=True;
	    Inc(dcnt);
	 End
	 Else Begin
	    While vis[sws[i,swcnt]] do Inc(swcnt);
	    Write(sws[i,swcnt],' ');
	    vis[sws[i,swcnt]]:=True;
	    Inc(swcnt);
	 End;
      End;
      WriteLn;
   End;
   Close(Output);
   {ReadLn(Target);
   
   Solve(Target);
   For i:= 2 to 6 do WriteLn('One of the most similar words of ',Voca[Target],' is ',voca[idx[i]],' the distance is ',dist[i]);}
   Close(Input);
End.
