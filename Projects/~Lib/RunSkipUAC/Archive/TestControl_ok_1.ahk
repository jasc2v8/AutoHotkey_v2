; TITLE: TestControl v0.0
/*
  TODO:

TestControl

	pipe:=NamedPipe(AHK_RunSkipUAC)
	RunTask(AHK_RunSkipUAC)
	pipe.Wait()
	pipe.Send(WorkerPath)
	pipe.Close()
	
	pipe:=NamedPipe(WORKER)
	pipe.Wait()
	pipe.Send(Profile, Actions)
	output:=pipe.Receive()
	process output
	pipe.Send("TERMINATE")
	ExitApp

AHK_RunSkipUAC.Program:=RunSkipUAC.ahk

RunSkipUAC.ahk
	pipe:=NamedPipe(AHK_RunSkipUAC)
	pipe.Create()
	request:=pipe.Receive(WorkerPath)
	RunNoWait((WorkerPath)
	pipe.Close
	ExitApp

TestWorker
	global SyncBackPath:=...SyncBack.exe
	
	pipe:=NamedPipe(WORKER)
	pipe.Create()
	profile, actions:=pipe.Receive()
	
	output:=Run(SyncBackPath, profile)
	Handle actions
	
	path.Send(ACK: output)
	pipe.Receive() ; "terminate"
	path.Close()
	ExitApp


*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>
#Include C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk

MsgBox(,"CONTROL")

TASK_NAME:= "AHK_RunSkipUAC"

logger:= LogFile("D:\TestControl.log", "CONTROL", true)

logger.Write("Run Task: " TASK_NAME)

runner:= RunSkipUAC()

runner.StartTask(TASK_NAME)

runner.RunElevated("D:\Software\DEV\Work\AHK2\Projects\~Lib\RunSkipUAC\TestWorker.ahk")

runner.Send("ProgramExe, PostAction, Profile")

Sleep 400

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

; pipe:= NamedPipe("WORKER")
; r := pipe.Wait(5000)

; if (!r) {
; 	logger.Write("Timeout Waiting for pipe.")
; 	MsgBox "Timeout Waiting for pipe.", "Timeout", "IconX"
; 	ExitApp()
; }

; pipe.Send("ProgramExe, PostAction, Profile")
; pipe.Close()
; pipe:=""

; ;required!
; Sleep 200

; pipe:= NamedPipe("WORKER")
; pipe.Create()
; reply:= pipe.Receive()
; logger.Write("Reply Received: " reply)
; pipe.Close()



; runner.Send("ProgramExe, PostAction, Profile")

; reply:= runner.Receive()

; logger.Write("Reply: " reply)

; ; logger.Write("Pipe Closed")

; MsgBox("Complete.")


; pipe:= NamedPipe("WORKER")
; r := pipe.Wait(5000)

; if (!r) {
; 	logger.Write("Timeout Waiting for pipe.")
; 	MsgBox "Timeout Waiting for pipe.", "Timeout", "IconX"
; 	ExitApp()
; }

; pipe.Send("Profile, Actions")
; reply:= pipe.Receive()
; logger.Write("Reply: " reply)
; pipe.Close()

; logger.Write("Pipe Closed")

MsgBox("Complete.")

