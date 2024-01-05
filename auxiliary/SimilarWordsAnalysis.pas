Program SMA;
Const
   ins = 1;
   rep = 1;
   del = 1;
var
   dp	  : Array[0..50,0..50] of Longint;
   dist,idx  : Array[1..5000] of Longint;
   voca	  : Array[1..5000] of AnsiString;
   i,j,n	  : Longint;
   target : Longint;
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
Begin
   Assign(Input,'CET4VocaEng.txt');;
   Reset(Input);
   ReadLn(n);
   For i:= 1 to n do Begin
      ReadLn(voca[i]);
   End;   
   Close(Input);
   Assign(Input,'');
   Reset(Input);
   Assign(Output,'CET4SM.txt');
   ReWrite(Output);   
   For i:= 1 to n do Begin
      Solve(i);
      For j:= 2 to 7 do Write(idx[j],' ');
      WriteLn;
   End;
   Close(Output);
   {ReadLn(Target);
   
   Solve(Target);
   For i:= 2 to 6 do WriteLn('One of the most similar words of ',Voca[Target],' is ',voca[idx[i]],' the distance is ',dist[i]);}
   Close(Input);
End.
