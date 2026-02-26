; TITLE  :  VSCodeSaveVersion v1.1.0.12
; SOURCE :  jasc2v8 and https://www.autohotkey.com/boards/viewtopic.php?t=102798
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Saves the AHK script in VSCode as the current or a new version: 1.0.0.0 becomes 1.0.0.1
; NOTES  :  Scans the script for all occurrences of the file version X.X.X.X
;           Increments build version by one. Example: 1.0.0.0 becomes 1.0.0.1
;           Replace all occurrences of the file version whith the new version
;           Options to copy to Lib or Apps folder.

#Requires AutoHotkey 2+
#SingleInstance Force

;if VSCode not active then return
if !WinActive("ahk_exe Code.exe")
    return

; User changeable
vsCodePath  := EnvGet("LOCALAPPDATA") "\Programs\Microsoft VS Code\Code.exe"
ahkLibDir   := EnvGet("USERPROFILE") "\Documents\AutoHotkey\Lib\"
ahkAppsDir  := EnvGet("USERPROFILE") "\Documents\AutoHotkey\AhkLauncher\AhkApps\"

TraySetIcon(vsCodePath)

; #region GUI Create

MyGuiTitle := "VSCodeSaveVersion v1.1.0.11"
MyGui := Gui("+AlwaysOnTop", MyGuiTitle )
MyGui.BackColor := "72A0C1" ; AirSuperiorityBlue
MyGui.SetFont("S10", "Segoe UI")

ButtonSaveAs     := MyGui.AddButton("ym w75 h50 Default", "Save Copy As")
ButtonSaveAsNew  := MyGui.AddButton("yp w75 h50", "Save Copy As New")
ButtonCopyToLib  := MyGui.AddButton("yp w75 h50", "Copy To`n Lib")
ButtonCopyToApps := MyGui.AddButton("yp w75 h50", "Copy To`n Apps")
buttonCancel     := MyGui.AddButton("yp w75 h50", "Cancel")

; #region Button Handlers

ButtonSaveAs.OnEvent("Click", ButtonSaveAs_Click)
ButtonSaveAsNew.OnEvent("Click", ButtonSaveAsNew_Click)
ButtonCopyToLib.OnEvent("Click", ButtonCopyToLib_Click)
ButtonCopyToApps.OnEvent("Click", ButtonCopyToApps_Click)
buttonCancel.OnEvent("Click", (*) => ExitApp())

; #region Gui Show

MyGui.Show("Hide")
MyGui.Move(50,50)
MyGui.Show()

; #region Functions

ButtonSaveAs_Click(Ctrl, Info) {
    SaveVersion(IncrementVersion:=false)
}
ButtonSaveAsNew_Click(Ctrl, Info) {
    SaveVersion(IncrementVersion:=true)    
}
ButtonCopyToLib_Click(Ctrl, Info) {
    WinActivate("ahk_exe Code.exe")
    CopyToDir(ahkLibDir)
    WinActivate(MyGui.Hwnd)
}
ButtonCopyToApps_Click(Ctrl, Info) {
    WinActivate("ahk_exe Code.exe")
    CopyToDir(ahkAppsDir)
    WinActivate(MyGui.Hwnd)
}

