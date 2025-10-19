
; This file intended to be used with AhkSetupBuilder

;AhkBuilder defines 											; Examples
#define MyAppFilePath "%MyAppFilePath%"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.exe"
#define MyAppIconPath "%MyAppIconPath%"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.ico"
#define MyAppId "%MyAppId%"							  ; "{{06B12894-ED34-4E96-9446-7314025B2170}}" (Installer not exe)
#define MyOutputDir "%MyOutputDir%"	      ; "D:\Software\DEV\Work\AHK2\Projects\MyApp"
#define MyAppPublisher "%MyAppPublisher%" ; My Company Name (optionally used for start menu group folder)

; builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss

; builtin defines:                                                ; Example:              ; Inno Setup
; ----------------------------------------------------------------;-----------------------;------------------------
#define MyAppFullName     GetFileDescription(MyAppFilePath)       ; My Application Setup  ; File Description
#define MyAppExeName      GetFileOriginalFilename(MyAppFilePath)  ; MyApplication.exe  		; Product Name
#define MyAppNameNoExt    RemoveFileExt(MyAppExeName)             ; MyApplication         ; MyApplication
#define MyAppCopyright    GetFileCopyright(MyAppFilePath)         ; Copyright @ 2025			; Copyright
#define MyProductVersion  GetFileProductVersion(MyAppFilePath)    ; Product (setup.exe)		; Product Version (series in setup.exe)
#define MyFileVersion     GetFileVersionString(MyAppFilePath)     ; File (MyAppExeName)		; File Version (in MyApp.exe)
; for this all files version
#define MyAppDir ExtractFileDir(MyAppFilePath)                    ; D:\Dir

[Setup]
;PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Application settings
AppId={#MyAppId}
AppName={#MyAppFullName}
AppVersion={#MyProductVersion}
AppPublisher={#MyAppPublisher}

; Application URLs
;AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyAppFullName}
;DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppFullName}
DefaultGroupName={#MyAppFullName}
DisableProgramGroupPage=no

; Output settings
Compression=lzma2
SolidCompression=yes
OutputDir={#MyOutputDir}
OutputBaseFilename={#MyAppNameNoExt}_setup_v{#MyFileVersion}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Installer Version Information
VersionInfoCompany={#MyAppPublisher}
VersionInfoVersion={#MyFileVersion}
VersionInfoProductVersion={#MyProductVersion}
VersionInfoDescription=Installer for {#MyAppFullName}
VersionInfoCopyright={#MyAppCopyright}
VersionInfoProductName={#MyAppFullName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: {#MyAppDir}\*; DestDir: "{app}"; Flags: ignoreversion

[Tasks]
Name: desktopicon; Description: "Create a &Desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked
Name: quicklaunchicon; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}";
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe};
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall unchecked skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;
