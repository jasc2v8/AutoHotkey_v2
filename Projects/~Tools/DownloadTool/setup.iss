
; User Provided Information
#define MyAppFilePath "DownloadControlTool.exe"
#define MyAppIconPath "dct.ico"
#define MyAppId       "{{185193B9-CF37-4333-9AA1-D89FA30D5DF9}}
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
function InitializeSetup(): Boolean;
begin
  MyVariable := '{#MyAppName}';
  //MsgBox('DEBUG value: ' + MyVariable, mbInformation, MB_OK);
  Result := True;
end;
