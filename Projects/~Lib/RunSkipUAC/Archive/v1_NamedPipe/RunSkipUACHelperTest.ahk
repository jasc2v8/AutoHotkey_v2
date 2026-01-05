; TITLE  :  MyScript v0.0
; SOURCE :  jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Run any program elevated without the UAC prompt
; USAGE  :  RunSkipUAC.Run("C:\Windows\System32\cmd.exe")
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2.0+

#Include RunSkipUACHelper.ahk

ProgramPath:= "D:\Software\DEV\Work\AHK2\Projects\RunSkipUAC\LogTest.ahk"

;r := RunSkipUAC("").IsTaskRunning("AHK_RunSkipUAC")
;r:= (r=true) ? "True" : "False"

;MsgBox "IsTaskRunning: " r, "HELPER"

; for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name = 'AutoHotkey64_UIA.exe'") {
;     MsgBox "PID: " process.ProcessId "`nCommand Line: " process.CommandLine
; }
; ExitApp()


TrayTip "Running Program...", "HELPER"

RunSkipUAC(ProgramPath)

; r := RunSkipUAC("").IsTaskRunning("AHK_RunSkipUAC")
; r:= (r=true) ? "True" : "False"
; MsgBox "IsTaskRunning: " r, "HELPER"

;runner := RunSkipUAC(ProgramPath);r := runner.Run()
;rTrueFalse:= (r=true) ? "True" : "False"
;err := OSError()
;MsgBox "Result: " rTrueFalse "`n`nOSError: " err.Number "`n`nOSError Message: " err.Message "`n`nLast Error: " A_LastError, "HELPER"

MsgBox "Test Complete.", "HELPER"

