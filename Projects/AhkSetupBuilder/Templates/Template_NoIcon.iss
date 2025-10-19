
; This file intended to be used with AhkSetupBuilder
; Re-Run MyApp.iss with Inno to compile MyApp.exe into MyApp_setup.exe

; Builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss
; -------------------------------------------------------------------------------------------------------------
#define MyAppFilePath     "%Path%"		           ; X:\Dir\SubDir\MyCustomApp\MyCustomApp.exe
#define MyAppIconPath     "" ;"%Icon_Path%"		       ; X:\Dir\SubDir\MyCustomApp\MyCustomApp.ico
#define MyAppName         "%Filename%"           ; MyCustomApp.exe 
#define MyAppNameNoExt    "%FileName_NameNoExt%" ; MyCustomApp
#define MyAppPublisher    "%App_Publisher%"      ; My Company Name (Optionally used for start menu group folder)
#define MyCompanyName     "%Company%"		         ; My Company Inc.
#define MyFileDescription "%FileDescription%"    ; My Custom Application
#define MyFileVersion     "%FileVersion%"        ; 1.0.0.0 (File Version of MyCustomApp.exe)
#define MyInternalName    "%FileName_NameNoExt%" ; Typically same as MyAppName NoExt
#define MyLanguage        "%Language%"           ; Not used. Manually edit this scrip in the [Languages] section
#define MyLegalCopyright  "%Copyright%"          ; Copyright ©2025	Not used, can be added to %MyFileDescription% or %MyAppPublisher%
#define MyLegalTrademark  "%LegalTrademarks%"    ; MY TRADEMARK™	
#define MyInnoId          "%Inno_Id%"						 ; {{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}} (Installer setup exe, not MyApp.exe)
#define MyOutputDir       "%Output_Dir%"	       ; X:\Dir\SubDir\MyApp
#define MyOutputFilename  "%Output_Filename%"	   ; MyCustomApp_v1.0.0.0.exe
#define MyProductName     "%ProductName%"        ; MyCustomApp
#define MyProductVersion  "%ProductVersion%"     ; 1.0.0.0 (Product Version of Installer setup.exe, typicall same as File version)

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
OutputBaseFilename={#MyOutputFilename}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={app}\{#MyAppName}

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
Name: "{group}\{#MyFileDescription}"; Filename: "{app}\{#MyAppName}"
Name: {group}\{cm:UninstallProgram,{#MyFileDescription}}; Filename: {uninstallexe};
Name: "{autodesktop}\{#MyFileDescription}"; Filename: "{app}\{#MyAppName}"; Tasks: desktopicon
;Name: "{userstartup}\{#MyFileDescription}"; Filename: "{app}\{#MyAppName}"

[Run]
Filename: "{app}\{#MyAppName}"; Description: "{cm:LaunchProgram,{#StringChange(MyFileDescription, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;
