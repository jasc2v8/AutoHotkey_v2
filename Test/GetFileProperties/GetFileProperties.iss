
; This file intended to be used with AhkSetupBuilder
; Once the file MyApp.exe is compiled into MyApp_setup.exe, you can edit and re-run the MyApp.iss file standalone 

;AhkBuilder defines 											; Examples
#define MyAppFilePath "D:\Software\DEV\Work\AHK2\Projects\GetFileProperties\GetFileProperties.exe"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.exe"
#define MyAppIconPath "D:\Software\DEV\Work\AHK2\Projects\GetFileProperties\GetFileProperties.ico"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.ico"
#define MyAppId "{{8D2C2750-0620-4B47-9BAA-A66368292E8D}}}"							  ; "{{06B12894-ED34-4E96-9446-7314025B2170}}" (Installer not exe)
#define MyOutputDir "D:\Software\DEV\Work\AHK2\Projects\GetFileProperties"	      ; "D:\Software\DEV\Work\AHK2\Projects\MyApp"
#define MyAppPublisher "AhkApps" ; My Company Name (optionally used for start menu group folder)

; builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss

; builtin defines:                                                ; Example:              ; Inno Setup
; ----------------------------------------------------------------;-----------------------;------------------------
#define MyAppFullName     GetFileDescription(MyAppFilePath)       ; My Application Setup  ; File Description
#define MyAppExeName      GetFileOriginalFilename(MyAppFilePath)  ; MyApplication.exe  		; Product Name
#define MyAppNameNoExt    RemoveFileExt(MyAppExeName)             ; MyApplication         ; MyApplication
#define MyAppCopyright    GetFileCopyright(MyAppFilePath)         ; Copyright @ 2025			; Copyright
#define MyProductVersion  GetFileProductVersion(MyAppFilePath)    ; Product (setup.exe)		; Product Version (series in setup.exe)
#define MyFileVersion     GetFileVersionString(MyAppFilePath)     ; File (MyAppExeName)		; File Version (in MyApp.exe)

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
Source: {#MyAppFilePath}; DestDir: "{app}"; Flags: ignoreversion
;Source: Ini.Net.dll.config; DestDir: "{app}"; Flags: ignoreversion
;NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Tasks]
Name: desktopicon; Description: "Create a &Desktop icon"; GroupDescription: "Additional icons:"; Flags: unchecked
Name: quicklaunchicon; Description: "Create a &Quick Launch icon"; GroupDescription: "Additional icons:"; Flags: unchecked

[Icons]
Name: "{group}\{#MyAppFullName}"; Filename: "{app}\{#MyAppExeName}"
Name: {group}\{cm:UninstallProgram,{#MyAppFullName}}; Filename: {uninstallexe};
Name: "{autodesktop}\{#MyAppFullName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppFullName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;
