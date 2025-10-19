#Requires AutoHotkey v2.0+
#SingleInstance Force

if A_IsAdmin
{
  MsgBox 'This script was run as admin!'
} else {
  MsgBox 'This script was NOT run as admin!'
}

full_command_line := DllCall("GetCommandLine", "str")

if (RegExMatch(full_command_line, " /restart(?!\S)"))
  MsgBox "This script was restarted as admin!"

if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        else
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
    }
    ExitApp
}

MsgBox "A_IsAdmin: " A_IsAdmin "`n`nCommand line:`n`n" full_command_line

; ** End Script
ExitApp
Escape::ExitApp