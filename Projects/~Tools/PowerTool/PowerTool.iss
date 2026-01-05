
; This file intended to be used with AhkSetupBuilder
; Re-Run MyApp.iss with Inno to compile MyApp.exe into MyApp_setup.exe

; Builtin source: https://github.com/jrsoftware/issrc/blob/main/Files/ISPPBuiltins.iss
; -------------------------------------------------------------------------------------------------------------
#define MyAppFilePath     "D:\Software\DEV\Work\AHK2\Projects\PowerTool\PowerTool.exe"		           
#define MyAppIconPath     "D:\Software\DEV\Work\AHK2\Projects\PowerTool\PowerTool.ico"		       
#define MyAppName         "PowerTool.exe"           
#define MyAppNameNoExt    "PowerTool" 
#define MyAppPublisher    "jasc2v8"      
#define MyCompanyName     "jasc2v8"		         
#define MyFileDescription "Power Control Tool"    
#define MyFileVersion     "1.0.0.0"        
#define MyInternalName    "PowerTool" 
#define MyLanguage        "English (United States)"           
#define MyLegalCopyright  "©2025 jasc2v8"          
#define MyLegalTrademark  "%LegalTrademarks%"    
#define MyInnoId          "{{B4292E30-2FBD-4C82-9EFC-B01AEC0B52F2}}"						 
#define MyOutputDir       "D:\Software\DEV\Work\AHK2\Projects\PowerTool"	       
#define MyOutputFilename  "PowerTool_setup_v1.0.0.0"	   
#define MyProductName     "PowerTool"        
#define MyProductVersion  "1.0.0.0"     

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

