; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>
#Include C:\ProgramData\AutoHotkey\RunSkipUAC\RunSkipUAC.ahk

logger:= LogFile("D:\TestWorker.log", "WORKER", true)

runner:= RunSkipUAC()

request:= runner.Receive()

logger.Write("Request Received: " request)

r := runner.Send("ACK: " request)

logger.Write("Reply Sent: ACK:" request ", r: " r)

logger.Write("Exit")
