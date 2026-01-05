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

;TODO check path?
RunSkipUACHelper("D:\Software\DEV\Work\AHK2\Projects\RunSkipUAC\TestWorker.exe")

; Required delay to allow worker to start
Sleep 500

try {

  logger.Write("Wait for pipe!")
  pipe:=NamedPipe("WORKER")

  r := pipe.WaitPipe(2000)
  if (!r) {
    logger.Write("Timeout Waiting for pipe.")
    ExitApp()
  }

  ;pipe.Wait()

  logger.Write("Pipe Ready!!!")
  Sleep 2000

  request:= "Run (SyncBackPath, SyncBackProfile)."
  logger.Write("Send Request: " request)
  pipe.Send(request)

  reply := pipe.Receive()
  logger.Write("Reply Received: " reply)

} catch any as e {

  logger.Write("ERROR: " e.Message)

} finally {

  logger.Write("Pipe close.")
  pipe.Close()

}

  SoundBeep 600

  MsgBox("Complete.")

