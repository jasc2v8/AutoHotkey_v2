; TITLE: TestControl v1.0.0.1
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Ignore
;#NoTrayIcon

#Include RunAdmin.ahk
;#Include <AdminLauncher>
#Include <LogFile>
#Include <RunShell>

MsgBox(,"CONTROL")

;
; Initialize
;

logger:= LogFile("D:\TestControl.log", "CONTROL", true)

logger.Write("Run Task")

launcher:= AdminLauncher()

;
; Start Task AdminLauncher which runs AdminLauncher.ahk at runLevel='highest'
;

launcher.StartTask()  ; Starts Task AdminLauncher which runs AdminLauncher.ahk in Listen() mode

;
; Start Worker by sending WorkerPath to AdminLauncher.ahk
;

; logger.Write("Start Worker")

; workerPath := "D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorker.ahk"

; success:= launcher.StartWorker(workerPath) ; no reply

; if !success {
;   MsgBox "Error Starting Worker:`n`n" workerPath
;   launcher.Kill()
;   ExitApp()
; }

;
; Send commandLine  to Worker
;

SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
SyncBackPostAction  := "monoff"
SyncBackProfile     := "TEST WITH SPACES"

commandLine := RunShell.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackProfile)

;A_AhkPath ADDED BY AdminLauncher: commandLine := RunShell.ToCSV(A_AhkPath, "D:\Software\DEV\Work\AHK2\Projects\~Tools\AdminStart\Test.ahk")
;A_AhkPath ADDED BY AdminLauncher: commandLine := RunShell.ToCSV(A_AhkPath, "D:\TEST\Show Args.ahk", "p1", "p2", "p3")

;commandLine := RunShell.ToCSV("D:\TEST\Show Args.exe", "p1", "p2", "p3")
;commandLine := RunShell.ToCSV("D:\TEST\StdOutArgs.exe", "p1", "p2", "p3")
;commandLine := RunShell.ToCSV("D:\TEST\TestLog.exe")
;commandLine := "D:\TEST\TestLog.ahk"
;commandLine := "D:\TEST\Test Log.ahk"
;commandLine := RunShell.ToCSV("D:\TEST\Show Args.ahk", "p1", "p2", "p3")

; commandCSV must be a string or CSV string. Quotes are added to handle spaces by RunShell
launcher.Send(commandLine)

;
; Receive reply
;

reply:= launcher.Receive()

logger.Write("Reply Received: " reply)

;
; Done
;

MsgBox("Complete.","CONTROL")

