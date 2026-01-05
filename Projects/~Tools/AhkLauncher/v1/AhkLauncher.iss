
; This file intended to be used with AhkSetupBuilder
; Re-Run MyApp.iss with Inno to compile MyApp.exe into MyApp_setup.exe

; Builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss
; -------------------------------------------------------------------------------------------------------------
#define MyAppFilePath     "D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe"		           
#define MyAppIconPath     "" ;"D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.ico"		       
#define MyAppName         "AhkLauncher.exe"           
#define MyAppNameNoExt    "AhkLauncher" 
#define MyAppPublisher    "jasc2v8"      
#define MyCompanyName     "jasc2v8"		         
#define MyFileDescription "AutoHotkey Launcher"    
#define MyFileVersion     "0.0.0.1746"        
#define MyInternalName    "AhkLauncher" 
#define MyLanguage        "English (United States)"           
#define MyLegalCopyright  "©2025 jasc2v8"          
#define MyLegalTrademark  "NONE™"    
#define MyInnoId          "{{D28D9A2A-ED03-443E-B8C1-EDB4F54B293E}}"						 
#define MyOutputDir       "D:\Software\DEV\Work\AHK2\Projects\AhkLauncher"	       
#define MyOutputFilename  "AhkLauncher_setup_v0.0.0.1746"	   
#define MyProductName     "AhkLauncher"        
#define MyProductVersion  "0.0.0.1"     

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

