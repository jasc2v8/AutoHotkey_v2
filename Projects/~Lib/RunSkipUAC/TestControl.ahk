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

runner.Run("D:\Software\DEV\Work\AHK2\Projects\~Lib\RunSkipUAC\TestWorker.ahk")

runner.Send("ProgramExe, PostAction, Profile")

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

MsgBox("Complete.","CONTROL")

; launcher := AdminLauncher()
; launcher.StartTask