CopyToDir(TargetDir) {
        
    ScriptPath := GetScriptPath()

    buttonPress:= MsgBox("Copy:`n`n"  ScriptPath "`n`nto:`n`n" TargetDir, "Copy", "YesNo Icon?")

    if (buttonPress="Yes") {

        SplitPath(ScriptPath,  &filename)

        newPath := Trim(TargetDir, "\") "\" filename

        if FileExist(newPath) {
            buttonPress:= MsgBox("Overwrite existing file?", "Copy", "YesNo Icon?")
            if (buttonPress="Yes")
            FileCopy(ScriptPath, newPath, Overwrite:=true)
        } else {
            FileCopy(ScriptPath, newPath)
        }
        MsgBox("File:`n`n" ScriptPath "`n`nCopied To:`n`n" newPath, "Success", "Iconi")
    }
}

SaveVersion(IncrementVersion:=false) {

    WinActivate("ahk_exe Code.exe")

    ; Extract the Script Title from the Window Title: "SaveAsVersion.ahk - SaveAsVersion - Visual Studio Code"
    ; \S+	Matches one or more non-whitespace characters. This includes letters, numbers, and symbols, but stops as soon as it hits a space, tab, or newline.
    ; \.	Matches a literal dot. In RegEx, a plain . is a wildcard, so the backslash \ is required to "escape" it so it specifically looks for a period.
    ; ahk	Matches the literal sequence of characters "ahk"
    ;ScriptTitle := RegExMatch(WindowTitle, "\S+\.ahk", &Match) ? Match[0] : ""

    ScriptPath := GetScriptPath()

    ; Backup clipboard
    OldClipboard := ClipboardAll()

    ; Copy all text to clipboard
    A_Clipboard := "" 
    Send("^a^c")

    ; If no clipboard data then return
    if !ClipWait(2)
    {
        A_Clipboard := OldClipboard
        return
    }

    ; Get the clipboard content
    ScriptContent := A_Clipboard

    ; Restore clipboard
    A_Clipboard := OldClipboard

    GetVersion(ScriptContent, &OldVersion, &NewVersion)

    if (IncrementVersion) {

        NewScriptContent := StrReplace(ScriptContent, OldVersion, NewVersion)

        ; If version string not found then return
        If (NewScriptContent = "") {
            Send("^{Home}")
            SoundBeep
            return
        }

        ; Paste changes
        A_Clipboard := NewScriptContent
        ; All text is still selected: Send("^a^c")
        Send("^v") ; paste
        Sleep(100) ; Small delay to ensure paste finishes
        Send("^s") ; save changes
        Send("^{Home}") ; Scroll back to top

        Version:= NewVersion

    } else {

        Version:= OldVersion
    }

    SaveAs(ScriptPath, Version)

    WinActivate(MyGui.Hwnd)

}

GetVersion(ScriptContent, &OldVersion, &NewVersion) {

    OldVersion := ""
    NewVersion := ""

    ; Pattern: Matches 'v' (no space) or 'Version,' or 'Version:' (optional space)
    ;Pattern := "([v, :])(\s*)(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; Pattern: Matches 'v' (no space)
    ;Pattern := "v(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; Pattern: Matches X.X.X.X
    Pattern := "(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; If pattern found then extract version, increment, then replace all old versions with new version
    if RegExMatch(ScriptContent, Pattern, &Match) {
        Major  := Match[1]
        Minor  := Match[2]
        Patch  := Match[3]
        Build  := Match[4]

        OldVersion := Major "." Minor "." Patch "." Build
        Build++
        NewVersion := Major "." Minor "." Patch "." Build
        
    }
}

ReplaceAllVersions(ScriptContent, NewVersion) {

    ; find the first match vX.X.X.X
    ; update version
    ; replace all old versions with new version

    NewContent:=""
    
    ; Pattern: Matches 'v' (no space) or 'Version,' or 'Version:' (optional space)
    ;Pattern := "([v, :])(\s*)(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; Pattern: Matches 'v' (no space)
    ;Pattern := "v(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; Pattern: Matches X.X.X.X
    Pattern := "(\d+)\.(\d+)\.(\d+)\.(\d+)"

    ; If pattern found then extract version, increment, then replace all old versions with new version
    if RegExMatch(ScriptContent, Pattern, &Match) {
        Major  := Match[1]
        Minor  := Match[2]
        Patch  := Match[3]
        Build  := Match[4]
        
        ; Increment the build version
        NewBuild := Build + 1

        ; Replace all old version with new version
        OldVersion := Match[0]

        NewVersion := Major "." Minor "." Patch "." NewBuild
        
        ;MsgBox "FullOldMatch: " FullOldMatch "`n`nFullNewMatch: " FullNewMatch, "DEBUG FullMatch"

        NewContent := StrReplace(ScriptContent, OldVersion, NewVersion)
    }

    return NewContent

}

SaveAs(ScriptPath, Version) {

    oldFilePath := ScriptPath

    newFilePath := StrReplace(ScriptPath, ".ahk") "_" Trim(Version) ".ahk"

    ; FileSelect(Options, RootDir\Filename, Title, Filter)
    ; Option "S" = Save mode
    ; Option "16" = Prompt to overwrite if file exists
    SelectedFile := FileSelect("S16", newFilePath, "Save As", "Ahk Script (*.ahk)")

    if (SelectedFile = "")
        return

    try {

        if FileExist(SelectedFile)
            FileDelete(SelectedFile)
        FileCopy(oldFilePath, SelectedFile, Overwrite:=false)
        MsgBox("File saved to:`n`n" SelectedFile, "Success", "Iconi")
    } catch Error as e {
        MsgBox("Failed to save file.`n`nError: " e.Message, "Error", "IconX")
    }

}

GetScriptPath() {

    ; Save current clipboard to restore it later
    OldClipboard := ClipboardAll()
    A_Clipboard := "" 

    ; VS Code Shortcut for "Copy Path of Active File"
    ; Default: Shift + Alt + C
    Send("+!c")

    if ClipWait(2) {
        FilePath := A_Clipboard
        A_Clipboard := OldClipboard ; Restore original clipboard
        return FilePath
    }

    A_Clipboard := OldClipboard
    return ""
}
