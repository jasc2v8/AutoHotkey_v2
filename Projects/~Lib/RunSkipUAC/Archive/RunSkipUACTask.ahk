; TITLE:    AhkRunSkipUAC v1.0
; SOURCE:   jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:

    AhkRunSkipUAC.ini
    [SETTINGS]
    PROGRAM := "C:\ProgramData\AutoHotkey\BackupControlTool\BackupControlTask.exe"
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <RunHelper>
#Include <IniHelper>

; #region Globals

global INI_PATH := EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.ini"

global INI      := IniHelper(INI_PATH)

ProgramPath := INI.ReadSettings("PROGRAM")

if !FileExist(ProgramPath) {
    MsgBox "File not Exist: " ProgramPath, "AhkRunSkipUAC", "IconX"
    ExitApp()
}

; Run
Output := RunHelper(ProgramPath)

; DEBUG
;FileAppend(Output "`n", EnvGet("PROGRAMDATA") "\AutoHotkey\AhkRunSkipUAC\AhkRunSkipUAC.log")
