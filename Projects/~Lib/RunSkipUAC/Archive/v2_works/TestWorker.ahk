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

;logger.Write("STARTING...")

try {

  ;logger.Write("Create pipe WORKER.")
  pipe:=NamedPipe("WORKER")
  ;pipe:=NamedPipe()

  logger.Write("Create server.")
  pipe.Create()

  logger.Write("Read request.")
  request := pipe.Receive()
  logger.Write("Request Received: " request)

  reply:= "Reply from WORKER: " request

  logger.Write("Send reply.")
  pipe.Send(reply)

  ; request:= pipe.Receive()
  ; logger.Write("Request Received: " request)



} catch any as e {

  logger.Write("ERROR: " e.Message)
  
} finally {

  logger.Write("Pipe close.")
  pipe.Close()

}

SoundBeep
MsgBox("Complete.")