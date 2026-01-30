; TITLE: TestControl v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Off
;#NoTrayIcon

#Include RunAdmin.ahk
;#Include <RunAdmin>
#Include <LogFile>
#Include <RunShell>

MsgBox(,"CONTROL")

;
; Initialize
;

logger:= LogFile("D:\TestControl.log", "CONTROL", true)

runner:= RunAdmin()

;
; Start Task RunAdmin which runs RunAdmin.ahk at runLevel='highest'
;

logger.Write("Run Task")

runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode

;
; Send commandLine
;

SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
SyncBackPostAction  := "monoff"
SyncBackProfile     := "TEST WITH SPACES"

commandLine := RunShell.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackProfile)

;A_AhkPath ADDED BY RunAdmin: commandLine := RunShell.ToCSV(A_AhkPath, "D:\Software\DEV\Work\AHK2\Projects\~Tools\AdminStart\Test.ahk")
;A_AhkPath ADDED BY RunAdmin: commandLine := RunShell.ToCSV(A_AhkPath, "D:\TEST\Show Args.ahk", "p1", "p2", "p3")

;commandLine := RunShell.ToCSV("D:\TEST\Show Args.exe", "p1", "p2", "p3")
;commandLine := RunShell.ToCSV("D:\TEST\StdOutArgs.exe", "p1", "p2", "p3")
;commandLine := RunShell.ToCSV("D:\TEST\TestLog.exe")
;commandLine := "D:\TEST\TestLog.ahk"
;commandLine := "D:\TEST\Test Log.ahk"
;commandLine := RunShell.ToCSV("D:\TEST\Show Args.ahk", "p1", "p2", "p3")

; commandCSV must be a string or CSV string. Quotes are added to handle spaces by RunShell
runner.Run(commandLine)

;
; Receive reply
;

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

;
; Done
;

MsgBox("Complete.","CONTROL")

