; TITLE: TestControl v1.0.0.5
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
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

logger.Write("Run Task")

runner:= RunAdmin()

;
; Start Task RunAdmin which runs RunAdmin.ahk at runLevel='highest'
;

runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode

;runner.Listen()

;
; Send commandLine  to Worker
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

Test1() {
  runner:= RunAdmin()
  runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode
  runner.RunWait(commandLine)
  reply:= runner.Receive()
  logger.Write("Reply Received: " reply)
}

;
; TEST - Run one only
;

Test2() {
  runner:= RunAdmin()
  runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode
  commandLine := RunShell.ToCSV("C:\Users\Jim\Documents\AutoHotkey\Lib\TestLogArgs.ahk", "Hello", "World")
  runner.Run(commandLine)
}

Test1()
Test2()

;
; Done
;

MsgBox("Complete.","CONTROL")

