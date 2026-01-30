; TITLE  :  VSCodeSaveVersion v1.0.0.3
; SOURCE :  jasc2v8 and https://www.autohotkey.com/boards/viewtopic.php?t=102798
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Saves the AHK script in VSCode as the current or a new verion: MyScript_vX.X.X.X+1
; USAGE  :  Requires the VSCode Extension: mark-wiemer.vscode-autohotkey-plus-plus
; NOTES  :

#Requires AutoHotkey 2+
#SingleInstance Force
#Include <String_Functions>

; if VSCode not active then return
if !WinActive("ahk_exe Code.exe")
    return

; #region GUI Create
MyGuiTitle := "VSCodeSaveVersion v1.0.0.3"
MyGui := Gui(, MyGuiTitle )
MyGui.BackColor := "7DA7CA" ; Steel Blue +2.5 Glaucous ; BackColor := "4682B4" ; Steel Blue
;MyGui.SetFont("S10", "Consolas")
;MyGui.SetFont()
ButtonSaveAs     := MyGui.AddButton("ym w75", "Save As")
ButtonSaveAsNew  := MyGui.AddButton("yp w75", "Save As New")
ButtonCopyToLib  := MyGui.AddButton("yp w75", "Copy To Lib")
ButtonCopyToApps := MyGui.AddButton("yp w75", "Copy To Apps")
buttonCancel     := MyGui.AddButton("yp w75", "Cancel")

; #region Button Handlers
ButtonSaveAs.OnEvent("Click", ButtonSaveAs_Click)
ButtonSaveAsNew.OnEvent("Click", ButtonSaveAsNew_Click)
ButtonCopyToLib.OnEvent("Click", ButtonCopyToLib_Click)
ButtonCopyToApps.OnEvent("Click", ButtonCopyToApps_Click)
buttonCancel.OnEvent("Click", (*) => ExitApp())

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
    ahkLibDir := EnvGet("USERPROFILE") "\Documents\AutoHotkey\Lib\"
    CopyToDir(ahkLibDir)
    WinActivate(MyGui.Hwnd)
}
ButtonCopyToApps_Click(Ctrl, Info) {
    WinActivate("ahk_exe Code.exe")
    ahkAppsDir := EnvGet("USERPROFILE") "\Documents\AutoHotkey\AhkLauncher\AhkApps\"
    CopyToDir(ahkAppsDir)
    WinActivate(MyGui.Hwnd)
}

CopyToDir(TargetDir) {

    currentPath := GetVSCodePath()

    if (currentPath = "")
        return

    buttonPress:= MsgBox("Copy:`n`n"  currentPath "`n`nto:`n`n" TargetDir, "Copy", "YesNo Icon?")

    if (buttonPress="Yes") {

        filename := StrSplitPath(currentPath).FileName

        newPath := StrJoinPath(TargetDir, filename)

        if FileExist(newPath) {
            buttonPress:= MsgBox("Overwrite existing file?", "Copy", "YesNo Icon?")
            if (buttonPress="Yes")
            FileCopy(currentPath, newPath, Overwrite:=true)
        } else {
            FileCopy(currentPath, newPath)

        }
    }
 
}

SaveVersion(IncrementVersion:=false) {

    WinActivate("ahk_exe Code.exe")

    ; Get Window title
    WindowTitle := WinGetTitle("ahk_exe Code.exe")

    ; Extract the Script Title from the Window Title: "SaveAsVersion.ahk - SaveAsVersion - Visual Studio Code"
    ; \S+	Matches one or more non-whitespace characters. This includes letters, numbers, and symbols, but stops as soon as it hits a space, tab, or newline.
    ; \.	Matches a literal dot. In RegEx, a plain . is a wildcard, so the backslash \ is required to "escape" it so it specifically looks for a period.
    ; ahk	Matches the literal sequence of characters "ahk"
    ScriptTitle := RegExMatch(WindowTitle, "\S+\.ahk", &Match) ? Match[0] : ""

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

    MsgBox "Content:`n`n" SubStr(ScriptContent, 1, 128) "`n`nOldVersion: " OldVersion "`n`nNewVersion: " NewVersion, "DEBUG ScriptContent"

    if (IncrementVersion) {

        NewScriptContent := StrReplace(ScriptContent, OldVersion, NewVersion)

        ;MsgBox SubStr(NewScriptContent, 1, 128), "DEBUG NewScriptContent"

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

    ; Save
    SaveAs(ScriptTitle, Version)

    WinWaitClose("Save As")

    WinActivate(MyGui.Hwnd)

}

; Done
;ExitApp()

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

    ;MsgBox "OldVersion: " OldVersion "`n`nNewVersion: " NewVersion, "DEBUG GetVersion"

}

ReplaceAllVersions(ScriptContent, NewVersion) {

    ; find the first match vX.X.X.X
    ; update version
    ; replace all old versions with new version

    NewContent:=""
    
    ;MsgBox "IncrementVersion : " StrLen(ScriptContent), "DEBUG"

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

SaveAs(ScriptTitle, Version) {

    newFilename := StrReplace(ScriptTitle, ".ahk") "_" Trim(Version) ".ahk"

    Send("^ks")
    WinWait("Save As")
    Send(newFilename)

    ; User can press Save or Cancel.

}

GetVSCodePath() {
    if !WinActive("ahk_exe Code.exe") {
        MsgBox("VS Code is not the active window.")
        return
    }

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
