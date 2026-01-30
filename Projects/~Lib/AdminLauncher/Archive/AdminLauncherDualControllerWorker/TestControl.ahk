; TITLE: TestControl v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
;#NoTrayIcon

;#Include AdminLauncher.ahk
#Include <AdminLauncher>
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

launcher.StartTask()  ; Starts Task AdminLauncher and runs AdminLauncher.ahk in Listen() mode

;
; Start Worker by sending WorkerPath to AdminLauncher.ahk
;

logger.Write("Start Worker")

workerPath := "D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorker.ahk"

success:= launcher.StartWorker(workerPath) ; no reply

if !success {
  MsgBox "Error Starting Worker:`n`n" workerPath
  launcher.Kill()
  ExitApp()
}

;
; Send params to Worker
;

SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
SyncBackPostAction  := "-monoff"
SyncBackProfile     :=  "TEST WITH SPACES"

params := RunShell.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackProfile)

launcher.Send(params)

;
; Receive reply
;

reply:= launcher.Receive()

logger.Write("Reply Received: " reply)

;
; Done
;

MsgBox("Complete.","CONTROL")

