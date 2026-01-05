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
  MyCustomPage: TWizardPage;
  MyTextBox: TNewEdit;

procedure CreateMyTextBoxPage;
begin
  // Create a new wizard page
  MyCustomPage := CreateCustomPage(wpWelcome, 'My Text Box Page', 'Enter some text below:');

  // Create the text box and set its parent to the new page
  MyTextBox := TNewEdit.Create(WizardForm);
  MyTextBox.Parent := MyCustomPage.Surface;
  MyTextBox.Left := ScaleX(10);
  MyTextBox.Top := ScaleY(10);
  MyTextBox.Width := ScaleX(300);
  MyTextBox.Height := ScaleY(25);
  MyTextBox.Text := 'This is a text box.';
  MyTextBox.Visible := True;
end;

procedure InitializeWizard;
begin
  // Call the procedure to create the custom page and text box
  CreateMyTextBoxPage;
  Exit;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  // Check if the current page is our custom page
  if CurPageID = MyCustomPage.ID then
  begin
    // Display the text box content
    MsgBox('You entered: ' + MyTextBox.Text, mbInformation, MB_OK);
  end;

  // Always return True to allow the wizard to proceed
  Result := True;
end;