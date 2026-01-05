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

logger:= LogFile("D:\TestWorker.log", "WORKER")

try {

  ; Create a pipe instance
  pipe:=NamedPipe("WORKER")

  logger.Write("Create server.")

  ; This server creates the pipe
  pipe.Create()

  logger.Write("Read request.")

  ; Receive the request from the client
  request := pipe.Receive()

  logger.Write("Request Received: " request)

  reply:= "Reply from WORKER: " request

  logger.Write("Send reply.")

  ; Send reply to the client
  pipe.Send(reply)

} catch any as e {

  logger.Write("ERROR: " e.Message)
  
} finally {

  logger.Write("Pipe close.")
  pipe.Close()
  pipe:=""

}

SoundBeep
MsgBox("Complete.")