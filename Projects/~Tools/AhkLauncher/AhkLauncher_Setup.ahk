; TITLE: AhkLauncher_Setup initial version
/**
 * AhkLauncher
 * 
 * 
 */
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('imageres.dll', 250)

; #region Global Variables

ZipFile   := A_ScriptDir '\AhkLauncher_SetupFiles.zip'
ExtractTo := EnvGet('USERPROFILE') . '\Documents\AutoHotkey'

LinkTarget  := EnvGet('USERPROFILE')  . '\Documents\AutoHotkey\AhkLauncher\AhkLauncher.ahk'
LinkSetup  := EnvGet('USERPROFILE')  . '\Documents\AutoHotkey\AhkLauncher\AhkLauncher_Setup.ahk'
LinkStartup := EnvGet('APPDATA')      . '\Microsoft\Windows\Start Menu\Programs\Startup\AhkLauncher.lnk'
LinkMenu    := EnvGet('APPDATA')      . '\Microsoft\Windows\Start Menu\AhkLauncher.lnk'
LinkMenuSetup := EnvGet('APPDATA')      . '\Microsoft\Windows\Start Menu\AhkLauncher_Setup.lnk'

SplitPath(LinkTarget, , &OutDir)
LinkDir     := OutDir

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "Setup AhkLauncher v0.1") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")
;SB := MyGui.AddStatusBar()

; Add Buttons to the GUI
ButtonInstall := MyGui.AddButton(, "Install")
ButtonUninstall := MyGui.AddButton("yp", "Uninstall")
ButtonHelp := MyGui.AddButton("yp", "Help")
ButtonCancel := MyGui.AddButton("yp Default", "Cancel")

; Assign event handlers
ButtonInstall.OnEvent("Click", ButtonInstall_Click)
ButtonUninstall.OnEvent("Click", ButtonUninstall_Click)
ButtonHelp.OnEvent("Click", ButtonHelp_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
MyGui.OnEvent("Close", (*) => ExitApp())

; Show the GUI
MyGui.Show()

; #region Functions

ButtonUninstall_Click(Ctrl, Info) {

  r := MsgBox("This will remove all installation files. Proceed?", "Uninstall", "YesNo Icon!")

  if (r = "No")
    return

  ; remove shortcuts
  if FileExist(LinkStartup)
    FileDelete(LinkStartup)

  if FileExist(LinkMenu)
    FileDelete(LinkMenu)

  if FileExist(LinkMenuSetup)
    FileDelete(LinkMenuSetup)

  ; terminate AhkLauncher.ahk so it can be deleted
  SetTitleMatchMode('1') ; starts with
  DetectHiddenWindows(true)
  pid := WinGetPID('AhkLauncher v')
  if (pid != 0)
    ProcessClose(pid)

  ; remove files
  if DirExist(LinkDir)
    DirDelete(LinkDir, true)

  r := MsgBox("Uninstall complete.", "Uninstall", "OK Icon!")

  ExitApp

}

ButtonInstall_Click(Ctrl, Info) {

  r := MsgBox("This will install all files and create shortcuts in the user startup" .
    " and start menu folders.`n`nProceed?", "Install", "YesNo Icon?")

  if (r = "No")
    return

  ; check if the launcher file exists
  if !FileExist('AhkLauncher.ahk') {
    MsgBox("File not found:`n`nAhkLauncher.ahk", "Error", "OK IconX")
    return
  }

  ; check if the setup files exist
  if !DirExist('.\AhkApps') {
    MsgBox("Folder not found: AhkApps", "Error", "OK IconX")
    return
  }

  ; copy the files
  try {
    DirCopy('..\AhkLauncher', LinkDir, 1)  
  } catch Error as e {
    MsgBox("Error copying files:`n`n" e.Message, "Error", "OK IconX")
    return
  }

  ; create shortcuts

  WorkingDir  := LinkDir
  Args        := ''
  Description := '' ; default will show target location
  IconFile    := 'imageres.dll'
  ShortcutKey := ''
  IconNumber  := 250
  RunState    := 1

  try {

    FileCreateShortcut(LinkTarget, LinkStartup, WorkingDir, Args, Description, 
      IconFile, ShortcutKey, IconNumber, RunState)

    FileCreateShortcut(LinkTarget, LinkMenu, WorkingDir, Args, Description, 
      IconFile, ShortcutKey, IconNumber, RunState)

    FileCreateShortcut(LinkSetup, LinkMenuSetup, WorkingDir, Args, Description, 
      IconFile, ShortcutKey, IconNumber, RunState)

  } catch Error as e {
    MsgBox("Error creating shortcut:`n`n" e.Message, "Error", "OK IconX")
    return
  }
 
  ; run now?

  r := MsgBox("Setup Complete, Launch Now?", "Complete", "YesNo")

  if (r = "Yes") {
    Run(LinkMenu)
  }

}

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

ButtonHelp_Click(Ctrl, Info) {

helpText := "
(
The AutoHotkey Launcher was created to avoid false antivirus messages.  All files are .ahk scripts and are installed with user privileges. Therefore, antivirus programs don't report false positives.

# Prerequistes:

1. Search for Default Apps, file type .ahk
2. Set default as AutoHotkey 64-bit (or your preference).
3. This will enable .ahk scripts to run when double-clicked.

# Instructions:

1. Extrack AhkLauncher_SetupFiles.zip to: .\AhkLauncher_SetupFiles
2. Double-Click AhkLauncher_Setup to begin the installation process.
3. AhkLauncher_Setup expects all setup files to be in the same folder.

# Press [Install] to:

1. Copy all setup files to: %USERPROFILE%\Documents\AutoHotkey\AhkLauncer
2. Create Startup Shortcut: %APPDATA%'\Microsoft\Windows\Start Menu\Programs\Startup\AhkLauncher.lnk'
3. Create Start Menu Shortcut: %APPDATA%'\Microsoft\Windows\Start Menu\Programs\AhkLauncher.lnk'
4. Ask the user to "Launch Now?"

# Press [Uninstall] to:

1. Remove all shortcuts.
2. Remove all files.
2. Nothing was created in the Windows Registry, no cleanup required.
)"
    MsgBox(helpText, "AUTOHOTKEY LAUNCHER SETUP HELP")

}


