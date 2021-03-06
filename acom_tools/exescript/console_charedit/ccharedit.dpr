program ccharedit;

{$APPTYPE CONSOLE}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, login, character, ComCtrls,
  StdCtrls, ExtCtrls;

var
  f: TMemoryStream;
  c: TCharacter;
  ce: TCharacterEntry;
  l: TLogin;
  logmask: String;
  filelist: TStringList;
  i: Integer;
  j: Integer;
  k: Integer;
  ic: Integer;
  item: TItem;
  currentlgn: String;

procedure FindAll (const Path: String;
                          Attr: Integer;
                          List: TStrings) ;
var
   Res: TSearchRec;
   EOFound: Boolean;
begin
   EOFound:= False;
   if FindFirst(Path, Attr, Res) < 0 then
     exit
   else
     while not EOFound do begin
       List.Add(Res.Name) ;
       EOFound:= FindNext(Res) <> 0;
     end;
   FindClose(Res) ;
end;

function MakeNick(nick: String; clan: String) : String;
var
  name: String;
begin
  name := nick;
  if(Length(clan) > 0) then name := nick+'|'+clan;
  CharToOem(PChar(name), PChar(name));
  Result := name;
end;

begin

logmask := '0123456789abcdefghijklmnopqrstuvwxyz';

writeln('Console Charedit v1.3 / Charedit v2.04a');
writeln('(c) 2010-2011 ZZYZX; (c) 2004-2008 ex-Lend');

if((ParamCount=0) or ((ParamCount=1) and (ParamStr(1)='help'))) then begin
  writeln('Usage: ', ParamStr(0), ' <action> [parameter1] [parameter2] ...');
  writeln;
  writeln('  Actions:');
  writeln('  help       - show this text');
  writeln('  fixs       - set main skill to bludgeon or earth');
  writeln('               parameter 1: path to chr_base directory');
  writeln('  wipe       - wipe all items from character database');
  writeln('               parameter 1: path to chr_base directory');
  writeln('  wipechar   - wipe all characters from database');
  writeln('               parameter 1: path to chr_base directory');
  writeln('  listgm     - find and list GM characters');
  writeln('               parameter 1: path to chr_base directory');
  writeln('  unlock     - unlock all locked logins');
  writeln('               parameter 1: path to chr_base directory');
