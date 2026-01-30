; TITLE: TestControl v0.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+
#SingleInstance Force
#NoTrayIcon

#Include <LogFile>
#Include <NamedPipe>
#Include <AdminLauncher>

MsgBox(,"CONTROL")

logger:= LogFile("D:\TestControl.log", "CONTROL", true)

logger.Write("Run Task")

runner:= AdminLauncher()

runner.StartTask()

runner.Run("D:\Software\DEV\Work\AHK2\Projects\~Lib\AdminLauncher\TestWorker.ahk")

runner.Send("ProgramExe, PostAction, Profile")

reply:= runner.Receive()

logger.Write("Reply Received: " reply)

MsgBox("Complete.","CONTROL")

