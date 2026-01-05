
; User Provided Information
;#define MyAppFilePath "D:\Software\DEV\Work\AHK2\Projects\CopyVS\CopyVS.exe"
#define MyAppFilePath ".\CopyVS.exe"
#define MyAppIconPath ".\CopyVS.ico"
#define MyAppId       "{{06B12894-ED34-4E96-9446-7314025B2170}}"
#define MyAppURL      "https://github.com/jasc2v8"
#define MyOutputDir   "."

; builtin defines: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss
#define MyAppName GetFileDescription(MyAppFilePath)           ; My Application     ; Assembly.Product
#define MyAppExeName GetFileOriginalFilename(MyAppFilePath)   ; MyApplication.exe  ; Assembly.Title
#define MyAppFileName RemoveFileExt(MyAppExeName)             ; MyApplication
#define MyAppPublisher GetFileCompany(MyAppFilePath)          ; My Company         ; Assembly.Company
#define MyAppCopyright GetFileCopyright(MyAppFilePath)        ; Copyright @ 2025   ; Assembly.Copyright
#define MyAppVersion GetFileProductVersion(MyAppFilePath)     ; 1.0.0              ; Assembly.AssemblyVersion
#define MyAppVersionInfo GetFileProductVersion(MyAppFilePath) ; 1.0.0              ; Assembly.ProductVersion

[Setup]
;PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={commonpf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
Compression=lzma2
SolidCompression=yes
OutputDir={#MyOutputDir}
OutputBaseFilename={#MyAppFileName}_setup_v{#MyAppVersion}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Installer Version Information
VersionInfoVersion={#MyAppVersion}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Installer for {#MyAppName}
VersionInfoCopyright={#MyAppCopyright}
VersionInfoProductName={#MyAppName} Setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: {#MyAppFilePath}; DestDir: "{app}"; Flags: ignoreversion
;Source: My Project.exe.config; DestDir: "{app}"; Flags: ignoreversion
;Source: Ini.Net.dll; DestDir: "{app}"; Flags: ignoreversion
;NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe};
;Name: {group}\readme; Filename: {app}\readme.txt;
;Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
;Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}" ; WorkingDir: "{app}"; Tasks: desktopicon
;Name: "{commonstartup}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;

[Code]
var
  MyVariable: String;
  FilesFound: Integer;
  FindRec: TFindRec;
  
begin
  FilesFound := 0;
  //if FindFirst(ExpandConstant('{sys}\*'), FindRec) then
  if FindFirst('*.exe', FindRec) then
  begin
    try
      repeat
        // Don't count directories
        if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY = 0 then
          FilesFound := FilesFound + 1;
      until not FindNext(FindRec);
    finally
      FindClose(FindRec);
    end;
  end;
  MsgBox(IntToStr(FilesFound) + ' files found in the System directory.', mbInformation, MB_OK)
end.
