; ABOUT:    MyScript v0.0
; SOURCE:   
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


        ; Broadcast environment change so Explorer and apps see it
        ; SendMessage(MsgNumber, wParam, lParam, Control, WinTitle, WinText, ExcludeTitle, ExcludeText, Timeout)
        ;SendMessage(0x1A, 0, "Environment", , "Program Manager", , , , 1000)

        HWND_BROADCAST:=0xFFFF
        WM_SETTINGCHANGE:=0x1A
        SMTO_ABORTIFHUNG:=0x0002
        timeoutMS:= 5000
        timeoutResult:=0
        
        DllCall("SendMessageTimeoutW", 
            "Ptr", HWND_BROADCAST,
            "UInt", WM_SETTINGCHANGE,
            "Ptr", 0, 
            "WStr", "Environment", 
            "UInt", SMTO_ABORTIFHUNG, 
            "UInt", timeoutMS, 
            "Ptr*", &timeoutResult)

        MsgBox "timeoutResult: " timeoutResult

