; TITLE: LogArgs v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFileHelper>
#Include <NamedPipeHelper>
#Include <RunSkipUACHelper>

logger:= LogFile("D:\TestControl.log", "TASK")

logger.Write("STARTING...")

Sleep 2000

logger.Write("Create pipe.")
pipe:=NamedPipe()

logger.Write("Create server.")
pipe.CreateServer()

logger.Write("Read request.")
request := pipe.Read()
logger.Write("Request Received: " request)

reply:= "Hello from Test Task."

logger.Write("Send reply.")
pipe.Send()

logger.Write("Pipe close.")
pipe.Close()

MsgBox("Complete.")