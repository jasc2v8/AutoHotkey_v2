; -- CodeExample1.iss --
;
; This script shows various things you can achieve using a [Code] section.

[Setup]
AppName=My Program
AppVersion=1.5
WizardStyle=modern
DisableWelcomePage=no
DefaultDirName='.\My Program'
DefaultGroupName=My Program
UninstallDisplayIcon={app}\MyProg.exe
InfoBeforeFile=build.bat
OutputDir=userdocs:Inno Setup Examples Output

[Files]
//Source: "MyProg.exe"; DestDir: "{app}"; Check: MyProgCheck; BeforeInstall: BeforeMyProgInstall('MyProg.exe'); AfterInstall: AfterMyProgInstall('MyProg.exe')
//Source: "MyProg.chm"; DestDir: "{app}"; Check: MyProgCheck; BeforeInstall: BeforeMyProgInstall('MyProg.chm'); AfterInstall: AfterMyProgInstall('MyProg.chm')
//Source: "Readme.txt"; DestDir: "{app}"; Flags: isreadme

[Icons]
//Name: "{group}\My Program"; Filename: "{app}\MyProg.exe"

[Code]
var
  FilesFound: Integer;
  FindRec: TFindRec;
  //
  FindHandle: THandle;
  FindData: TFindRec;
  ListBox: TNewListBox;
  
procedure ListExeFiles();
begin
  // Create a new list box
  ListBox := TNewListBox.Create(WizardForm);
  ListBox.Parent := WizardForm;
  ListBox.Top := 10;
  ListBox.Left := 10;
  ListBox.Width := 300;
  ListBox.Height := 200;
  ListBox.Visible := True;

  // Find the first .exe file
  if FindFirst(ExpandConstant('*.exe'), FindRec) then
  begin
    MsgBox('exe file found: ' + FindRec.Name, mbInformation, MB_OK);
    FindClose(FindRec); // Always close the find handle
  end;
end;

procedure CountSystemFiles();
begin
  FilesFound := 0;
  // Start searching in the Windows System directory for all files
  if FindFirst(ExpandConstant('{sys}\*'), FindRec) then
  begin
    try
      repeat
        // Check if the found item is not a directory
        if (FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
        begin
          FilesFound := FilesFound + 1;
        end;
      until not FindNext(FindRec); // Continue until no more files are found
    finally
      FindClose(FindRec); // Always close the find handle
    end;
  end;
  MsgBox(IntToStr(FilesFound) + ' files found in the System directory.', mbInformation, MB_OK);
end;

function InitializeSetup(): Boolean;
begin
  CountSystemFiles();
  //ListExeFiles();
  Result := False; //exit before setup
end;
