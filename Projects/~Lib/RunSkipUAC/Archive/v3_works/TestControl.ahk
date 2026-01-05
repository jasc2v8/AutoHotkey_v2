; TITLE: TestControl v0.0
/*
  TODO:

  TestControl
    RunAHKHelper("TestTask.ahk")
    pipe:=NamedPipeHelper()
    pipe.Connect()
    pipe.Send("Hello from Test Control.")
    reply := pipe.Read()
    logger.Write("Reply: " reply)

  TestControlTask
    pipe:=NamedPipeHelper()
    request := pipe.Read()
    logger.Write("TASK Request: " request)
    reply:= "Hello from Test Control Task."
    logger.Write("TASK Reply: " reply)
    pipe.Send()
    pipe.Close()

*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFileHelper>
#Include <NamedPipeHelper>
#Include <RunSkipUACHelper>

logger:= LogFile("D:\TestControl.log", "CONTROL")

logger.Write("Run TestWorker")

RunSkipUAC("D:\Software\DEV\Work\AHK2\Projects\RunSkipUAC\TestWorker.ahk")

try {

  logger.Write("Wait for pipe.")

  ; Create a pipe instance
  pipe:=NamedPipe("WORKER")

  ; Wait for pipe to be created by the server
  r := pipe.Wait(1000)
  if (!r) {
    logger.Write("Timeout Waiting for pipe.")
    ExitApp()
  }

  logger.Write("Pipe Ready.")

  request:= "Run (SyncBackPath, SyncBackProfile)."

  logger.Write("Send Request: " request)

  ; Send request to server
  pipe.Send(request)

  ; Receive reply from server
  reply := pipe.Receive()

  logger.Write("Reply Received: " reply)

} catch any as e {

  logger.Write("ERROR: " e.Message)

} finally {

  logger.Write("Pipe close.")
  pipe.Close()
  pipe:=""

}

SoundBeep 600

MsgBox("Complete.")

