; -- CodeExample1.iss --
;
; This script shows various things you can achieve using a [Code] section.

//#define MyAppName 'My Application'

#ifndef MyAppName
  #define MyAppName "My App (Default)"
#endif

#ifndef MyAppVersion
  #define MyAppVersion "1.0"
#endif

[Setup]
//disable the UAC for this example. Default is admin
PrivilegesRequired=lowest

//AppName=My Program
AppName={#MyAppName}
AppVersion={#MyAppVersion}
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
  //
  MyAppName: String;
  MyAppVersion: String;
  
procedure ListExeFiles(AppName: String);
begin
  // Create a new list box
  ListBox := TNewListBox.Create(WizardForm);
  ListBox.Parent := WizardForm;
  ListBox.Top := 10;
  ListBox.Left := 10;
  ListBox.Width := 300;
  ListBox.Height := 200;
  ListBox.Visible := True;

  MyAppName    := '{#MyAppName}';
  MyAppVersion := '{#MyAppVersion}';
  
  // Find the first .exe file
  if FindFirst('D:\Software\DEV\Work\AHK2\Projects\CopyVS\*.exe', FindRec) then
  begin
    //MsgBox('exe file found: ' + FindRec.Name, mbInformation, MB_OK);
    Log('=> exe file found: ' + FindRec.Name);
    Log('=> AppName: ' + MyAppName);
    Log('=> MyAppVersion: ' + MyAppVersion);
    MsgBox('AppName: ' + MyAppName, mbInformation, MB_OK);
    MsgBox('MyAppVersion: ' + MyAppVersion, mbInformation, MB_OK);
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
  //CountSystemFiles();
  ListExeFiles('{#MyAppName}');
  Result := False; // exit before setup
end;
