
; This file intended to be used with AhkSetupBuilder
; Re-Run MyApp.iss with Inno to compile MyApp.exe into MyApp_setup.exe

; Builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss

; Builtin defines:                                    ; Example:              ; Inno Setup
; ----------------------------------------------------;-----------------------;------------------------
#define MyCompanyName     "%MyCompanyName%"		        ; My Company Inc.
#define MyFileDescription "%MyFileDescription%"       ; My Custom Application
#define MyFileVersion  "   %MyFileVersion%"           ; 1.0.0.0 Product Version (series in Installer setup.exe)
#define MyProductVersion  "%MyProductVersion%"        ; 1.0.0.0 Product Version (series in Installer setup.exe)
#define MyInternalName    "%MyProductVersion%"        ; Typically same as MyAppName NoExt
#define MyLanguage        "%MyLanguage%"              ; Not used. Manually edit this scrip in the [Languages] section
#define MyLegalCopyright  "%MyLegalCopyright%"        ; Copyright ©2025	Not used, can be added to %MyFileDescription% or %MyAppPublisher%
#define MyLegalTrademark  "%MyLegalTrademark%"        ; MY TRADEMARK™	
#define MyAppExeName      "%MyOriginalFilename%"      ; MyApp.exe 
#define MyProductName     "%MyProductName%"           ; MyCustomApp
#define MyAppFilePath     "%MyAppFilePath%"		        ; "X:\Dir\SubDir\MyApp\MyApp.exe"
#define MyAppIconPath     "%MyAppIconPath%"		        ; "X:\Dir\SubDir\MyApp\MyApp.ico"
#define MyAppPublisher    "%MyAppPublisher%"          ; My Company Name (optionally used for start menu group folder)
#define MyAppNameNoExt    "%MyAppNameNoExt%"          ; MyCustomApp
#define MyInnoId          "%MyInnoId%"						    ; "{{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}}" (Installer setup exe, not MyApp.exe)
#define MyOutputDir       "%MyOutputDir%"	            ; "X:\Dir\SubDir\MyApp"

[Setup]
;PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Application settings
AppId={#MyInnoId}
AppName={#MyFileDescription}
AppVersion={#MyProductVersion}
AppPublisher={#MyAppPublisher}
AppCopyright={#MyLegalCopyright}

; Application URLs
;AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyFileDescription}
;DefaultDirName={autopf}\{#MyAppPublisher}\{#MyFileDescription}
DefaultGroupName={#MyFileDescription}
DisableProgramGroupPage=no

; Output settings
Compression=lzma2
SolidCompression=yes
OutputDir={#MyOutputDir}
;OutputBaseFilename={#MyAppNameNoExt}_setup_v{#MyFileVersion}
OutputBaseFilename={#MyAppNameNoExt}_setup_v{#MyProductVersion}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Installer Version Information
VersionInfoCompany={#MyAppPublisher}
VersionInfoVersion={#MyFileVersion}
VersionInfoProductVersion={#MyProductVersion}
VersionInfoDescription=Installer for {#MyFileDescription}
VersionInfoCopyright={#MyLegalCopyright}
VersionInfoProductName={#MyFileDescription}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: {#MyAppFilePath}; DestDir: "{app}"; Flags: ignoreversion
;Source: Ini.Net.dll.config; DestDir: "{app}"; Flags: ignoreversion
;NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Tasks]
Name: desktopicon; Description: "Create a &Desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked
Name: quicklaunchicon; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Icons]
Name: "{group}\{#MyFileDescription}"; Filename: "{app}\{#MyAppExeName}"
Name: {group}\{cm:UninstallProgram,{#MyFileDescription}}; Filename: {uninstallexe};
Name: "{autodesktop}\{#MyFileDescription}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyFileDescription, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;