end else if(ParamCount=1) then begin
{none actions without parameters do exist for now}
end else begin
  if((ParamStr(1)='fixs') and (ParamCount=2)) then begin
  for i:=1 to Length(logmask) do begin
    filelist := TStringList.Create;
    FindAll(ParamStr(2)+'\'+logmask[i]+'\*.lgn', faAnyFile, filelist);
    for j:=0 to filelist.Count-1 do begin
      currentlgn := ParamStr(2)+'\'+logmask[i]+'\'+filelist.Strings[j];
      if(fileexists(currentlgn)) then begin
        writeln('Found file ', currentlgn, ', processing...');
        l := TLogin.Create;
        l.LoadFromFile(currentlgn);
        if not l.IsError then begin
          for k:=0 to l.CharList.Count-1 do begin
            c := TCharacter.Create;
              c.LoadFromStream(TCharacterEntry(l.CharList.Items[k]).Entry);
              if not c.IsError then begin
                if((c.UnknownValue1<1) or (c.UnknownValue1>4)) then begin
                  if((c.Sex=128) or (c.Sex=0)) then
                    c.UnknownValue1 := 3; // ������
                  if((c.Sex=64) or (c.Sex=192)) then
                    c.UnknownValue1 := 4; // �����
                end;
                c.SaveToStream(TCharacterEntry(l.CharList.Items[k]).Entry);
              end;
            c.Free;
          end;
          l.SaveToFile(currentlgn);
        end;
        l.Free;
      end;
    end;
    filelist.Free;
  end;
  end else if((ParamStr(1)='wipe') and (ParamCount=2)) then begin
  for i:=1 to Length(logmask) do begin
    filelist := TStringList.Create;
    FindAll(ParamStr(2)+'\'+logmask[i]+'\*.lgn', faAnyFile, filelist);
    for j:=0 to filelist.Count-1 do begin
      currentlgn := ParamStr(2)+'\'+logmask[i]+'\'+filelist.Strings[j];
      if(fileexists(currentlgn)) then begin
        writeln('Found file ', currentlgn, ', processing...');
        l := TLogin.Create;
        l.LoadFromFile(currentlgn);
        if not l.IsError then begin
          for k:=0 to l.CharList.Count-1 do begin
            c := TCharacter.Create;
              c.LoadFromStream(TCharacterEntry(l.CharList.Items[k]).Entry);
              if not c.IsError then begin
                c.Bag.Clear;
                item := TItem.Create;
                for ic:=0 to c.Dress.Count-1 do begin
                  TItem(c.Dress.Items[ic]).Assign(item);
                end;
                item.Free;
                c.SaveToStream(TCharacterEntry(l.CharList.Items[k]).Entry);
              end;
            c.Free;
          end;
          l.SaveToFile(currentlgn);
        end;
        l.Free;
      end;
    end;
    filelist.Free;
  end;
  end else if((ParamStr(1)='wipechar') and (ParamCount=2)) then begin
  for i:=1 to Length(logmask) do begin
    filelist := TStringList.Create;
    FindAll(ParamStr(2)+'\'+logmask[i]+'\*.lgn', faAnyFile, filelist);
    for j:=0 to filelist.Count-1 do begin
      currentlgn := ParamStr(2)+'\'+logmask[i]+'\'+filelist.Strings[j];
      if(fileexists(currentlgn)) then begin
        writeln('Found file ', currentlgn, ', processing...');
        l := TLogin.Create;
        l.LoadFromFile(currentlgn);
        if not l.IsError then l.CharList.Clear;
        l.SaveToFile(currentlgn);
        l.Free;
      end;
    end;
    filelist.Free;
  end;
  end else if((ParamStr(1)='listgm') and (ParamCount=2)) then begin
  for i:=1 to Length(logmask) do begin
    filelist := TStringList.Create;
    FindAll(ParamStr(2)+'\'+logmask[i]+'\*.lgn', faAnyFile, filelist);
    for j:=0 to filelist.Count-1 do begin
      currentlgn := ParamStr(2)+'\'+logmask[i]+'\'+filelist.Strings[j];
      if(fileexists(currentlgn)) then begin
        {writeln('Found file ', currentlgn, ', processing...');
        // �� ��������� ����� ������� }
        l := TLogin.Create;
        l.LoadFromFile(currentlgn);
        if not l.IsError then begin
          for k:=0 to l.CharList.Count-1 do begin
            c := TCharacter.Create;
              c.LoadFromStream(TCharacterEntry(l.CharList.Items[k]).Entry);
              if not c.IsError then begin
                if(c.Id2 and $3F000000 = $3F000000) then
                  writeln('GM login: ', currentlgn, ' nickname: ', makeNick(c.Nick, c.Clan));
                end;
            c.Free;
          end;
        end;
        l.Free;
      end;
    end;
    filelist.Free;
  end;
  end else if((ParamStr(1)='unlock') and (ParamCount=2)) then begin
  for i:=1 to Length(logmask) do begin
    filelist := TStringList.Create;
    FindAll(ParamStr(2)+'\'+logmask[i]+'\*.lgn', faAnyFile, filelist);
    for j:=0 to filelist.Count-1 do begin
      currentlgn := ParamStr(2)+'\'+logmask[i]+'\'+filelist.Strings[j];
      if(fileexists(currentlgn)) then begin
        {writeln('Found file ', currentlgn, ', processing...');
        // �� ��������� ����� ������� }
        l := TLogin.Create;
        l.LoadFromFile(currentlgn);
        if not l.IsError then begin
          if l.Locked = 1 then begin
             l.Locked := 0;
             writeln('Unlocking login '+currentlgn);
          end;
        end;
        l.SaveToFile(currentlgn);
        l.Free;
      end;
    end;
    filelist.Free;
  end;
  end;
end;

end.
