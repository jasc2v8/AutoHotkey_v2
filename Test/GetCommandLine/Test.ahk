;;TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  
; USAGE  :
; NOTES  :

;;TODO: Fix something

#Requires AutoHotkey v2+
#SingleInstance Off
#NoTrayIcon

if (A_Args.Length= 0) {

    Run("C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" A_Space A_ScriptFullPath " hello world")

    ExitApp
}

        ArgString := ""
        for arg in A_Args
        {
            ArgString .= ' "' . arg . '"'
        }

        MsgBox ArgString
    ExitApp
; Version 1.1.7
; Comprehensive Test: PATHEXT + UIAccess + Parameter Hand-off

; 1. Grab the raw command line for deep diagnostics
RawCmd := DllCall("GetCommandLine", "str")

; 2. Check if we need to relaunch with UIAccess
if !InStr(A_AhkPath, "_UIA.exe")
{
    if !RegExMatch(RawCmd, "i) /restart(?!\S)")
    {
        ; Rebuild the argument string from A_Args
        ArgString := ""
        for arg in A_Args
        {
            ArgString .= ' "' . arg . '"'
        }

        try 
        {
            ; Use the UIA version of the current interpreter
            UIA_Path := StrReplace(A_AhkPath, ".exe", "_UIA.exe")
            
            ; Explicitly call the interpreter + script + args
            Run('*UIAccess "' . UIA_Path . '" /restart "' . A_ScriptFullPath . '"' . ArgString)
            ExitApp
        }
        catch as err
        {
            MsgBox("UIA Relaunch Failed:`n" . err.Message)
            ExitApp
        }
    }
}

; 3. Final Verification Output
if (A_Args.Length > 0)
{
    ParamList := ""
    for i, a in A_Args
    {
        ParamList .= i ": " a "`n"
    }
    
    MsgBox(
        "TEST SUCCESSFUL`n" .
        "--------------------`n" .
        "Interpreter: " . (InStr(A_AhkPath, "_UIA") ? "UIA Mode" : "Standard") . "`n" .
        "Args Count: " . A_Args.Length . "`n" .
        "Values:`n" . ParamList
    )
}
else
{
    MsgBox(
        "TEST FAILED: No Parameters`n" .
        "--------------------`n" .
        "If you typed 'test.ahk hello', Windows stripped the word 'hello'.`n`n" .
        "Raw OS Command received:`n" . RawCmd
    )
}
