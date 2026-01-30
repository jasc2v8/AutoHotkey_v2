; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <RunShell>

;#Include <AdminLauncher>
#Include AdminLauncher.ahk

logger:= LogFile("D:\TestWorkerRun.log", "WORKER", true)

logger.Write("A_Args.Length: " A_Args.Length)

if (A_Args.Length > 0) {
  Loop A_Args.Length
    logger.Write("Arg" A_index ": " A_Args[A_Index])
}

if (A_Args.Length = 0)
  return

command := RunShell.ArrayToCSV(A_Args)

logger.Write("Worker RunShell: " command)

RunShell(command)

;logger.Write("Worker Receiving...")

runner:= AdminLauncher()

;request:= runner.Receive()

;logger.Write("Request Received: " request)

r := runner.Send("ACK: " command)

logger.Write("Reply Sent: ACK:" command ", r: " r)

logger.Write("Exit")
