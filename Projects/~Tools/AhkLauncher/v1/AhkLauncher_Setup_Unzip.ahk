; TITLE: AhkLauncher_Setup Unzip version
; 
#Requires AutoHotkey >=2.0

#SingleInstance Force
#NoTrayIcon
TraySetIcon('imageres.dll', 250)

; #region Global Variables

ZipFile   := A_ScriptDir '\AhkLauncher_SetupFiles.zip'
ExtractTo := EnvGet('USERPROFILE') . '\Documents\AutoHotkey'

LinkTarget  := EnvGet('USERPROFILE')  . '\Documents\AutoHotkey\AhkLauncher\AhkLauncher.ahk'
LinkStartup := EnvGet('APPDATA')      . '\Microsoft\Windows\Start Menu\Programs\Startup\AhkLauncher.lnk'
LinkMenu    := EnvGet('APPDATA')      . '\Microsoft\Windows\Start Menu\AhkLauncher.lnk'

SplitPath(LinkTarget, , &OutDir)
LinkDir     := OutDir

; #region Create Gui

MyGui := Gui("-AlwaysOnTop", "AhkLauncher Setup v0.1") ; "ToolWindow" does not have tray icon
MyGui.BackColor := "4682B4" ; Steel Blue
MyGui.SetFont("S12 CBlack w480", "Segouie UI")
;SB := MyGui.AddStatusBar()

; Add Buttons to the GUI
;MyGui.AddText("w25 +Hidden")
ButtonInstall := MyGui.AddButton(, "Install")
ButtonUninstall := MyGui.AddButton("yp", "Uninstall")
ButtonHelp := MyGui.AddButton("yp", "HELP")
ButtonCancel := MyGui.AddButton("yp Default", "Cancel")
;MyGui.AddText("yp w25 +Hidden")
;MyLine := MyGui.Add("Text", "xm w320 h1 0x10") ;SS_ETCHEDHORZ
; Filler := MyGui.Add("Button", "xm w24 +Hidden")  ; "x+5 y+5"
; ButtonMovies := MyGui.Add("Button", "yp W110", "📂 Movies")
; ButtonTV := MyGui.Add("Button", "yp W110", "📂 TV")
;~ MyButtonOpt3 := MyGui.Add("Button", "x+m yp W64 Default", "Opt3")

; Assign event handlers
ButtonInstall.OnEvent("Click", ButtonInstall_Click)
ButtonUninstall.OnEvent("Click", ButtonUninstall_Click)
ButtonHelp.OnEvent("Click", ButtonHelp_Click)
ButtonCancel.OnEvent("Click", ButtonCancel_Click)
; ButtonMovies.OnEvent("Click", ButtonMovies_Click)
; ButtonTV.OnEvent("Click", ButtonTV_Click)
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

  ; remove files
  if DirExist(LinkDir)
    DirDelete(LinkDir, true)

  r := MsgBox("Uninstall complete.", "Uninstall", "OK Icon!")


}
ButtonInstall_Click(Ctrl, Info) {

  r := MsgBox("This will install all files and create a shortcut in the user startup folder. Proceed?", "Uninstall", "YesNo Icon?")

  if (r = "No")
    return

    ; check if zip file exists

  if !FileExist('AhkLauncher_SetupFiles.zip') {
    MsgBox("Setup files not found:`n`nAhkLauncher_SetupFiles.zip", "Error", "OK IconX")
    return
  }

  ; unzip the files

  r := Unzip(ZipFile, ExtractTo)

  if r == false {
    MsgBox("Error unzipping files", "Error", "OK IconX")
    return
  }
  
  ; create shortcut
  ;MsgBox(LinkTarget '`n`n' . LinkStartup . '`n`n' . LinkDir)

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
   
  } catch Error as e {
    MsgBox("Error creating shortcut:`n`n" e.Message, "Error", "OK IconX")
    return
  }
 
  ; run now?

  r := MsgBox("Setup Complete, Launch Now?", "Complete", "YesNo")

  if (r = "Yes") {
    Run(LinkStartup)
  }

  ;WriteStatus("Setup Complete.")

}

ButtonCancel_Click(Ctrl, Info) {
 ExitApp()
}

; WriteStatus(Text){
;  SB.SetText(StrRepeat(" ", 5) . Text)
; }

; StrRepeat(text, times) {
;  return StrReplace(Format("{:" times "}", ""), " ", text)
; }

Unzip(ZipPath, DestFolder)
{
    ; Check if the source ZIP file exists
    if !FileExist(ZipPath) {
        MsgBox 'Error: Zip file not found: ' ZipPath
        return false
    }

    ; Ensure the destination folder exists, create it if it doesn't
    DirCreate(DestFolder)
    
    ; Create the Shell.Application COM object
    try
        psh := ComObject('Shell.Application')
    catch
        return false ; Failed to create COM object

    ; Get the objects for the destination folder and the zip file
    DestNamespace := psh.Namespace(DestFolder)
    ZipNamespace := psh.Namespace(ZipPath)

    ; Copy the items from the zip file to the destination folder
    ; The '1024' (or 4|16) represents flags for the CopyHere method:
    ; 4 = Do not display a progress dialog box.
    ; 16 = Respond with "Yes to All" for any file conflict.
    ; This makes the operation non-interactive.
    DestNamespace.CopyHere(ZipNamespace.Items, 4 | 16)
    
    ; Note: The COM method is asynchronous (runs in the background), 
    ; but for simple scripts, it often completes before the script ends.
    ; For complex applications, you might need extra code to ensure completion.
    return true
}
ButtonHelp_Click(Ctrl, Info) {

helpText := "
(

The AutoHotkey Launcher was created to avoid false antivirus messages.  All files are .ahk scripts and are installed with user privileges.

Press [Install] and the following is performed.
----------------------------------------------------------------------

1.  Unzip AhkLauncher_SetupFiles.zip to: %USERPROFILE%\Documents\AutoHotkey\AhkLauncer

2. Create AhkLauncher.lnk in: %APPDATA%'\Microsoft\Windows\Start Menu\Programs\Startup\AhkLauncher.lnk'

3. Ask the user to "Launch Now?"

Press [Uninstall] to:
----------------------------------------------------------------------

1. Remove all files.

2. Nothing was created in the Windows Registry, so no cleanup required.

)"
    MsgBox(helpText, "AUTOHOTKEY LAUNCHER SETUP HELP")

}


