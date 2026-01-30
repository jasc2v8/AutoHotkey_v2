; TITLE: TestControl v1.0.0.7
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Off
;#NoTrayIcon

;#Include RunAdmin.ahk
;#Include <RunAdmin>


#Include <LogFile>
;#Include RunAdmin.ahk
#Include RunAdminIPC.ahk
#Include <RunLib>


MsgBox(,"CONTROL")

;
; Initialize
;

log_file:= LogFile("D:\TestControl.log", "CONTROL", true)

run_lib := RunLib()



;logger.Write("Run Task")

;runner:= RunAdmin()

;
; Start Task RunAdmin which runs RunAdmin.ahk at runLevel='highest'
;

;runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode

;runner.Listen()

;
; Send commandCSV  to Worker
;

;A_AhkPath ADDED BY RunAdmin: commandCSV := RunLib.ToCSV(A_AhkPath, "D:\Software\DEV\Work\AHK2\Projects\~Tools\AdminStart\Test.ahk")
;A_AhkPath ADDED BY RunAdmin: commandCSV := RunLib.ToCSV(A_AhkPath, "D:\TEST\Show Args.ahk", "p1", "p2", "p3")

;commandCSV := RunLib.ToCSV("D:\TEST\Show Args.exe", "p1", "p2", "p3")
;commandCSV := RunLib.ToCSV("D:\TEST\StdOutArgs.exe", "p1", "p2", "p3")
;commandCSV := RunLib.ToCSV("D:\TEST\TestLog.exe")
;commandCSV := "D:\TEST\TestLog.ahk"
;commandCSV := "D:\TEST\Test Log.ahk"
;commandCSV := RunLib.ToCSV("D:\TEST\Show Args.ahk", "p1", "p2", "p3")

; commandCSV must be a string or CSV string. Quotes are added to handle spaces by RunLib

Test9() {
  SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
  SyncBackPostAction  := ""
  SyncBackProfile     := "TEST WITH SPACES"

  ipc := RunAdminIPC()
  ipc.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode

  run_lib := RunLib()
  commandCSV := run_lib.ToCSV("/RunWait",SyncBackPath, SyncBackPostAction, SyncBackProfile)
  
  ipc.Send(commandCSV)
  reply:= ipc.Receive()

  MsgBox "Reply Received: [" Trim(reply," `n") "]"
}

; Case 1. Option 1: Run (no reply)
; Case 2. Shortcut.lnk - Paste the CommandCSV as the Target in the shortcut properties
Test1() {

  ; Args are available for both .ahk and .exe

  commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /Run, " .
                "D:\TEST\TestLogArgs.exe, Hello, World"

  log_file.Write(commandCSV)

  ; RunLib will prepend A_AhkPath for Script.ahk
  run_lib.Run(commandCSV)
}

;Case 1, Option 1: RunWait with reply
Test2() {

  ; Use ipc to recevie reply
  ipc := RunAdminIPC()

  ipc.StartTask()

  ; Args are available for both .ahk and .exe
   commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /RunWait, " .
                "D:\TEST\StdOutArgs.ahk, Hello, World"

  log_file.Write(commandCSV)

  ; RunLib will prepend A_AhkPath for Script.ahk
  run_lib.Run(commandCSV)

  reply:= ipc.Receive()

  log_file.Write("reply: " reply)

  MsgBox reply, "Reply"

}

;Case 1, Option 2: Start Task RunAhk then Command via NamedPipe IPC
Test3() {

  ipc:= RunAdminIPC()

  ipc.StartTask()
  
  ; RunAdmin.ahk is started by StartTask() so exclude from the commandCSV
  commandCSV := "/RunWait, D:\TEST\StdOutArgs.exe, Hello, World"

  log_file.Write(commandCSV)

  ipc.Send(commandCSV)

  ;pipe:= NamedPipe()
  ;pipe.Wait()
  ;reply:= pipe.Receive()
  ;pipe.Close()
  
  reply:= ipc.Receive()

  ;no ipc2:= RunAdminIPC()
  ;no reply:= ipc2.Receive()

  log_file.Write("reply: " reply)

  MsgBox reply, "Reply"

}

Test4() {
}

; MsgBox "Test9", "Test Start"
; Test9()
; ExitApp

; MsgBox "Test1", "Test Start"
; Test1()

; MsgBox "Test2", "Test Start"
; Test2()

MsgBox "Test3", "Test Start"
Test3()

;MsgBox "Test4", "Test Start"
;Test4()

;
; Done
;

MsgBox("Complete.","CONTROL")

 ExitApp()
