
; User Provided Information

;AhkBuilder defines 											; examples
#define MyAppFilePath "%MyAppFilePath%"		; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.exe"
#define MyAppId "%MyAppId%"							  ; "{{06B12894-ED34-4E96-9446-7314025B2170}}" (Installer not exe)
#define MyOutputDir "%MyOutputDir%"	      ; "D:\Software\DEV\Work\AHK2\Projects\MyApp"
#define MyAppIconPath "%MyAppIconPath%"      ; "D:\Software\DEV\Work\AHK2\Projects\MyApp\MyApp.ico"

; builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss

; builtin defines:                                            ; Example:              ; Visual Studio 2022:			  ; Inno Setup
; ------------------------------------------------------------;-----------------------;---------------------------;------------------------
#define MyAppName GetFileDescription(MyAppFilePath)           ; My Application Setup  ; Assembly.Product					; File Description
#define MyAppExeName GetFileOriginalFilename(MyAppFilePath)   ; MyApplication.exe  		; Product Name							; Product Name
#define MyAppFileName RemoveFileExt(MyAppExeName)             ; MyApplication
#define MyAppCopyright GetFileCopyright(MyAppFilePath)        ; Copyright @ 2025			; Assembly.Copyright				; Copyright
#define MyAppVersion GetFileProductVersion(MyAppFilePath)     ; 1.0.0              		; Assembly.AssemblyVersion  ; File Version (exe)
#define MyAppVersionInfo GetFileProductVersion(MyAppFilePath) ; 1.0.0              		; Assembly.ProductVersion		; Product Version (series)
#define MyAppDir ExtractFileDir(MyAppFilePath)                ; D:\Dir

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
DisableProgramGroupPage=yes

; Output settings
Compression=lzma2
SolidCompression=yes
OutputDir={#MyOutputDir}
OutputBaseFilename={#MyAppFileName}_setup_v{#MyAppVersion}
SetupIconFile={#MyAppIconPath}
UninstallDisplayIcon={#MyAppIconPath}

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
