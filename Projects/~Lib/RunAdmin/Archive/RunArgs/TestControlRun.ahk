; TITLE: TestControl v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include AdminLauncher.ahk
#Include <RunShell>

MsgBox(,"CONTROL")

logger:= LogFile("D:\TestControlRun.log", "CONTROL", true)

logger.Write("Run Task")

runner:= AdminLauncher()

runner.StartTask()

; if worker is EXE
;cmd := 'D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorkerRun.exe "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'

; if worker is AHK
;cmd := '"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorkerRun.ahk" "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe" "TEST WITH SPACES"'
workerPath          := "D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorkerRun.ahk"
SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
SyncBackPostAction  := "-monoff"
SyncBackProfile     :=  "TEST WITH SPACES"

;cmd             := RunShell.ToCSV(ahkPath, workerPath, SyncBackPath, SyncBackProfile)
cmd             := RunShell.ToCSV(workerPath, SyncBackPath, SyncBackPostAction, SyncBackProfile)

logger.Write("Run TestWorker with params: " cmd)

success := runner.Send(cmd)

logger.Write("success: " success)

;success := runner.Send("ProgramExe, PostAction, Profile")

;logger.Write("success: " success)

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

MsgBox("Complete.","CONTROL")

