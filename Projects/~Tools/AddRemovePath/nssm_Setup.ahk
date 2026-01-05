; TITLE  :  nssm_Setup v1.0
; SOURCE :  Copilot, Gemini, AHKv2 Forums, and myself 
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

; #region Admin Check

; Requires Administrator privileges
full_command_line := DllCall("GetCommandLine", "str")

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\\ S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp  ; Exit the current, non-elevated instance
}

; #region Main

#Include <Debug>
#Include <AddRemovePATH>
#Include <MsgBoxCustom>

NSSMx64Path := "D:\Software\DEV\Work\AHK2\Projects\WindowsService\nssm\win64\nssm.exe"
NSSMx86Path := "D:\Software\DEV\Work\AHK2\Projects\WindowsService\nssm\win32\nssm.exe"

NSSMx64ProgramFilesDir := EnvGet("ProgramFiles")         "\NSSM"
NSSMx86ProgramFilesDir := EnvGet("ProgramFiles(x86)")    "\NSSM"

; user select
MyExePath           := NSSMx64Path
MyProgramFilesDir   := (MyExePath = NSSMx64Path) ? NSSMx64ProgramFilesDir : NSSMx86ProgramFilesDir

Looping:= True

while (Looping) {

    text := "Path: " MyProgramFilesDir "`n`nInstall and add to System PATH.`n`nUninstall and remove from System PATH."
    r:= MsgTerminal(text, "NSSM Setup", "&Install, &Uninstall, Default &Cancel, AlignCenter")

    switch r {
        case "&Install":
            Install(MyExePath, MyProgramFilesDir)
        case "&Uninstall":
            UnInstall(MyExePath, MyProgramFilesDir)
        case "&Cancel":
            Looping:= False
        default:
            continue
    }
}

; #region Functions

Install(MyExePath, MyProgramFilesDir) {

    if !DirExist(MyProgramFilesDir)
        DirCreate MyProgramFilesDir

    FileCopy MyExePath, MyProgramFilesDir, OverwriteYes:=1

    r:= AddToSystemPath(MyProgramFilesDir)

;MsgBox r

    if (r = "Duplicate Found") {
        text:="NSSM installed but,`n`nNOT added a Duplicate to PATH:`n`n" MyProgramFilesDir
    } else {
        text:="NSSM installed and added to PATH:`n`n" MyProgramFilesDir
    }
    MsgT(text, "NSSM Setup", "&OK",,,,,,,"icon!", "icon!")
}

UnInstall(MyExePath, MyProgramFilesDir) {

    if !DirExist(MyProgramFilesDir) {
        MsgT("Dir Not Exist:`n`n" MyProgramFilesDir, "NSSM Setup", "",,,,,,,"iconI", "iconI")
        return
    }
    r := MsgT("UNINSTALL - are you sure?", "NSSM Setup", "Yes, &No",,,,,,,"icon?", "icon?")
    if (r != "Yes")
        return

    try {
        DirDelete MyProgramFilesDir, Recurse:=True        
    } catch Error as e {
        MsgT("Error Uninstalling:`n`n" e.Message, "NSSM Setup",,,,,,,,"iconX", "iconX")
    }

    r:= RemoveFromSystemPath(MyProgramFilesDir)

    if (r = "")
        MsgT("Error Removing from System Path:`n`n" MyProgramFilesDir, "NSSM Setup",,,,,,,,"iconX", "iconX")
    else
        MsgT("Success Uninstalling and Removing from System Path:`n`n" MyProgramFilesDir, "NSSM Setup",,,,,,,,"icon!", "icon!")

}




