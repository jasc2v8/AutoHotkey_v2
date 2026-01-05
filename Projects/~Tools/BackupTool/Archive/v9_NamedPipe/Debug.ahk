#Requires AutoHotkey 2.0+

#SingleInstance Force
#NoTrayIcon

#Include <CRC>
#Include <Messenger>

DetectHiddenWindows True 
SetTitleMatchMode 2 ; contains

;pid:= ProcessExist("BackupControlWorker.exe")
;MsgBox WinExist("ahk_pid " pid) ", " pid

;ok MsgBox ProcessExist("RunSkipUAC.exe")

;MsgBox ProcessExist("BackupControlWorker.exe")

MsgBox WinExist("RunSkipUAC ahk_class AutoHotkey")

MsgBox WinWait("RunSkipUAC")

MsgBox WinExist("RunSkipUAC")

;SetTitleMatchMode 2 ; For partial title matching
;MsgBox WinExist("ahk_exe BackupControlWorker.exe")

;     ipc:= Messenger(CRC.Get64("BackupControlTool"))

; WorkerPath   := EnvGet("PROGRAMDATA") "\AutoHotkey\BackupControlTool\BackupControlWorker.ahk"

;         ipc.Send("RunSkipUAC ahk_class AutoHotkey", WorkerPath)