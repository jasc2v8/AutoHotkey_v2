
; User Provided Information

;AhkBuilder defines 											; examples
#define MyAppFilePath "D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder.exe"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.exe"
#define MyAppIconPath "D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder\AhkSetupBuilder.ico"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.ico"
#define MyAppId "{{B7D1FB29-B701-4010-8DEA-A5477C60C76D}}"							  ; "{{06B12894-ED34-4E96-9446-7314025B2170}}" (Installer not exe)
#define MyOutputDir "D:\Software\DEV\Work\AHK2\Projects\AhkSetupBuilder"	      ; "D:\Software\DEV\Work\AHK2\Projects\MyApp"

; builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss

; builtin defines:                                            ; Example:              ; Visual Studio 2022:			  ; Inno Setup
; ------------------------------------------------------------;-----------------------;---------------------------;------------------------
#define MyAppName GetFileDescription(MyAppFilePath)           ; My Application Setup  ; Assembly.Product					; File Description
#define MyAppExeName GetFileOriginalFilename(MyAppFilePath)   ; MyApplication.exe  		; Product Name							; Product Name
#define MyAppFileName RemoveFileExt(MyAppExeName)             ; MyApplication
#define MyAppCopyright GetFileCopyright(MyAppFilePath)        ; Copyright @ 2025			; Assembly.Copyright				; Copyright
#define MyAppVersion GetFileProductVersion(MyAppFilePath)     ; 1.0.0              		; Assembly.AssemblyVersion  ; File Version (exe)
#define MyAppVersionInfo GetFileProductVersion(MyAppFilePath) ; 1.0.0              		; Assembly.ProductVersion		; Product Version (series)

[Setup]
;PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Application settings
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppPublisher={#MyAppPublisher}

; Application URLs
;AppPublisherURL={#MyAppURL}
;AppSupportURL={#MyAppURL}
;AppUpdatesURL={#MyAppURL}

DefaultDirName={autopf}\{#MyAppName}
;DefaultDirName={autopf}\{#MyAppPublisher}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=no

; Output settings
Compression=lzma2
SolidCompression=yes
OutputDir={#MyOutputDir}
OutputBaseFilename={#MyAppFileName}_setup_v{#MyAppVersion}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={app}\{#MyAppExeName}

; Installer Version Information
;VersionInfoCompany={#MyAppPublisher}
VersionInfoVersion={#MyAppVersion}
VersionInfoProductVersion={#MyAppVersion}
VersionInfoDescription=Installer for {#MyAppName}
VersionInfoCopyright={#MyAppCopyright}
VersionInfoProductName={#MyAppName} Setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: {#MyAppFilePath}; DestDir: "{app}"; Flags: ignoreversion
;Source: Ini.Net.dll.config; DestDir: "{app}"; Flags: ignoreversion
;NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: {group}\{cm:UninstallProgram,{#MyAppName}}; Filename: {uninstallexe};
;Name: {group}\readme; Filename: {app}\readme.txt;
;Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
;Name: "userdesktop\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}" ; WorkingDir: "{app}"; Tasks: desktopicon
;Name: "userdesktop\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; \
  Flags: nowait postinstall skipifsilent runascurrentuser

[UninstallDelete]
Name: {app}; Type: dirifempty;
