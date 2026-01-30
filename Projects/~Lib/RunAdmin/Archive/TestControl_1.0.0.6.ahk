; TITLE: TestControl v1.0.0.6
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
  ; SyncBackPath        := "C:\Program Files (x86)\SyncBackSE\SyncBackSE.exe"
  ; SyncBackPostAction  := "monoff"
  ; SyncBackProfile     := "TEST WITH SPACES"
  ; commandCSV := RunLib.ToCSV(SyncBackPath, SyncBackPostAction, SyncBackProfile)
  ; runner.StartTask()  ; Starts Task RunAdmin which runs RunAdmin.ahk in Listen() mode
  ; runner.RunWait(commandCSV)
  ; reply:= runner.Receive()
  ; logger.Write("Reply Received: " reply)
}

;Case 1, Option 1: Run (no reply)
Test1() {

  ; works for both .ahk and .exe

  commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /Run, " .
                "D:\TEST\TestLogArgs.exe, Hello, World"

  commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /Run, " .
                "D:\TEST\TestLogArgs.ahk, Hello, World"

  log_file.Write(commandCSV)

  ; RunLib will prepend A_AhkPath for Script.ahk
  run_lib.Run(commandCSV)
}

;Case 1, Option 1: RunWait with reply
Test2() {

  ipc := RunAdminIPC()
  ;ipc_send    := RunAdminIPC("")

  ; works for both .ahk and .exe

  commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /RunWait, " .
                "D:\TEST\StdOutArgs.exe, Hello, World"

  ;commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /RunWait, " .
  ;              "D:\TEST\StdOutArgs.exe, Hello, World"

  log_file.Write(commandCSV)

  ; RunLib will prepend A_AhkPath for Script.ahk
  run_lib.Run(commandCSV)

  ;pipe:= NamedPipe()
  ;pipe.Wait()
  ;reply:= pipe.Receive()
  ;pipe.Close()
  reply:="NOTHING"

  reply:= ipc.Receive()

  log_file.Write("reply: " reply)

  MsgBox reply, "Reply"

}

;Case 1, Option 2: Start Task RunAhk then Command via NamedPipe IPC
Test3() {

  ipc:= RunAdminIPC()

  ipc.StartTask()
  
  commandCSV := "/RunWait, D:\TEST\StdOutArgs.exe, Hello, World"

  ;commandCSV := "D:\Software\DEV\Work\AHK2\Projects\~Lib\RunAdmin\RunAdmin.ahk, /RunWait, " .
  ;              "D:\TEST\StdOutArgs.exe, Hello, World"

  log_file.Write(commandCSV)

  ; RunLib will prepend A_AhkPath for Script.ahk
  ;run_lib.Run(commandCSV)

  ipc.Send(commandCSV)

  ;pipe:= NamedPipe()
  ;pipe.Wait()
  ;reply:= pipe.Receive()
  ;pipe.Close()
  reply:="NOTHING"

  reply:= ipc.Receive()

  log_file.Write("reply: " reply)

  MsgBox reply, "Reply"

}

;Test1()
;Test2()
Test3()
;
; Done
;

MsgBox("Complete.","CONTROL")

 ExitApp()
